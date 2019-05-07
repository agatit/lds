unit LdsTrendCalc;

interface

uses
  Winapi.Windows, System.Types, System.SysUtils, System.Classes, Vcl.Forms,
  System.Math, DateUtils,
  LdsTrend, CL, AppLogs;

type
  TTrendCalc = class(TTrend)
  private
    FCLContext: cl_context;
    FCLSegmentProgram: cl_program;
    FCLDerivativeKernel: cl_kernel;
    FCLQueue: cl_command_queue;
    FCLDevice: cl_device_id;
    FTrend: TTrend;
    FWindow: Word;
    FCalcCache: TDoubleArray;
    Calculate: procedure(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer) of object;
    procedure CalculateCL(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer);
      virtual; abstract;
    procedure CalculateCPU(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer);
      virtual; abstract;
    procedure SetCLContext(const Value: cl_context);
    procedure SetCLDevice(const Value: cl_device_id);
    procedure SetupCL;
    procedure SetWindow(const Value: Word);
  protected
    function GetCacheSize: Cardinal; override;
  public
    property CLContext: cl_context read FCLContext write SetCLContext;
    property CLDevice: cl_device_id read FCLDevice write SetCLDevice;
    property Window: Word read FWindow write SetWindow;
    constructor Create(ATrendDef: Integer; ATrend: TTrend;
      AWindow: Word); virtual;
    function GetRawValue(const AIndex: TSampleIndex; CacheRead: Boolean = False)
      : TTrendValue; override;
    function GetValue(const AIndex: TSampleIndex; CacheRead: Boolean = False)
      : Double; overload; override;
    procedure UpdateCache(ANew: TSampleIndex; AForce: Boolean = False);
      override;
    procedure UpdateCache(var AFirst, ALast: Cardinal); override;
    //procedure UpdateCache_bak(var AFirst, ALast: Cardinal); override;
  end;

  TTrendMean = class(TTrendCalc)
  private
    procedure CalculateCL(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer); override;
    procedure CalculateCPU(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer); override;
  end;

  TTrendDeriv = class(TTrendCalc)
  private
    procedure CalculateCL(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer); override;
    procedure CalculateCPU(var AIn: array of Double; var AOut: array of Double;
      ACount, AFilterWindow, AFilterStep, AInterleave: Integer); override;
  end;

implementation

constructor TTrendCalc.Create(ATrendDef: Integer; ATrend: TTrend;
  AWindow: Word);
begin
  inherited Create();
  FTrend := ATrend;
  FTrendDef := ATrendDef;
  FWindow := AWindow;
  FCLContext := nil;
  FCLSegmentProgram := nil;
  FCLDerivativeKernel := nil;
  FCLQueue := nil;
  FCLDevice := nil;
  FCLContext := nil;

  // FChunkSampleTime := FTrend.FChunkSampleTime; //?????
  // FSampleTime := FTrend.SampleTime; //?????
  Calculate := CalculateCPU;
end;

procedure TTrendCalc.SetCLContext(const Value: cl_context);
begin
  FCLContext := Value;
  SetupCL;
end;

procedure TTrendCalc.SetCLDevice(const Value: cl_device_id);
begin
  FCLDevice := Value;
  SetupCL;
end;

procedure TTrendCalc.SetupCL;
  function convertToString(const Filename: AnsiString): AnsiString;
  begin
    with TFileStream.Create(IncludeTrailingPathDelimiter
      (ExtractFilePath(Application.ExeName)) + Filename, fmOpenRead or
      fmShareDenyWrite) do
      try
        SetLength(Result, Size);
        if Size > 0 then
          Read(Result[1], Size);
      finally
        Free;
      end;
  end;

var
  i: Integer;
  sourceStr: AnsiString;
  sourceSize: size_t;
  sourcePAnsiChar: PAnsiChar;
  s, error_string: AnsiString;
  returned_size: size_t;
  errcode_ret: cl_int; // error code returned from api calls
