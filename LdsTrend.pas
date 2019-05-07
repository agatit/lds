unit LdsTrend;

interface

uses
  Winapi.Windows, System.Types, System.SysUtils, System.Classes,
  System.Math, DateUtils, ProfilerDataModule, AppLogs, ComObj,
  System.SyncObjs, System.Generics.Defaults, System.Generics.Collections;

const
  RawNaN = -$8000;
  CacheSize = 5000; //chunks
  CacheInc = 5000; //chunks
  WritePeriod = 2000; //ms
  WriteCacheSize = 3;
  ChunkSize = 100;  //nie rusz bo ci łapa uschnie!
  UpdateDelay = 10; //sek. - opóżnienie odświezenia przy braku danych w bazie
  //const NaN = 0.0 / 0.0;

type
  TTrendValue =  Int16;

  PTrendChunkData = ^TTrendChunkData;
  TTrendChunkData = array[0..ChunkSize-1] of TTrendValue;

  PDoubleArray = ^TDoubleArray;
  TDoubleArray = array[0..CacheSize*ChunkSize-1] of Double;

  TTrendChunk = record
    Data: TTrendChunkData;
    Time: LongWord;
    Changed: Boolean;
    Saved: Boolean;
    LastSample: ShortInt;
  end;

  TSampleIndex = record
    Chunk: LongWord;
    Sample: Word;
  end;

  TTrend = class
  private
    FName: String;
    FSIUnit: String;
  protected
    FScale: Double;
    FScaledMax: double;
    FTrendDef: Integer;
    FTimeExponent: Integer;
    FSampleTime: TDateTime;
    FScaledMin: double;
    FRawMin: TTrendValue;
    FRawMax: TTrendValue;

    FChunkSampleTime: TDateTime;
    FChunkMult: Integer;
    FCache: array [0..CacheSize-1] of TTrendChunk;

    FFirst: LongWord;
    FLast: LongWord;

    FFirstAttempt: LongWord;
    FLastAttempt: LongWord;
    FNextUpdate : TDateTime;

    FUpdateLock: TCriticalSection;

    procedure SetTimeExponent(const Value: Integer);
    procedure SetScaledMax(const Value: double);
    procedure SetScaledMin(const Value: double);
    procedure SetRawMin(const Value: TTrendValue);
    procedure SetRawMax(const Value: TTrendValue);
    function GetCacheSize: Cardinal; virtual; abstract;

    procedure CleanChunk(var AChunk: TTrendChunk); overload;
    procedure CleanChunk(AOffset: Integer); overload;

    function LogEvent(AVerbosityLevel : TVerbosityLevel; AMessage : string): string;

  public
    AppLogs: TAppLogs;

    function RescaleValue(AValue: TTrendValue): Double; overload; //inline;

    property ScaledMax: double read FScaledMax write SetScaledMax;
    property TrendDef: Integer read FTrendDef;
    property SampleTime: TDateTime read FSampleTime write FSampleTime;
    property ScaledMin: double read FScaledMin write SetScaledMin;
    property RawMin: TTrendValue read FRawMin write SetRawMin;
    property RawMax: TTrendValue read FRawMax write SetRawMax;
    property ChunkSampleTime: TDateTime read FChunkSampleTime
      write FChunkSampleTime;
    property TimeExponent: Integer read FTimeExponent write SetTimeExponent;
    property Name: String read FName write FName;
    property SIUnit: String read FSIUnit write FSIUnit;
    property CacheSize: Cardinal read GetCacheSize;

    function GetValue(const ATime: TDateTime; CacheRead: Boolean = False): Double; overload; virtual;
    function GetValue(const AIndex: TSampleIndex; CacheRead: Boolean = False): Double; overload; virtual;
    procedure GetValueEx( AStartTime, AEndTime: TDateTime; var FirstVal, LastValue, MaxValue, MinValue: Double; CacheRead: Boolean = False);
    function GetRawValue(const AIndex: TSampleIndex; CacheRead: Boolean = False): TTrendValue; virtual;

    procedure GetDataBlock(var AData: array of Double; const ATime: TDateTime; const ACount: Int64); overload; virtual;
    procedure GetDataBlock(var AData: array of Double; const AFirst: Cardinal; const ALast: Cardinal); overload; virtual;
    procedure GetDataCache(var AData: array of Double); virtual;
    procedure UpdateCache(ANew: TSampleIndex; AForce: Boolean = False); overload; virtual; abstract;
    procedure UpdateCache(var AFirst, ALast: Cardinal); overload; virtual; abstract;
    procedure ClearCache;
    function DateTimeToIndex(const ATime: TDateTime): TSampleIndex;
    function IndexToDateTime(const ASampleIndex: TSampleIndex): TDateTime;
    procedure IncIndex(var ASampleIndex: TSampleIndex;
      AIncerement: Word = 1); inline;
    procedure DecIndex(var ASampleIndex: TSampleIndex);
    function MoveIndex(const ASampleIndex: TSampleIndex; ACount: Int64)
      : TSampleIndex;
    function DiffIndex(const ASampleIndex1: TSampleIndex;
      const ASampleIndex2: TSampleIndex): Int64;

    constructor Create(); virtual;
    destructor Destroy(); override;

  end;

