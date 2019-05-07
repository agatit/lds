unit LdsTrendDB;

interface

uses
  Winapi.Windows, System.Types, System.SysUtils, System.Classes,
  System.Math, DateUtils,
  Data.DB, MemDS, DBAccess, MSAccess,
  LdsTrend, AppLogs;

type
  TTrendDB = class(TTrend)
  private
    FId: Integer;
    FData: TList;
    FPortNo: Integer;
    FHostName: String;
    FSlaveID: Integer;
    FBeginAddr: Word;
    FConnection: TMSConnection;
    // FQuery: TMSQuery;
    FDBCache: Array [0 .. CacheSize - 1] of TTrendChunk;
    // tymczasowy do ³adowania z BD
    FWriteCache: Array [0 .. WriteCacheSize] of TTrendChunk; // cache do zapisu
    FWriteIndex: LongWord;
    FLastWrite: Cardinal;
    sqlSaveChunk: TMSSQL;
    qryQuickTrends: TMSQuery;
  protected
    function GetCacheSize: Cardinal; override;
  public
    property HostName: String read FHostName write FHostName;
    property PortNo: Integer read FPortNo write FPortNo;
    property SlaveID: Integer read FSlaveID write FSlaveID;
    property BeginAddr: Word read FBeginAddr write FBeginAddr;
    constructor Create(ATrendDef: Integer; AServer, ADatabase, AUsername,
      APassword: String); overload;
    constructor Create(ATrendDef: Integer; AConnection: TMSConnection);
      overload;
    destructor Destroy;
    // procedure GetDataBlock(var AData: array of Double; const ATime: TDateTime; const ACount: Int64); override;
    procedure UpdateCache(ANew: TSampleIndex; AForce: Boolean = False);
      override;
    procedure UpdateCache(var AFirst, ALast: Cardinal); override;
    procedure SetRawValue(const AIndex: TSampleIndex;
      const AValue: TTrendValue);
  end;

implementation

constructor TTrendDB.Create(ATrendDef: Integer; AServer, ADatabase, AUsername,
  APassword: String);
begin
  FConnection := TMSConnection.Create(nil);
  FConnection.Server := AServer;
  FConnection.Database := ADatabase;
  FConnection.Username := AUsername;
  FConnection.Password := APassword;
  FConnection.LoginPrompt := False;
  Create(ATrendDef, FConnection);
end;

constructor TTrendDB.Create(ATrendDef: Integer; AConnection: TMSConnection);
var
  i: Integer;
begin
  inherited Create();
  FConnection := AConnection;
  FTrendDef := ATrendDef;
  // parametry domyslne
  SetTimeExponent(0);
  FRawMin := -32768;
  FRawMax := 32767;
  FScaledMin := -1;
  FScaledMax := 1;
  FHostName := 'localhost';
  FPortNo := 502;
  FSlaveID := 1;
  FBeginAddr := 0;
  FWriteIndex := 0;
  // FillChar(FWriteCache, SizeOf(TTrendChunkData), $FF);
  for i := 0 to Length(FWriteCache) - 1 do
    CleanChunk(FWriteCache[i]);
  sqlSaveChunk := TMSSQL.Create(nil);
  sqlSaveChunk.SQL.Text := 'MERGE QUICK_TRENDS target  ' +
    'USING (SELECT :TREND_DEF_ID, :TIME, :DATA) AS source (TREND_DEF_ID, TIME, DATA)   '
    + 'ON target.TIME = source.TIME and target.TREND_DEF_ID = source.TREND_DEF_ID    '
    + 'WHEN MATCHED THEN UPDATE SET DATA = :DATA     ' +
    'WHEN NOT MATCHED THEN INSERT(TREND_DEF_ID, TIME, DATA)    ' +
    'VALUES(:TREND_DEF_ID, :TIME, :DATA);   ';
  sqlSaveChunk.Params.Items[0].DataType := ftInteger;
  sqlSaveChunk.Params.Items[0].ParamType := ptInput;
  sqlSaveChunk.Params.Items[1].DataType := ftLargeint;
  sqlSaveChunk.Params.Items[1].ParamType := ptInput;
  sqlSaveChunk.Params.Items[2].DataType := ftBytes;
  sqlSaveChunk.Params.Items[2].ParamType := ptInput;
  sqlSaveChunk.Connection := FConnection;
  qryQuickTrends := TMSQuery.Create(nil);
  qryQuickTrends.SQL.Text := 'SELECT             ' + '  TREND_DEF_ID     ' +
    '  ,TIME            ' + '  ,DATA            ' + 'FROM               ' +
    '  QUICK_TRENDS     ' + 'ORDER BY TIME      ';
  qryQuickTrends.Connection := FConnection;
  for i := 0 to CacheSize - 1 do
    CleanChunk(i);