begin
  if Assigned(FCLDevice) and Assigned(FCLContext) then
  begin
    // Create OpenCL program with source code
    sourceStr := convertToString('SegmentCalculations.cl');
    sourceSize := Length(sourceStr);
    sourcePAnsiChar := PAnsiChar(sourceStr);
    FCLSegmentProgram := clCreateProgramWithSource(FCLContext, 1,
      @sourcePAnsiChar, @sourceSize, @errcode_ret);
    if errcode_ret <> CL_SUCCESS then
    begin
      raise Exception.Create('clCreateProgramWithSource: ' +
        IntToStr(errcode_ret));
    end;
    // Build the program (OpenCL JIT compilation)
    errcode_ret := clBuildProgram(FCLSegmentProgram, 1, @FCLDevice, nil,
      nil, nil);
    if errcode_ret <> CL_SUCCESS then
    begin
      clGetProgramBuildInfo(FCLSegmentProgram, FCLDevice, CL_PROGRAM_BUILD_LOG,
        0, nil, @returned_size);
      SetLength(s, returned_size + 2);
      clGetProgramBuildInfo(FCLSegmentProgram, FCLDevice, CL_PROGRAM_BUILD_LOG,
        Length(s), PAnsiChar(s), @returned_size);
      SetLength(s, Min(Pos(#0, s) - 1, returned_size - 1));
      raise Exception.Create('clBuildProgram: ' + s);
    end;
    // Create a handle to the compiled OpenCL function (Kernel)
    FCLDerivativeKernel := clCreateKernel(FCLSegmentProgram,
      PAnsiChar('FilterDerivative'), @errcode_ret);
    if errcode_ret <> CL_SUCCESS then
    begin
      raise Exception.Create('clCreateKernel: ' + IntToStr(errcode_ret));
    end;
    // Create a command-queue on the first CPU or GPU device
    FCLQueue := clCreateCommandQueue(FCLContext, FCLDevice, 0, @errcode_ret);
    if errcode_ret <> CL_SUCCESS then
    begin
      raise Exception.Create('clCreateCommandQueue: ' + IntToStr(errcode_ret));
    end;
    Calculate := CalculateCL;
  end
  else
    Calculate := CalculateCPU;
end;

procedure TTrendCalc.SetWindow(const Value: Word);
begin
  FWindow := Value;
  // UpdateCache((FLast+FFirst) div 2);   ROZWA¯YÆ REAFAKTORING!
end;

function TTrendCalc.GetCacheSize: Cardinal;
var
  sample_mult: Integer;
begin
  // Result := LdsTrend.CacheSize - (FWindow div ChunkSize + 1);
  sample_mult := Round(IntPower(10, (TimeExponent - FTrend.TimeExponent)));
  Result := (CacheInc div sample_mult) - 1 - (FWindow div ChunkSize div 2 + 1) -
    (FWindow div ChunkSize div 2 + 1);
end;

function TTrendCalc.GetRawValue(const AIndex: TSampleIndex; CacheRead: Boolean)
  : TTrendValue;
begin
  Result := RawNaN;
end;

function TTrendCalc.GetValue(const AIndex: TSampleIndex;
  CacheRead: Boolean): Double;
var
  i: Integer;
  tmp_index: TSampleIndex;
begin
  if not CacheRead then
    UpdateCache(AIndex);
  // pobranie
  if (FFirst <= AIndex.Chunk) and (AIndex.Chunk <= FLast) then
    Result := FCalcCache[(AIndex.Chunk - FFirst) * ChunkSize + AIndex.Sample]
  else
    Result := NaN; // nie ma wartoœci w BD
end;

procedure TTrendCalc.UpdateCache(var AFirst, ALast: Cardinal);
var
  i: Integer;
  exp_first, exp_last: LongWord;
  first_index, last_index: TSampleIndex;
  tmp_in: array of Double;
  tmp_out: array of Double;
  tmp_cache: PDoubleArray;
  sample_mult: Integer;
  offset: Integer;
begin
  FUpdateLock.Enter;
  try
    try
      LogEvent(vlDebug, 'CalcTrend ' + IntToStr(FTrendDef) +
        '> Cache updated Request: ' + ' (' + IntToStr(AFirst) + '..' +
        IntToStr(ALast) + ') ' + IntToStr(ALast - AFirst));
      if (ALast - AFirst) > CacheSize then
        raise Exception.Create('Required range exceeds cache size');
      sample_mult := Round(IntPower(10, (TimeExponent - FTrend.TimeExponent)));
      first_index.Chunk := (AFirst) * sample_mult; // w skali trendu Ÿród³owego
      first_index.Sample := 0;
      last_index.Chunk := (ALast + 1) * sample_mult - 1;
      last_index.Sample := 99;
      first_index := FTrend.MoveIndex(first_index, -FWindow div 2);
      last_index := FTrend.MoveIndex(last_index, FWindow div 2);
      offset := first_index.Sample;
      exp_first := first_index.Chunk;
      exp_last := last_index.Chunk;
      FTrend.UpdateCache(exp_first, exp_last);
      if (exp_first <= exp_last) {and (FTrend.FFirst < FTrend.FLast)} then
      begin
        first_index.Chunk := exp_first;
        last_index.Chunk := exp_last;
        first_index := FTrend.MoveIndex(first_index, FWindow div 2);
        last_index := FTrend.MoveIndex(last_index, -FWindow div 2);
        FFirst := first_index.Chunk div sample_mult;
        FLast := (last_index.Chunk + 1) div sample_mult - 1;
        if (AFirst <> FFirst) or (ALast <> FLast) then
        begin
          FNextUpdate := Now + UpdateDelay * OneSecond;
          FFirstAttempt := AFirst;
          FLastAttempt := ALast;
        end;
        SetLength(tmp_in, (exp_last - exp_first + 1) * ChunkSize);
        FTrend.GetDataBlock(tmp_in, exp_first, exp_last);
        tmp_cache := PDoubleArray(tmp_in);
        Inc(PByte(tmp_cache), offset * SizeOf(tmp_in[0]));
        // dodaæ przeliczanie tylko nowych danych !!!
        Calculate(tmp_cache^, FCalcCache, (FLast - FFirst + 1) * sample_mult *
          ChunkSize + FWindow, FWindow, 1, sample_mult);
        // do sprawdzenia!
        AFirst := FFirst;
        ALast := FLast;
        LogEvent(vlDebug, 'CalcTrend ' + IntToStr(FTrendDef) +
          '> Cache updated   Cache: ' + ' (' + IntToStr(AFirst) + '..' +
          IntToStr(ALast) + ') ' + IntToStr(ALast - AFirst));
      end
      else
      begin
        AFirst := 1;
        ALast := 0;
      end;
    except
      on e: Exception do
      begin
        raise Exception.Create('TTrendCalc.UpdateCache(1): ' + e.Message);
      end;
    end;
  finally
    FUpdateLock.Leave;
  end;
end;

{
procedure TTrendCalc.UpdateCache(var AFirst, ALast: Cardinal);
var
  i, j: Integer;
  exp_first, exp_last: LongWord; // nowy przedzia³ oczekiwany
  db_first, db_last: LongWord; // przedzia³ do pobrania z BD
  tmp_first, tmp_last: LongWord; // przedzia³ który uda³o siê pobraæ

  function ReadFromTrend: Boolean;
  var
    i: Integer;
  begin
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
        if ReadFromTrend then
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
            FCache[i - exp_first] := FCalcCache[i - db_first];
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
        if ReadFromTrend then
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
            FCache[i - tmp_first] := FCalcCache[i - db_first];
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
        if ReadFromTrend then
        begin
          // koiowanie z bd
          for i := tmp_first to tmp_last do
            FCache[i - tmp_first] := FCalcCache[i - db_first];
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
   }
procedure TTrendCalc.UpdateCache(ANew: TSampleIndex; AForce: Boolean);
var
  exp_first, exp_last: Cardinal; // nowy przedzia³ oczekiwany
  Size: Cardinal;
begin
  try
    if AForce or (((ANew.Chunk < FFirst) or (FLast < ANew.Chunk)) and
      ((ANew.Chunk < FFirstAttempt) or (FLastAttempt < ANew.Chunk) or
      (FNextUpdate < Now))) then
    begin
      // wyliczenie oczekiwanego przedzia³u
      Size := GetCacheSize();
      exp_first := ANew.Chunk - (Size div 2);
      exp_last := exp_first + Size - 1;
      UpdateCache(exp_first, exp_last);
    end;
  except
    on e: Exception do
    begin
      raise Exception.Create('TTrendCalc.UpdateCache(2): ' + e.Message);
    end;
  end;
end;

procedure TTrendMean.CalculateCL(var AIn, AOut: array of Double;
  ACount, AFilterWindow, AFilterStep, AInterleave: Integer);
begin
  CalculateCPU(AIn, AOut, ACount, AFilterWindow, AFilterStep, AInterleave);
  // na razie
end;

procedure TTrendMean.CalculateCPU(var AIn, AOut: array of Double;
  ACount, AFilterWindow, AFilterStep, AInterleave: Integer);
var
  x: Double;
  i, j: Integer;
  filter_count: Integer;
  sum: Double;
  count: Integer;
begin
  filter_count := AFilterWindow div AFilterStep;
  for i := 0 to ((ACount - AFilterWindow) div AInterleave) - 1 do
  begin
    sum := 0;
    count := 0;
    for j := 0 to filter_count - 1 do
    begin
      x := AIn[i * AInterleave + j * AFilterStep];
      if not IsNan(x) then
      begin
        sum := sum + x;
        Inc(count);
      end;
    end;
    if count > 0 then
      AOut[i] := sum / count
    else
      AOut[i] := 0;
  end;
end;

procedure TTrendDeriv.CalculateCL(var AIn: array of Double;
  var AOut: array of Double; ACount, AFilterWindow, AFilterStep,
  AInterleave: Integer);
var
  gpu_data, gpu_derivative: cl_mem;
  globalThreads: array [0 .. 0] of size_t; // ?????
  errcode_ret: cl_int; // error code returned from api calls
begin
  // Allocate GPU memory
  gpu_data := clCreateBuffer(FCLContext, CL_MEM_READ_ONLY or
    CL_MEM_COPY_HOST_PTR, SizeOf(AIn[0]) * Length(AIn), @AIn[0], @errcode_ret);
  if (errcode_ret <> CL_SUCCESS) then
  begin
    raise Exception.Create('clCreateBuffer (1): ' + IntToStr(errcode_ret));
  end;
  gpu_derivative := clCreateBuffer(FCLContext, CL_MEM_WRITE_ONLY,
    SizeOf(AOut[0]) * ACount, nil, @errcode_ret);
  if (errcode_ret <> CL_SUCCESS) then
  begin
    raise Exception.Create('clCreateBuffer (2): ' + IntToStr(errcode_ret));
  end;
  try
    // In the next step we associate the GPU memory with the Kernel arguments
    errcode_ret := clSetKernelArg(FCLDerivativeKernel, 0, SizeOf(cl_mem),
      @gpu_data);
    errcode_ret := clSetKernelArg(FCLDerivativeKernel, 1, SizeOf(cl_mem),
      @gpu_derivative);
    errcode_ret := clSetKernelArg(FCLDerivativeKernel, 2, SizeOf(AFilterWindow),
      @AFilterWindow);
    // Launch the Kernel on the GPU
    globalThreads[0] := ACount; // Length(AOut)-1;
    // localThreads[0]:=1;
    errcode_ret := clEnqueueNDRangeKernel(FCLQueue, FCLDerivativeKernel, 1, nil,
      @globalThreads, nil, 0, nil, nil);
    if (errcode_ret <> CL_SUCCESS) then
    begin
      raise Exception.Create('clEnqueueNDRangeKernel: ' +
        IntToStr(errcode_ret));
    end;
    // Copy the output in GPU memory back to CPU memory
    errcode_ret := clEnqueueReadBuffer(FCLQueue, gpu_derivative, CL_TRUE, 0,
      SizeOf(AOut[0]) * ACount, @AOut[0], 0, nil, nil);
    if (errcode_ret <> CL_SUCCESS) then
    begin
      raise Exception.Create('clEnqueueReadBuffer: ' + IntToStr(errcode_ret));
    end;
  finally
    // Free memory
    clReleaseMemObject(gpu_data);
    clReleaseMemObject(gpu_derivative);
  end;
end;

procedure TTrendDeriv.CalculateCPU(var AIn: array of Double;
  var AOut: array of Double; ACount, AFilterWindow, AFilterStep,
  AInterleave: Integer);
var
  xa, xb: Double;
  i, j: Integer;
  filter_count: Integer;
  sum_x: Double;
begin
  filter_count := AFilterWindow div AFilterStep; // do sprawdzenia lub wywalenia
  for i := 0 to ((ACount - AFilterWindow) div AInterleave) - 1 do
  begin
    sum_x := 0;
    for j := 0 to filter_count - 1 do
    begin
      xa := AIn[i * AInterleave + j * AFilterStep];
      xb := AIn[i * AInterleave + AFilterWindow - j * AFilterStep];
      if not IsNan(xa) and not IsNan(xb) then
        sum_x := sum_x + j * (xb - xa);
    end;
    AOut[i] := sum_x / (0.01 * AFilterStep * filter_count / 2 *
      (filter_count / 2 + 1) * (2 * filter_count / 2 + 1) / 3);
  end;
end;

end.