implementation

{ TTrend }

procedure TTrend.SetScaledMax(const Value: double);
begin
  FScaledMax := Value;
  FScale := (FScaledMax - FScaledMin) / (FRawMax - FRawMin);
end;

procedure TTrend.SetScaledMin(const Value: double);
begin
  FScaledMin := Value;
  FScale := (FScaledMax - FScaledMin) / (FRawMax - FRawMin);
end;

procedure TTrend.SetRawMin(const Value: TTrendValue);
begin
  FRawMin := Value;
  FScale := (FScaledMax - FScaledMin) / (FRawMax - FRawMin);
end;

procedure TTrend.SetRawMax(const Value: TTrendValue);
begin
  FRawMax := Value;
  FScale := (FScaledMax - FScaledMin) / (FRawMax - FRawMin);
end;

function TTrend.GetValue(const ATime: TDateTime; CacheRead: Boolean): Double;
var
  i1,i2: TSampleIndex;
  t1, t2: TDateTime;
begin
  //interpolacja
  i1 := DateTimeToIndex(ATime);
  i2 := i1;
  IncIndex(i2);
  t1 := IndexToDateTime(i1);
  t2 := t1+SampleTime;

  Result := (GetValue(i1, CacheRead)*(t2-ATime) + GetValue(i2, CacheRead)*(ATime-t1))/SampleTime;
end;

function TTrend.RescaleValue(AValue: TTrendValue): Double;
begin
  if AValue = RawNaN then
    Result := NaN
  else
    Result := (AValue - FRawMin) * FScale + FScaledMin;
end;

function TTrend.LogEvent(AVerbosityLevel: TVerbosityLevel;
  AMessage: string): string;
begin
  if Assigned(AppLogs) then
    AppLogs.LogEvent(AVerbosityLevel, AMessage);
end;

procedure TTrend.GetDataBlock(var AData: array of Double;
  const ATime: TDateTime; const ACount: Int64);
var
  index: TSampleIndex;
  value: Double;
  i: integer;
begin
  index := DateTimeToIndex(ATime);
  for i := 0 to ACount-1 do
  begin
    value := GetValue(index);
    AData[i] := value;
    IncIndex(index);
  end;
end;

procedure TTrend.GetDataBlock(var AData: array of Double; const AFirst: Cardinal; const ALast: Cardinal);
var
  value: Double;
  i, j: Cardinal;
begin
  for i := AFirst to ALast do
    for j := 0 to ChunkSize-1 do
    begin
      value :=  RescaleValue(FCache[i-FFirst].Data[j]);  //NIE JEST OGÓLNE, zadziała tylko dla TDBTrend !!!
      AData[ChunkSize*(i-AFirst) + j] := value;
    end;
end;

procedure TTrend.GetDataCache(var AData: array of Double);
var
  value: Double;
  i, j: Cardinal;