end;

destructor TTrendDB.Destroy;
begin
  sqlSaveChunk.Free;
  FUpdateLock.Free;
end;

function TTrendDB.GetCacheSize: Cardinal;
begin
  Result := LdsTrend.CacheSize;
end;

procedure TTrendDB.SetRawValue(const AIndex: TSampleIndex;
  const AValue: TTrendValue);
  procedure WriteBuffer;
  var
    data: String;
    i: Integer;
  begin
    with sqlSaveChunk do
    begin
      ParamByName('TREND_DEF_ID').Value := FTrendDef;
      ParamByName('TIME').Value := FWriteIndex * FChunkMult; // ?????
      ParamByName('DATA').SetBlobData(@FWriteCache[0].data,
        100 * SizeOf(TTrendValue));
      Execute;
      FLastWrite := GetTickCount;
      data := '';
      for i := 0 to 99 do
        data := data + IntToStr(FWriteCache[0].data[i]) + ' ';
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) + '> save to database ' +
        IntToStr(FWriteIndex) + ' : ' + data);
    end;
  end;

var
  i: Integer;
  msg: String;
begin
  try
    if FWriteIndex = 0 then // pierwszy raz
    begin
      FWriteIndex := AIndex.Chunk;
      FLastWrite := GetTickCount;
      // FillChar(FWriteCache[0].data, SizeOf(TTrendChunkData), $FF);
      CleanChunk(FWriteCache[0]);
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) + '> start writing at ' +
        IntToStr(FWriteIndex));
    end;
    if AIndex.Chunk > FWriteIndex then
    begin
      WriteBuffer;
      // logowanie - sprawdzenie czy by³ komplet
      if AIndex.Chunk > FWriteIndex + 1 then
        LogEvent(vlWarning, 'Trend ' + IntToStr(FTrendDef) + '> New. Chunks ' +
          IntToStr(FWriteIndex + 1) + ' to ' + IntToStr(AIndex.Chunk - 1) +
          ' skipped');
      msg := '';
      for i := 0 to ChunkSize - 1 do
        if FWriteCache[0].data[i] = RawNaN then
        begin
          msg := msg + IntToStr(i) + ' ';
        end;
      if msg = '' then
        LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) + '> New ' +
          IntToStr(AIndex.Chunk) + ' Write chunk: ' + IntToStr(FWriteIndex) +
          ' complete')
      else
        LogEvent(vlWarning, 'Trend ' + IntToStr(FTrendDef) + '> New ' +
          IntToStr(AIndex.Chunk) + ' Write chunk: ' + IntToStr(FWriteIndex) +
          ' skipped: ' + msg);
      // FillChar(FWriteCache[0].data, SizeOf(TTrendChunkData), $FF);
      CleanChunk(FWriteCache[0]);
      FWriteIndex := AIndex.Chunk;
    end;
    if AIndex.Chunk = FWriteIndex then
    begin
      FWriteCache[0].data[AIndex.Sample] := AValue;
      if GetTickCount - FLastWrite > WritePeriod then
        WriteBuffer;
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) + '> Rewrite chunk: ' +
        IntToStr(FWriteIndex) + ' complete')
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('TTrendDB.SetRawValue: ' + e.Message);
    end;
  end;
