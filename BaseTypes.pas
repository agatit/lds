{*------------------------------------------------------------------------------
Klasy podstawowych typów obiektów aplikacji
@author   Adam Pietrzko, Dariusz Ludwiczak, S³awomir Kotkowski
@version  2007/11
@comment  AGAT IT S.A. 2010 (c) Wszystkie prawa zastrze¿one
-------------------------------------------------------------------------------}

unit BaseTypes;

interface

uses
  ActnList,Windows, ActiveX, Classes, ComCtrls, Controls, DB,DBConsts, Graphics, ImgList, SysUtils,
  CRParser, DAConsts, DBAccess,ExceptionForm,AppLogs, Types, Variants,
  {$IFDEF ORACLE_DB}
    OraParser,
    Ora,
  {$ELSE}
    MSParser,
  MSAccess,
  {$ENDIF}
   TypInfo, Contnrs, dxBar;


  resourcestring
    strNoData = '<Brak danych do wyœwietlenia>';

type
  TFrameParameterList = class;

  TEventStates = (esActive = 1, esAck = 2, esClose = 3);

  TFieldTag = (ftNone, ftReserved, ftUnique, ftList);

{*------------------------------------------------------------------------------
Rekord dla zmiennej do potweirdzenia zdarzenia
-------------------------------------------------------------------------------}
  TEventAckVariable = packed record
    {*--------------------------------------------------------------------------
    Alias zmiennej do potwierdzania zdarzeñ
    ---------------------------------------------------------------------------}
    Name : String;
    {*--------------------------------------------------------------------------
    Identyfikator urz¹dzenia potwierdzaj¹cego
    ---------------------------------------------------------------------------}
    AckDeviceID : integer;
    {*--------------------------------------------------------------------------
    Wartoœæ zmiennej do potwierdzania 
    ---------------------------------------------------------------------------}
    Value : Variant;
  end;
{*------------------------------------------------------------------------------
Rekord z danymi weryfikowanego pola
-------------------------------------------------------------------------------}
  TValidationData = packed record
    {*--------------------------------------------------------------------------
    Pole poddane sprawdzeniu wpisanej wartoœci
    ---------------------------------------------------------------------------}
    Field: TField;

    {*--------------------------------------------------------------------------
    Okreœla czy wpisana wartoœæ jest poprawna
    ---------------------------------------------------------------------------}
    Validated: Boolean;

    {*--------------------------------------------------------------------------
    Pozwala sprawdziæ pozosta³e pola pomimo b³êdnego wpisu
    ---------------------------------------------------------------------------}
    Skip: Boolean;

    {*--------------------------------------------------------------------------
    Okreœla czy ma zostaæ pokazana podpowidŸ
    ---------------------------------------------------------------------------}
    ShowHint: Boolean;

    {*--------------------------------------------------------------------------
    Tekst wyœwietlonej podpowiedzi
    ---------------------------------------------------------------------------}
    Hint: string;

    {*--------------------------------------------------------------------------
    Bierz¹ca zak³adka
    ---------------------------------------------------------------------------}
    CurrentTab: TWinControl;

    {*--------------------------------------------------------------------------
    Zmieñ zak³adkê na NewTab
    ---------------------------------------------------------------------------}
    NewTab: TWinControl;
  end;
{*------------------------------------------------------------------------------
Typy weryfikacji formy edycyjnej
-------------------------------------------------------------------------------}
  TValidationType = (vtPost, vtTabSwitch);

{*------------------------------------------------------------------------------
Klasa parametru podstawowej ramki aplikacji
-------------------------------------------------------------------------------}
  TFrameParameter = class(TObject)
  private
    FValue: Variant;
    FName: String;
    FCompositeType: Integer;
    FParentFrameParam: Integer;
    FChildren: TFrameParameterList;
    FFrameParam: Integer;
    function GetItemByName(AName: String): TFrameParameter;
    function GetItemByIndex(AIndex: Integer): TFrameParameter;
    function GetCount: Integer;
    function GetValueByName(AName: String): Variant;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(AName:String):TFrameParameter;
    property Count: Integer read GetCount;
    property ItemsByName[AName:String]:TFrameParameter read GetItemByName;  default;
    property ValueByName [AName:String]:Variant read GetValueByName;
    property ItemsByIndex[AIndex:Integer]:TFrameParameter read GetItemByIndex;
    property Value : Variant read FValue;
    property Name : String read FName;
    property CompositeType : Integer read FCompositeType;
    property ParentFrameParam : Integer read FParentFrameParam;
    property FrameParam : Integer read FFrameParam;
  end;