begin
  for i := 0 to FLast-FFirst do
    for j := 0 to ChunkSize-1 do
    begin
      value :=  RescaleValue(FCache[i].Data[j]);  //NIE JEST OGÓLNE, zadziała tylko dla TDBTrend !!!
      AData[ChunkSize*i + j] := value;
    end;
end;

function TTrend.GetRawValue(const AIndex: TSampleIndex; CacheRead: Boolean): TTrendValue;
var
  i: Integer;
begin
  if not CacheRead then
    UpdateCache(AIndex);
  // pobranie
  if (FFirst <= AIndex.Chunk) and (AIndex.Chunk <= FLast) then
    Result := FCache[AIndex.Chunk - FFirst].Data[AIndex.Sample]
  else
    Result := RawNaN; // nie ma wartości w BD
end;

function TTrend.GetValue(const AIndex: TSampleIndex; CacheRead: Boolean): Double;
var
  i: Integer;
begin
  if not CacheRead then
    UpdateCache(AIndex);
  // pobranie
  if (FFirst <= AIndex.Chunk) and (AIndex.Chunk <= FLast) then
    Result := RescaleValue(FCache[AIndex.Chunk - FFirst].Data[AIndex.Sample])
  else
    Result := NaN; // nie ma wartości w BD
end;


procedure TTrend.GetValueEx(AStartTime, AEndTime: TDateTime;
  var FirstVal, LastValue, MaxValue, MinValue: Double; CacheRead: Boolean);
var
  StartIndex, EndIndex, CurrentIndex: TSampleIndex;
  CurrentChunk: LongWord;
  CurrentSample, MaxSample: byte;
  v, val: Double;
  First: Boolean;
  tmpDate: TDateTime;
  i, SampleCount: Int64;
begin
  First := True;
  if (AStartTime>AEndTime) then
  begin
     tmpDate:=AEndTime;
     AEndTime:=AStartTime;
     AStartTime:=tmpDate;
  end;

  StartIndex := DateTimeToIndex(AStartTime);
  EndIndex := DateTimeToIndex(AEndTime);
  if (DiffIndex(EndIndex, StartIndex)>0) then
    DecIndex(EndIndex);
  SampleCount:=DiffIndex(EndIndex, StartIndex);
  val:=GetValue(StartIndex, CacheRead);

  FirstVal := val;
  LastValue := val;
  MinValue := val;
  MaxValue := val;

  i:=1;
  while (i<=SampleCount) do
  begin
    IncIndex(StartIndex);
    val := GetValue(StartIndex, CacheRead);
    if not IsNan(val) then
    begin
      if IsNan(FirstVal) then
      begin
        FirstVal:=val;
        MinValue:=val;
        MaxValue:=val;
      end;
      if val < MinValue then
        MinValue := val;
      if val > MaxValue then
        MaxValue := val;
      LastValue := val;
    end;
    Inc(i);
  end;
end;

//zbezczeszczona wersja procedury :)
{
procedure TTrend.GetValueEx(AStartTime, AEndTime: TDateTime;
  var FirstVal, LastValue, MaxValue, MinValue: Double; CacheRead: Boolean);
var
  i: Integer;
  StartIndex, EndIndex, CurrentIndex: TSampleIndex;
  val, last: Double;
begin
  FirstVal := GetValue(AStartTime, CacheRead);
  LastValue := GetValue(AEndTime, CacheRead);

  StartIndex := DateTimeToIndex(AStartTime);
  EndIndex := DateTimeToIndex(AEndTime);
  IncIndex(StartIndex);
  CurrentIndex := StartIndex;

  MinValue := NaN;
  MaxValue := NaN;

  for i := 0 to DiffIndex(StartIndex, EndIndex)-1 do
  begin
    val := GetValue(CurrentIndex, CacheRead);
    if not IsNaN(val) then
    begin
      if IsNaN(MaxValue) or (val > MaxValue) then
        MaxValue := val;
      if IsNaN(MinValue) or (val < MinValue) then
        MinValue := val;
      if IsNaN(FirstVal) then
        FirstVal := val;
      last := val;
    end;
    IncIndex(CurrentIndex);
  end;
  if IsNaN(LastValue) then
    LastValue := last;
end;         }