end;

procedure TTrendDB.UpdateCache(var AFirst, ALast: Cardinal);
var
  i, j: Integer;
  exp_first, exp_last: LongWord; // nowy przedzia³ oczekiwany
  db_first, db_last: LongWord; // przedzia³ do pobrania z BD
  tmp_first, tmp_last: LongWord; // przedzia³ który uda³o siê pobraæ

  function ReadFromDB: Boolean;
  var
    i: Integer;
  begin
    // ³adowanie z bazy do tymczasowego FTmpCache
    qryQuickTrends.FilterSQL := 'TREND_DEF_ID = ' + IntToStr(FTrendDef) +
      ' and TIME >= ' + IntToStr(db_first * FChunkMult) + ' and TIME <= ' +
      IntToStr(db_last * FChunkMult);
    tmp_first := db_last;
    tmp_last := db_first;
    qryQuickTrends.Open;
    try
      qryQuickTrends.First;
      for i := db_first to db_last do
        if not qryQuickTrends.Eof and
          (qryQuickTrends.FieldByName('TIME').AsInteger = i * FChunkMult) then
        begin
          qryQuickTrends.FieldByName('DATA')
            .GetData(@FDBCache[i - db_first].data);
          FDBCache[i - db_first].Changed := False;
          qryQuickTrends.Next;
          tmp_first := min(tmp_first, i);
          tmp_last := max(tmp_last, i);
        end
        else
          // FillChar(FDBCache[i - db_first].Data, SizeOf(TTrendChunkData), $FF);
          CleanChunk(FDBCache[i - db_first]);
    finally
      qryQuickTrends.Close;
    end;
    // ??????
    if (tmp_first <> db_first) OR (tmp_last <> db_last) then
    // brak danych w bazie
    begin
      FNextUpdate := Now + UpdateDelay * OneSecond;
      FFirstAttempt := db_first;
      FLastAttempt := db_last;
    end;
    Result := tmp_first <= tmp_last;
  end;