{*------------------------------------------------------------------------------
Klasa zarz¹dzaj¹ca list¹ parametrów podstawowej ramki aplikacji
-------------------------------------------------------------------------------}
  TFrameParameterList = class(TObject)
  private
    FFrameParameter:TObjectList;
    function GetValueByName(AName: String): Variant;
    function GetCount: Integer;
  public

    constructor Create;
    destructor Destroy; override;
    function GetItem(AName: String): TFrameParameter;
    property Count: Integer read GetCount;
    function Add(AName:String):TFrameParameter;
    function FillParameterList(ASourceParams : TDataSource; AFrameID:Integer; AParentFrameParamID: Integer = 0):Boolean;
  end;


{*------------------------------------------------------------------------------
Klasa pola bazodanowego do konfiguracji parametrów
-------------------------------------------------------------------------------}
  TParamDefField = class(TVariantField)
  private
    FParamValueType : integer;
    FParamValueFormat : string;
  published
    property ParamValueType : integer read FParamValueType write FParamValueType;
    property ParamValueFormat : string read FParamValueFormat write FParamValueFormat;
  end;

procedure StreamToFont(Stream: TStream; Font: TFont);
procedure FieldToFont(Field: TField; Font: TFont);
procedure FontToStream(Font: TFont; Stream: TStream);
procedure FontToField(Font: TFont; Field: TField);


implementation

uses
  CommCtrl, Messages, Dialogs, cxDBLookupComboBox;

{*------------------------------------------------------------------------------
Wstawia do obiektu TFont dane ze strumienia
@param Stream Strumieñ z danymi typu TFont
@param Font Obiekt typu TFont pobieraj¹cy dane ze strumienia
-------------------------------------------------------------------------------}
procedure StreamToFont(Stream: TStream; Font: TFont);
var
  S: ShortString;
  B: Byte;
  I: Integer;
begin
  with Stream do
  begin
    Read(S[0], 1);
    Read(S[1], Length(S));
    Font.Name := S;

    Read(I, SizeOf(I));
    //Font.Size := I;
    Font.Height := I;

    Read(B, SizeOf(B));
    Font.Style := TFontStyles(B);

    Read(I, SizeOf(I));
    Font.Color := I;
  end;
end;

{*------------------------------------------------------------------------------
Wstawia do obiektu TFont dane z pola typu ftBlob
@param Field Pole z danymi typu TFont
@param Font Obiekt typu TFont pobieraj¹cy dane z pola bazodanowego
-------------------------------------------------------------------------------}
procedure FieldToFont(Field: TField; Font: TFont);
var
  S: TMemoryStream;
begin
  if not Assigned(Font) then
    Font := TFont.Create;

  if not Assigned(Field) then Exit;
  if Field.DataType <> ftBlob then Exit;
  if Field.IsNull then Exit;

  S := TMemoryStream.Create;
  try
    (Field as TBlobField).SaveToStream(S);
    S.Position := 0;
    StreamToFont(S, Font);
  finally
    FreeAndNil(S);
  end;
end;

{*------------------------------------------------------------------------------
Wstawia do strumienia dane z obiektu TFont
@param Stream Strumieñ pobieraj¹cy dane z obiektu TFont
@param Font Obiekt typu TFont z danymi
-------------------------------------------------------------------------------}
procedure FontToStream(Font: TFont; Stream: TStream);
var
  S: ShortString;
  B: Byte;
  I: Integer;
begin
  with Stream do
  begin
    S := Font.Name;
    Write(S[0], 1);
    Write(S[1], Length(S));

    //I := Font.Size;
    I := Font.Height;
    Write(I, SizeOf(I));

    B := Byte(Font.Style);
    Write(B, SizeOf(B));

    I := Font.Color;
    Write(I, SizeOf(I));
  end;
end;

{*------------------------------------------------------------------------------
Wstawia do pola typu ftBlob dane z obiektu TFont
@param Field Pole pobieraj¹ce dane typu TFont
@param Font Obiekt typu TFont z danymi
-------------------------------------------------------------------------------}
procedure FontToField(Font: TFont; Field: TField);
var
  S: TMemoryStream;
begin
  if not Assigned(Font) then
    Font := TFont.Create;

  if not Assigned(Field) then Exit;
  if Field.DataType <> ftBlob then Exit;

  S := TMemoryStream.Create;
  try
    FontToStream(Font, S);
    S.Position := 0;
    (Field as TBlobField).LoadFromStream(S);
  finally
    FreeAndNil(S);
  end;
end;


{TFrameParameter}
function TFrameParameter.Add(AName: String): TFrameParameter;
begin
  if Assigned(FChildren) then
    Result:=FChildren.Add(AName);
end;

constructor TFrameParameter.Create;
begin
  FChildren := TFrameParameterList.Create;
end;

destructor TFrameParameter.Destroy;
begin
  FreeAndNil(FChildren);
  inherited;