procedure TTrend.ClearCache;
begin
  FFirst := 0;
  FLast := 0;
end;

constructor TTrend.Create();
begin
  FFirst := 0;
  FLast := 0;

  FNextUpdate := 0;
  FFirstAttempt := 0;
  FLastAttempt := 0;

  FUpdateLock := TCriticalSection.Create;
end;

procedure TTrend.SetTimeExponent(const Value: Integer);
begin
  FTimeExponent := Value;
  FSampleTime := IntPower(10, FTimeExponent - 2) / 86400;
  FChunkSampleTime := IntPower(10, FTimeExponent) / 86400;
  FChunkMult := Round(IntPower(10, FTimeExponent));
  LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) + '> FSampleTime: ' +
    FloatToStr(FSampleTime) + ' FChunkSampleTime: ' +
    FloatToStr(FChunkSampleTime));
end;

function TTrend.DateTimeToIndex(const ATime: TDateTime): TSampleIndex;
begin
  Result.Chunk := Floor((ATime - UnixDateDelta) / FChunkSampleTime);
  Result.Sample := Floor((ATime - UnixDateDelta - FChunkSampleTime *
    Result.Chunk) / FSampleTime);
end;

function TTrend.IndexToDateTime(const ASampleIndex: TSampleIndex): TDateTime;
begin
  Result := UnixDateDelta + FChunkSampleTime * ASampleIndex.Chunk + FSampleTime
    * ASampleIndex.Sample
end;

procedure TTrend.IncIndex(var ASampleIndex: TSampleIndex;
  AIncerement: Word = 1);
begin
  Inc(ASampleIndex.Sample, AIncerement);
  while ASampleIndex.Sample >= ChunkSize do
  begin
    Inc(ASampleIndex.Chunk);
    Dec(ASampleIndex.Sample, ChunkSize);
  end;
end;

procedure TTrend.DecIndex(var ASampleIndex: TSampleIndex);
begin
  if (ASampleIndex.Sample = 0) then
  begin
    Dec(ASampleIndex.Chunk);
    ASampleIndex.Sample := ChunkSize - 1;
  end
  else
  begin
    Dec(ASampleIndex.Sample);
  end;
end;

destructor TTrend.Destroy;
begin
  inherited;
end;

function TTrend.MoveIndex(const ASampleIndex: TSampleIndex; ACount: Int64)
  : TSampleIndex;
var
  res, rem: LongInt;
begin
  // potrzebny jest mod zwracający zawsze wartość dodatnią. Pascal go nie ma, więc liczę ręcznie:
  res := (ACount + ASampleIndex.Sample) div ChunkSize;
  rem := ACount + ASampleIndex.Sample - res * ChunkSize;
  // zgaduje że szybsze od mod
  if rem < 0 then
  begin
    Dec(res);
    rem := ChunkSize + rem;
  end;
  Result.Chunk := ASampleIndex.Chunk + res;
  Result.Sample := rem;
end;

function TTrend.DiffIndex(const ASampleIndex1: TSampleIndex;
  const ASampleIndex2: TSampleIndex): Int64;
begin
  Result := (ASampleIndex1.Chunk - ASampleIndex2.Chunk) * ChunkSize +
    (ASampleIndex1.Sample - ASampleIndex2.Sample)
end;


procedure TTrend.CleanChunk(var AChunk: TTrendChunk);
var
  i: Integer;
begin
  with AChunk do
  begin
    Changed := False;
    //FillChar(Data, SizeOf(TTrendChunkData), $FF);
    for i := 0 to ChunkSize-1 do
      Data[i] := RawNaN;
    Saved := False;
    LastSample := -1;
  end;
end;


procedure TTrend.CleanChunk(AOffset: Integer);
begin
  CleanChunk(FCache[AOffset]);
end;

end.