begin
  FUpdateLock.Enter;
  try
    try
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) +
        '> Cache updated Request: ' + ' (' + IntToStr(AFirst) + '..' +
        IntToStr(ALast) + ') ' + IntToStr(ALast - AFirst));
      if (ALast - AFirst) > CacheSize - 1 then
        raise Exception.Create('Required range exceeds cache size');
      exp_first := AFirst;
      exp_last := ALast;
      // jeœli aby po³¹czyæ przedzia³y musimy do³adowaæ mniej i¿ zachowamy - rozsez przedzia³  (do uproszenia warunek!)
      if (exp_last < FFirst) and (exp_last + (FLast - FFirst) >= FFirst) and
        (FFirst - exp_first < CacheSize) then
        exp_last := FFirst - 1;
      if (exp_first > FLast) and (exp_first - (FLast - FFirst) <= FLast) and
        (exp_last - FLast < CacheSize) then
        exp_first := FLast + 1;
      // nowy przedzia³ wewn¹trz cache'u
      if (FFirst <= exp_first) and (exp_last < FLast) then
      begin
        exit; // nie robimy nic
      end
      // nowy przedzia³ nachodz¹cy z prawej strony
      else if (FFirst <= exp_first) and (exp_first <= FLast + 1) then
      begin
        db_first := max(FLast, exp_last - CacheSize + 1);
        // by³o FLast + 1 ale odejmuje jeden aby zawsze aktualizawoac ostatin element cache
        db_last := exp_last;
        if ReadFromDB then
        begin
          exp_first := max(FFirst, tmp_last - CacheSize + 1);
          // korekata - nie zmniejszamy cache
          // przesuwanie
          if exp_first <> FFirst then
            for i := exp_first to db_first - 1 do
              FCache[i - exp_first] := FCache[i - FFirst];
          // czyszczenie dziury - dane o które pytaliœmy ale nie ma ich w bazie
          for i := db_first to tmp_first - 1 do
            CleanChunk(i - exp_first);
          // kopiowanie z bd
          for i := tmp_first to tmp_last do
            FCache[i - exp_first] := FDBCache[i - db_first];
          FFirst := exp_first;
          FLast := tmp_last;
        end;
        ALast := min(ALast, FLast); // zmniejszy przedzia³ gdy brak danych
      end
      // nowy przedzia³ nachodz¹cy z lewej strony
      else if (FFirst - 1 <= exp_last) and (exp_last <= FLast) then
      begin
        db_first := exp_first;
        db_last := FFirst - 1;
        if ReadFromDB then
        begin
          exp_last := min(FLast, tmp_first + CacheSize - 1);
          // korekata - nie zmniejszamy cache
          // przesuwanie
          if tmp_first <> FFirst then
            for i := exp_last downto FFirst do
              FCache[i - tmp_first] := FCache[i - FFirst];
          // czyszczenie dziury
          for i := tmp_last + 1 to db_last do
            CleanChunk(i - tmp_first);
          // kopiowanie z bd
          for i := tmp_first to tmp_last do
            FCache[i - tmp_first] := FDBCache[i - db_first];
          FFirst := tmp_first;
          FLast := exp_last;
        end;
        AFirst := max(AFirst, FFirst); // zmniejszy przedzia³ gdy brak danych
      end
      // przedzia³y s¹ roz³¹czne
      else
      begin
        db_first := exp_first;
        db_last := exp_last;
        if ReadFromDB then
        begin
          // koiowanie z bd
          for i := tmp_first to tmp_last do
            FCache[i - tmp_first] := FDBCache[i - db_first];
          FFirst := tmp_first;
          FLast := tmp_last;
          AFirst := max(AFirst, FFirst); // zmniejszy przedzia³ gdy brak danych
          ALast := min(ALast, FLast);
        end
        else
        begin
          AFirst := 1; // b³êdna watoœæ - nie ma co zwróciæ
          ALast := 0;
        end;
      end;
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) +
        '> Cache updated  Return: ' + ' (' + IntToStr(AFirst) + '..' +
        IntToStr(ALast) + ') ' + IntToStr(ALast - AFirst));
      LogEvent(vlDebug, 'Trend ' + IntToStr(FTrendDef) +
        '> Cache updated   Cache: ' + ' (' + IntToStr(FFirst) + '..' +
        IntToStr(FLast) + ') ' + IntToStr(FLast - FFirst));
    except
      on e: Exception do
      begin
        raise Exception.Create('TTrendDB.UpdateCache(1): ' + e.Message);
      end;
    end;
  finally
    FUpdateLock.Leave;
  end;
end;

procedure TTrendDB.UpdateCache(ANew: TSampleIndex; AForce: Boolean);
var
  exp_first, exp_last: Cardinal; // nowy przedzia³ oczekiwany
begin
  try
    if AForce or (((ANew.Chunk < FFirst) or (FLast < ANew.Chunk) or
      ((FLast = ANew.Chunk) and (FCache[ANew.Chunk - FFirst].data[ANew.Sample]
      = RawNaN))) and ((ANew.Chunk < FFirstAttempt) or
      (FLastAttempt < ANew.Chunk) or (FNextUpdate < Now))) then
    begin
      // wyliczenie oczekiwanego przedzia³u
      exp_first := ANew.Chunk - (CacheInc div 2);
      exp_last := exp_first + CacheInc - 1;
      UpdateCache(exp_first, exp_last);
    end
  except
    on e: Exception do
    begin
      raise Exception.Create('TTrendDB.UpdateCache(2): ' + e.Message);
    end;
  end;
end;

end.