end;

function TFrameParameter.GetCount: Integer;
begin
    Result:=0;
  try
  if Assigned(FChildren) then
    Result := FChildren.Count
  else
    Result:=0;
  except
    on e:exception do
  end;
end;

function TFrameParameter.GetItemByIndex(AIndex: Integer): TFrameParameter;
begin
  Result := (FChildren.FFrameParameter.Items[AIndex] as TFrameParameter);
end;

function TFrameParameter.GetItemByName(AName: String): TFrameParameter;
var
  i:Integer;
begin
  try
  Result:=Nil;
  if Assigned(FChildren) then
  for i := 0 to FChildren.FFrameParameter.Count-1 do

    
    if (FChildren.FFrameParameter.Items[i] as TFrameParameter).FName = AName then
      Result := (FChildren.FFrameParameter.Items[i] as TFrameParameter);

  except
    on e:exception do
    ShowExceptionForm(sParameterError, E.Message);
  end;
end;

function TFrameParameter.GetValueByName(AName: String): Variant;
var
  i:Integer;
begin
  try
    Result := ItemsByName[AName].Value;
  except
     on E: Exception do
    ShowExceptionForm(sParameterError, 'Brak Parametru: '+ AName + '! '+ E.Message);
  end;
end;
  

{ TFrameParameterList }

function TFrameParameterList.Add(AName: String):TFrameParameter;
var
  frameParameter:TFrameParameter;

  begin
    frameParameter.FName := AName;
    FFrameParameter.Add(frameParameter);
    Result := frameParameter;
end;


constructor TFrameParameterList.Create;
begin
  FFrameParameter := TObjectList.Create;
end;

destructor TFrameParameterList.Destroy;
begin
   FFrameParameter.OwnsObjects:=True;
   FreeAndNil(FFrameParameter);
  inherited;
end;

function TFrameParameterList.FillParameterList(ASourceParams : TDataSource; AFrameID,
  AParentFrameParamID: Integer): Boolean;
var
  tmp:TFrameParameter;
  i:Integer;
begin
  try
    {With AqueryParams do
    begin
      Active := False;
      ParamByName('FrameID').AsInteger := AFrameID;
      ParamByName('ParentFrameParamID').AsInteger := AParentFrameParamID;
      Active := True;
      First;
    end;}
    if not Assigned(ASourceParams) or not Assigned(ASourceParams.DataSet) then exit;
    if not ASourceParams.DataSet.Active then
      ASourceParams.DataSet.Active := True;
    ASourceParams.DataSet.First;
    while not ASourceParams.DataSet.Eof do
    begin
      tmp := TFrameParameter.Create;
      tmp.FValue := ASourceParams.DataSet.FieldByName('Value').Value;
      tmp.FCompositeType := ASourceParams.DataSet.FieldByName('TypeDefID').Value;
      if ASourceParams.DataSet.FieldByName('ParentFrameParamID').AsInteger=0 then
      tmp.FName := ASourceParams.DataSet.FieldByName('FrameParamDefName').Value
      else
      tmp.FName := ASourceParams.DataSet.FieldByName('ParamName').Value;
      tmp.FParentFrameParam := ASourceParams.DataSet.FieldByName('FrameParamID').Value;
      tmp.FFrameParam := ASourceParams.DataSet.FieldByName('FrameParamID').Value;
      FFrameParameter.Add(tmp);
      ASourceParams.DataSet.Next;
    end;
    for i := 0 to FFrameParameter.Count-1 do
    if (FFrameParameter.Items[i] as TFrameParameter).CompositeType>99 then
      begin
        (FFrameParameter.Items[i] as TFrameParameter).FChildren.FillParameterList(ASourceParams, AFrameID,(FFrameParameter.Items[i] as TFrameParameter).ParentFrameParam);
      end;
  except
     on E: Exception do
    ShowExceptionForm(sParameterError, E.Message);
  end;
end;

function TFrameParameterList.GetCount: Integer;
begin
  result := FFrameParameter.Count;
end;

function TFrameParameterList.GetItem(AName: String): TFrameParameter;
var
  i:Integer;
begin
  Result:=Nil;
  for i := 0 to FFrameParameter.Count - 1 do
  begin
    if (FFrameParameter.Items[i] as TFrameParameter).Name=AName then
      Result := (FFrameParameter.Items[i] as TFrameParameter);
  end;


end;

function TFrameParameterList.GetValueByName(AName: String): Variant;
var
  i:Integer;
begin
  for i := 0 to FFrameParameter.Count - 1 do
    if (FFrameParameter.Items[i] as TFrameParameter).Name=AName then
      Result := (FFrameParameter.Items[i] as TFrameParameter).Value;
end;

initialization

finalization



end.
