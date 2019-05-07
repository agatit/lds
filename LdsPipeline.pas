unit LdsPipeline;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Contnrs,
  System.Math, DateUtils, Variants, AppLogs, LdsTrend,
  System.Generics.Defaults, System.Generics.Collections;

const
  WaveTracesLimit = 50;
  WaveReflectionsLimit = 0;

type

  TProbPoint = record
    Position: Double;
    Time: TDateTime;
    Value: Double;
  end;

  TProbList = array of TProbPoint;
  TProbMap = array of array of Double;

  TLdsLayer = (llWave, llMass, llMask, llDumy);
  TLdsLayers = set of TLdsLayer;

type
  TCorrelator = class
  private
    FTrend1: TTrend;
    FTrend2: TTrend;
    FWindow: Cardinal;
    FOffset: Integer;

    FLastIndex: TSampleIndex;
    FLastX1Sum: UInt64;
    FLastX2Sum: UInt64;
    FLastXYSum: UInt64;

  public
    constructor Create(ATrend1: TTrend; ATrend2: TTrend; AOffset: TDateTime; AWindow: TDateTime);

    function Value(const ATime: TDateTime): Double; overload;
    function Value(const AIndex1, AIndex2: TSampleIndex): Double; overload;
  end;

  TNode = class
  private
    FTrend: TTrend;
    FPosition: Double;
  public
    property Position: Double read FPosition write FPosition;
    property Trend: TTrend read FTrend write FTrend;

    constructor Create(APosition:Double; ATrend: TTrend);
  end;

  TPressureNode = class(TNode)
  private
  public
  end;

  TValveNode = class(TNode)
  private
  public
  end;

  TFlowNode = class(TNode)
  private
  public
  end;

  TTemperatureNode = class(TNode)
  private
  public
  end;

  TTracePoint = record
    Value: Double;
    Position: Double;
    Time: TDateTime;
    Distance: Double;
    Node: TPressureNode;
    constructor Create(AValue: Double; APosition: Double; ATime: TDateTime; ADistance: Double; ANode: TPressureNode);
  end;

  TPipeline = class;

  TMethod = class
  private
    FSegment: TPipeline;
    FRatio: Double;

  protected

  public
    property Ratio: Double read FRatio write FRatio;
    procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); virtual; abstract;

    constructor Create(ASegment: TPipeline);
    destructor Destroy; override;
  end;

  TDummyMethod = class(TMethod)
     procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); override;
  end;

  TWaveMethod = class(TMethod)
  private
    function WaveTime(AEventPos, ATransmitterPos: Double): TDateTime;
    function Dumping(AEventPos, ATransmitterPos: Double): Double;

  public
    DerivativeMaximumValue: Double;
    DerivativeMinimumValue: Double;
    DerivativeAlarmValue: Double;
    BaseWaveSpeed: Double;
    BaseDumping: Double;

    function GetTracePoints(APos: Double; ATime: TDateTime; ATraceDir:Integer; var ATracePoints: array of TTracePoint): Integer;
    procedure GetResponse_old(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); //override;
    procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); override;

    constructor Create(ASegment: TPipeline);
  end;

  TBalanceMethod = class(TMethod)
  public
    Flow1Trend: TTrend;
    Flow2Trend: TTrend;
    Pressure1Trend: TTrend;
    Pressure2Trend: TTrend;
    //BaseFlowFactor: Double;
    //BaseFlowOffset: Double;
    FlowCurveA: Double;
    FlowCurveB: Double;
    FlowCurveC: Double;

    LeakMinimumValue: Double;
    LeakMaximumValue: Double;
    MinFlow: Double;
    CorrectionOffset: Double;
    CorrectionFactor: Double;
    procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); override;
  end;

  TMaskMethod = class(TMethod)
  public
    MaskTrend: TTrend;
    procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word); override;
  end;


  TMaxFinder = class;

  TPipeline = class
  private
    FBeginPos: Double;
    FEndPos: Double;
    FNodes: array of TNode;
    FMethods: array of TMethod;
    FName: String;
    FMaxFinder: TMaxFinder;
    FAlarmLevel: Double;

    procedure GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word);

    function GetNode(index: Integer): TNode;
    function GetNodeCount: Integer;
    procedure SetNode(index: Integer; const Value: TNode);
    function GetPrevNode(APos: Double; cls: TClass = nil): TNode;
    function GetNextNode(APos: Double; cls: TClass = nil): TNode;

    function GetMethodCount: Integer;
    function GetMethod(index: Integer): TMethod;
    procedure SetMethods(index: Integer; const Value: TMethod);
  public
    AppLogs: TAppLogs;


    property NodeCount: Integer read GetNodeCount;
    property Nodes[index: Integer]: TNode read GetNode write SetNode;
    property MethodCount: Integer read GetMethodCount;
    property Methods[index: Integer]: TMethod read GetMethod write SetMethods;
    property BeginPos: Double read FBeginPos write FBeginPos;
    property EndPos: Double read FEndPos write FEndPos;
    property Name: String read FName write FName;
    property AlarmLevel: Double read FAlarmLevel write FAlarmLevel;
    property MaxFinder: TMaxFinder read FMaxFinder;

    procedure GetProbabilityMap(var AProbMap: TProbMap; var AEventList: TProbList;
                                PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                                TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word;
                                Layer: TLdsLayers = []);

    procedure GetProbabilityList(var AProbList: TProbList; var AEventList: TProbList; PosMin,
                                PosMax: Double; PosCount: Word; TimeMin, TimeMax: TDateTime; TimeCount: Word;
                                Layer: TLdsLayers);

    constructor Create();
    destructor Destroy(); override;
  end;

  TMaximum = class
    StartPos: Double;
    StartTime: TDateTime;
    LastTime: TDateTime;
    MaxValue: Double;
    PosSum: Double;
    Count: Word;
  end;

  TMaxFinder = class
  private
    FMaximums: TObjectList;

  public

    procedure Find(var AProbMap: TProbMap; var AEventList: TProbList;
                  PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                  TimeMin, TimeMax: TDateTime; TimeIndexMin, TimeIndexMax: Word;
                  DerivativeAlarmValue: Double; PosTolerance: Double);
    constructor Create();

  end;



const
  NullIndex: TSampleIndex = (Chunk:0; Sample:0);

var
  Dumping: Double;

implementation
uses ProfilerDataModule;


{ TNode }

constructor TNode.Create(APosition: Double; ATrend: TTrend);
begin
  FPosition := APosition;
  FTrend := ATrend;
end;

{ TTracePoint }

constructor TTracePoint.Create(AValue: Double; APosition: Double; ATime: TDateTime; ADistance: Double; ANode: TPressureNode);
begin
    Value := AValue;
    Position := APosition;
    Time := ATime;
    Distance := ADistance;
    Node := ANode;
end;

{ TCorrelator }

constructor TCorrelator.Create(ATrend1, ATrend2: TTrend; AOffset: TDateTime; AWindow: TDateTime);
var
  sample_time: TDateTime;

begin
  FTrend1 := ATrend1;
  FTrend2 := ATrend2;

  sample_time := min(ATrend1.SampleTime, ATrend2.SampleTime);
  FWindow := floor(AWindow / sample_time);
  FOffset := floor(AOffset / sample_time);

  FLastIndex := NullIndex;
  FLastX1Sum := 0;
  FLastX2Sum := 0;
  FLastXYSum := 0;
end;

function TCorrelator.Value(const ATime: TDateTime): Double;
begin
  Result := Value(FTrend1.DateTimeToIndex(ATime), FTrend2.DateTimeToIndex(ATime));
end;

function TCorrelator.Value(const AIndex1, AIndex2: TSampleIndex): Double;
var
  x1, x2: Integer;
  i: Integer;
  index1add, index2add, index1sub, index2sub, index_new: TSampleIndex;
  count, count_add, count_sub: Cardinal;

begin
  index_new := AIndex1;

  count := FTrend1.DiffIndex(index_new, FLastIndex);
  FLastIndex := index_new;
  //if count < (FWindow div 2) then
  if false then
  begin
    if count > 0 then
    begin
      index1add := FTrend1.MoveIndex(AIndex1, FWindow div 2 - count);
      index2add := FTrend2.MoveIndex(AIndex2, FWindow div 2 + FOffset - count);
      index1sub := FTrend1.MoveIndex(AIndex1, -FWindow div 2 - count);
      index2sub := FTrend2.MoveIndex(AIndex2, -FWindow div 2 + FOffset - count);
    end
    else
    begin
      index1add := FTrend1.MoveIndex(AIndex1, FWindow div 2);
      index2add := FTrend2.MoveIndex(AIndex2, FWindow div 2 + FOffset);
      index1sub := FTrend1.MoveIndex(AIndex1, -FWindow div 2);
      index2sub := FTrend2.MoveIndex(AIndex2, -FWindow div 2 + FOffset);
    end;
    count_add := count;
    count_sub := count;
  end
  else
  begin
    index1add := FTrend1.MoveIndex(AIndex1, -FWindow div 2);
    index2add := FTrend2.MoveIndex(AIndex2, -FWindow div 2 + FOffset);
    count_add := FWindow;
    count_sub := 0;
    FLastX1Sum := 0;
    FLastX2Sum := 0;
    FLastXYSum := 0;
  end;

  for i := 0 to count_add-1 do
  begin
    x1 := FTrend1.GetRawValue(index1add);
    x2 := FTrend2.GetRawValue(index2add);
    Inc(FLastX1Sum, x1);
    Inc(FLastX2Sum, x2);
    Inc(FLastXYSum, UInt64(x1)*x2);
    FTrend1.IncIndex(index1add);
    FTrend2.IncIndex(index2add);
  end;

  for i := 0 to count_sub-1 do
  begin
    x1 := FTrend1.GetRawValue(index1sub);
    x2 := FTrend2.GetRawValue(index2sub);
    Dec(FLastX1Sum, x1);
    Dec(FLastX2Sum, x2);
    Dec(FLastXYSum, UInt64(x1)*x2);
    FTrend1.IncIndex(index1sub);
    FTrend2.IncIndex(index2sub);
  end;

  Result := (FLastXYSum - FLastX1Sum*FLastX2Sum/FWindow)/(1.0*FWindow*$3FFF0000); //połowa zakresy do kwadratu * N
end;




{ TSegment }

constructor TPipeline.Create();
begin
  FBeginPos := 0;
  FEndPos := 0;
  FName := 'asd';
  FMaxFinder := TMaxFinder.Create;
end;

destructor TPipeline.Destroy;
begin
  FMaxFinder.Free;
  inherited;
end;

procedure TPipeline.GetProbabilityMap(var AProbMap: TProbMap; var AEventList: TProbList; PosMin,
  PosMax: Double; PosIndexMin, PosIndexMax: Word; TimeMin, TimeMax: TDateTime;
  TimeIndexMin, TimeIndexMax: Word; Layer: TLdsLayers);
var
  i,p,t: Integer;
  tmp: TProbMap;
  PosCount, TimeCount: Integer;
begin
  PosCount := PosIndexMax-PosIndexMin+1;
  TimeCount := TimeIndexMax-TimeIndexMin+1;
  SetLength(tmp, PosCount, TimeCount);

  for p  := PosIndexMin to PosIndexMax do
    for t := TimeIndexMin to TimeIndexMax do
      AProbMap[p,t] := 0;

  if llWave in Layer then
  begin
    Methods[0].GetResponse(tmp, AEventList, PosMin, PosMax, 0, PosCount-1, TimeMin, TimeMax, 0, TimeCount-1);
    for p  := PosIndexMin to PosIndexMax do
      for t := TimeIndexMin to TimeIndexMax do
        AProbMap[p,t] := tmp[p-PosIndexMin,t-TimeIndexMin]
  end;

  if llMass in Layer then
  begin
    Methods[2].GetResponse(tmp, AEventList, PosMin, PosMax, 0, PosCount-1, TimeMin, TimeMax, 0, TimeCount-1);
    for p  := PosIndexMin to PosIndexMax do
      for t := TimeIndexMin to TimeIndexMax do
        AProbMap[p,t] :=  AProbMap[p,t] + tmp[p-PosIndexMin,t-TimeIndexMin]
  end;

  if llMask in Layer then
  begin
    Methods[1].GetResponse(tmp, AEventList, PosMin, PosMax, 0, PosCount-1, TimeMin, TimeMax, 0, TimeCount-1);
    for p  := PosIndexMin to PosIndexMax do
      for t := TimeIndexMin to TimeIndexMax do
        AProbMap[p,t] := AProbMap[p,t] * tmp[p-PosIndexMin,t-TimeIndexMin];
  end;


  //pobieranie listy zdarzeń jest czasochłonne, nie warto tego robić przy odświeżaniu wykresu
  //MaxFinder.Find(AProbMap,  AEventList, PosMin, PosMax, 0, PosCount-1, TimeMin, TimeMax, 0, TimeCount-1 ,(Methods[0] as TWaveMethod).DerivativeAlarmValue, 300); //zrobić parametry dla segmentu!!!
end;


procedure TPipeline.GetProbabilityList(var AProbList: TProbList; var AEventList: TProbList; PosMin,
  PosMax: Double; PosCount: Word; TimeMin, TimeMax: TDateTime; TimeCount: Word;
  Layer: TLdsLayers);
var
  pos, pos_step: Double;
  tm, time_step: TDateTime;
  p,t: Integer;
  probMap: TProbMap;

begin
  SetLength(probMap, PosCount, TimeCount);
  SetLength(AEventList, 0);

  GetProbabilityMap(probMap, AEventList, PosMin, PosMax, 0, PosCount-1, TimeMin, TimeMax, 0, TimeCount-1, Layer);

  pos_step := IfThen(PosCount>1, (PosMax - PosMin) / (PosCount-1), 0);
  time_step :=  IfThen(TimeCount>1, (TimeMax - TimeMin) / (TimeCount-1), 0);

  SetLength(AProbList, PosCount*TimeCount);

  tm := TimeMin;
  for t := 0 to TimeCount-1 do
  begin
    pos := PosMin;
    for p := 0 to PosCount-1 do
    begin
      with AProbList[t*PosCount + p] do
      begin
        Position := pos;
        Time := tm;
        Value :=  probMap[p, t];
      end;
      pos := pos + pos_step;
    end;
    tm := tm + time_step;
  end;
end;

procedure TPipeline.GetResponse(var AProbMap: TProbMap;
  var AEventList: TProbList; PosMin, PosMax: Double; PosIndexMin,
  PosIndexMax: Word; TimeMin, TimeMax: TDateTime; TimeIndexMin,
  timeIndexMax: Word);
var
  i: Integer;
begin

end;

function TPipeline.GetMethod(index: Integer): TMethod;
begin
  Result := FMethods[index];
end;

function TPipeline.GetMethodCount: Integer;
begin
  Result := Length(FMethods);
end;

function TPipeline.GetPrevNode(APos: Double; cls: TClass): TNode;
begin
  Result := nil;
end;


function TPipeline.GetNextNode(APos: Double; cls: TClass): TNode;
begin
  Result := nil;
end;

function TPipeline.GetNode(index: Integer): TNode;
begin
  Result := FNodes[index];
end;

function TPipeline.GetNodeCount: Integer;
begin
  Result := Length(FNodes);
end;

procedure TPipeline.SetMethods(index: Integer; const Value: TMethod);
begin
  if index >= Length(FMethods) then
    SetLength(FMethods, index+1);
  FMethods[index] := Value;
end;

procedure TPipeline.SetNode(index: Integer; const Value: TNode);
begin
  if index >= Length(FNodes) then
    SetLength(FNodes, index+1);
  FNodes[index] := Value;

  TArray.Sort<TNode>(FNodes , TDelegatedComparer<TNode>.Construct(
    function(const Left, Right: TNode): Integer
    begin
      Result := TComparer<Double>.Default.Compare(Left.Position, Right.Position);
    end));
end;



////////////////////////////////////////////////////////////////////////////////
// TMethod
constructor TMethod.Create(ASegment: TPipeline);
begin
  FRatio := 1;
  FSegment := ASegment;
end;

destructor TMethod.Destroy;
begin
  inherited;
end;


////////////////////////////////////////////////////////////////////////////////
// TDummyMethod

procedure TDummyMethod.GetResponse(var AProbMap: TProbMap; var AEventList: TProbList; PosMin,
  PosMax: Double; PosIndexMin, PosIndexMax: Word; TimeMin, TimeMax: TDateTime; TimeIndexMin, TimeIndexMax: Word);
var
  pos, pos0,pos_sigma, pos_step: Double;
  tm, time0,time_sigma, time_step: TDateTime;
  p,t: Integer;

begin

  pos_step :=  IfThen(PosIndexMax > PosIndexMin, (PosMax - PosMin) / (PosIndexMax-PosIndexMin), 0);
  time_step :=  IfThen(TimeIndexMax > TimeIndexMin, (TimeMax - TimeMin) / (TimeIndexMax-TimeIndexMin), 0);

  time0 := StrToDateTime('2016-01-01 00:05:00');
  time_sigma := StrToTime('0:05:00');
  pos0 := 11000;
  pos_sigma := 500;

  tm := TimeMin;
  for t := TimeIndexMin to TimeIndexMax do
  begin
    pos := PosMin;
    for p := PosIndexMin to PosIndexMax do
    begin
      AProbMap[p, t] :=  exp(-(sqr((tm - time0)/time_sigma)+sqr((pos - pos0)/pos_sigma))/2);
      pos := pos + pos_step;
    end;
    tm := tm + time_step;
  end;
end;



////////////////////////////////////////////////////////////////////////////////
// TWaveMethod

constructor TWaveMethod.Create(ASegment: TPipeline);
begin
  inherited;

  FSegment := ASegment;
  DerivativeMaximumValue := 0.0008;
  DerivativeMinimumValue := 0.0000;
  BaseWaveSpeed := 1214;
  BaseDumping := 0;
end;


function TWaveMethod.WaveTime(AEventPos, ATransmitterPos: Double): TDateTime;

  //it's a kind of magic
  function time(APos: Double): Double;
  begin
    Result := ((2.054463674297892E-12*APos + -4.092705636310795E-8)*APos + 0.0010568446842449445)*APos + -0.2927529299562952;
  end;

begin
  //Result := OneSecond *  Abs(time(ATransmitterPos) - time(AEventPos));
  //Result := OneSecond * abs(AEventPos - ATransmitterPos)/FWaveSpeed;  //1150
  Result := OneSecond * abs(AEventPos - ATransmitterPos)/BaseWaveSpeed;
end;

function TWaveMethod.Dumping(AEventPos, ATransmitterPos: Double): Double;
begin
  Result := BaseDumping;
end;

function TWaveMethod.GetTracePoints(APos: Double; ATime: TDateTime; ATraceDir:Integer;
  var ATracePoints: array of TTracePoint): Integer;

var
  i: Integer;
  trace_count: Integer;

  procedure WaveTrace(APos: Double; ATime: TDateTime; APosIndex: Integer; AWaveDir: Integer; ADistance: Double; AReflections: Integer; ATraceDir:Integer);
  var
    index: Integer;
    wave_dir: Integer;
    trace_dir: Integer;
    delay, dist: Double;
    detection: TTracePoint;
  begin
    wave_dir := IfThen(AWaveDir>0,1,-1);
    trace_dir := IfThen(ATraceDir>0,1,-1);
    index := APosIndex;
    //dist := ADistance;

    while (trace_count <= High(ATracePoints)) and (Low(FSegment.FNodes) <= index) and (index <= High(FSegment.FNodes)) and (trace_count < WaveTracesLimit) do //uniezaleźnic od FNodes
    begin
      if FSegment.Nodes[index] is TPressureNode then
      begin
        with ATracePoints[trace_count] do
        begin
          Node := TPressureNode(FSegment.Nodes[index]);
          Position := Node.Position;
          Time := ATime + trace_dir * WaveTime(Position, APos);
          Distance := ADistance + abs(Position-APos);
          Value := Node.FTrend.GetValue(Time);
        end;
        Inc(trace_count);
        break;
      end
      else if FSegment.Nodes[index] is TValveNode then
      begin
        //jeśli zawór zamknięty - odbicie
        if (AReflections < WaveReflectionsLimit)
              and (not Assigned(TValveNode(FSegment.Nodes[index]).FTrend)
                or (TValveNode(FSegment.Nodes[index]).FTrend.GetValue(ATime - WaveTime(FSegment.Nodes[index].Position, APos)) < 0.5)) then
        begin
          dist := ADistance + abs(FSegment.Nodes[index].Position-APos);
          delay :=  trace_dir * WaveTime(FSegment.Nodes[index].Position, APos);
          WaveTrace(FSegment.Nodes[index].Position, ATime + delay, index-wave_dir, -wave_dir, dist , AReflections + 1, ATraceDir);
          break;
        end;
      end;
      //inne ignorujemy

      Inc(index, wave_dir);
    end;
  end;
begin
  trace_count := 0;
  i := 0;
  while (FSegment.Nodes[i].Position <= APos) and (i < High(FSegment.FNodes)) do //uniezaleznić od FNodes
  begin
    Inc(i);
  end;
  if (FSegment.Nodes[i].Position < APos) and (i = High(FSegment.FNodes)) then //uniezaleznić od FNodes
    exit; //nie da się nic obliczyć dla tego punktu

  WaveTrace(APos, ATime, i-1, -1, 0, 0, ATraceDir); //na lewo
  WaveTrace(APos, ATime, i, 1, 0, 0, ATraceDir); //i na prawo

  Result := trace_count;

end;


procedure TWaveMethod.GetResponse(var AProbMap: TProbMap; var AEventList: TProbList; PosMin,
  PosMax: Double; PosIndexMin, PosIndexMax: Word; TimeMin, TimeMax: TDateTime; TimeIndexMin, TimeIndexMax: Word);
var
  pos, pos_step: Double;
  tm, time_step: TDateTime;
  i,j,p,t: Integer;

  index1, index2 : TSampleindex;

  range: Integer;

  data_begin: Integer;

  cause_deriv, result_deriv, local_deriv, min_deriv, max_deriv, sum_deriv: Double;
  count_deriv: Integer;
  max_pos, min_pos, tmp, peak_min, peak_max: Double;
  max_offset: Integer;

  trace_array: array of TTracePoint;
  trace_count: Integer;

begin

  //data_begin := data_begin - (FWMParams.CorrellationWindow div 2); //zmiejszam przesunięcie dla korelacji gdyż korelacja jest liczona asymetrycznie
  pos_step :=  IfThen(PosIndexMax > PosIndexMin, (PosMax - PosMin) / (PosIndexMax-PosIndexMin), 0);
  time_step :=  IfThen(TimeIndexMax > TimeIndexMin, (TimeMax - TimeMin) / (TimeIndexMax-TimeIndexMin), 0);


  tm := TimeMin;
  for t := TimeIndexMin to TimeIndexMax do
  begin
    min_deriv := MaxDouble;
    max_deriv := -MaxDouble;

    //czasy przejścia fali i maksymalna pochodna
    min_deriv := MaxDouble;
    max_deriv := -MaxDouble;
    sum_deriv := 1;
    pos := PosMin;
    for p := PosIndexMin to PosIndexMax do
    begin

      //uśrednienie skutków
      SetLength(trace_array,WaveTracesLimit);
      trace_count := GetTracePoints(pos, tm, 1, trace_array);
      sum_deriv := 1;
      count_deriv := 0;

      // weryfikowac czy nie było za dużo odbić - punkt bez pomiaru ciśnienia zamknięty między zaworami ?

      for i := 0 to trace_count-1 do
        if Assigned(trace_array[i].Node) and not IsNaN(trace_array[i].Value) then
        begin
          //sum_deriv := sum_deriv + trace_array[i].Value;
          //sum_deriv := sum_deriv * max(0,trace_array[i].Value * (1 + (tm-trace_array[i].Time) * 86400 * Dumping));
          sum_deriv := sum_deriv * max(0,trace_array[i].Value);
          //sum_deriv := sum_deriv + trace_array[i].Value * (1 - trace_array[i].Distance * Dumping(trace_array[i].Position, pos));

          Inc(count_deriv);
        end;
      if count_deriv > 0 then
        result_deriv := power(sum_deriv,1/count_deriv)
        //result_deriv := sum_deriv/count_deriv
      else
        result_deriv := 0;

       //uśrednienie przyczyn
      SetLength(trace_array,0);
      SetLength(trace_array,WaveTracesLimit);
      trace_count := GetTracePoints(pos, tm, -1, trace_array);
      sum_deriv := 1;
      count_deriv := 0;
      for i := 0 to trace_count-1 do
        if Assigned(trace_array[i].Node) and not IsNaN(trace_array[i].Value) then
        begin
          //sum_deriv := sum_deriv + trace_array[i].Value;
          sum_deriv := sum_deriv * max(0,trace_array[i].Value);
          //sum_deriv := sum_deriv + trace_array[i].Value * (1 + trace_array[i].Distance * Dumping(trace_array[i].Position, pos));
          Inc(count_deriv);
        end;

      if count_deriv > 0 then
        cause_deriv := power(sum_deriv,1/count_deriv)
        //cause_deriv := sum_deriv/count_deriv
      else
        cause_deriv := 0;

      local_deriv := max(0, max(0,result_deriv) - max(0,cause_deriv));
      //local_deriv := result_deriv - cause_deriv;
      //local_deriv := result_deriv;

      if max_deriv < local_deriv then
      begin
        max_deriv := local_deriv;
        max_pos := pos;
      end;

      if min_deriv > local_deriv then
      begin
        min_deriv := local_deriv;
      end;

      AProbMap[p, t] := local_deriv;

      pos := pos + pos_step;
    end;


    //skalowanie
    if (DerivativeMaximumValue > DerivativeMinimumValue) and (max_deriv > min_deriv) then
      for p := PosIndexMin to PosIndexMax do
      begin
        //peak := Min(1, (max_deriv-DerivativeMinimumValue) / (DerivativeMaximumValue - DerivativeMinimumValue));
        //AProbMap[p, t] := peak * (AProbMap[p, t] - min_deriv) / (max_deriv-min_deriv);

        //skalowanie DerivativeMinimumValue -> 0 ; DerivativeMaximumValue -> 1
        //AProbMap[p, t] := max(0,(AProbMap[p, t]-DerivativeMinimumValue)) / (DerivativeMaximumValue - DerivativeMinimumValue);

        //skalowanie  wartość minimalna -> 0  ; DerivativeMaximumValue -> 1
        peak_min := max(DerivativeMinimumValue, min_deriv);
        AProbMap[p, t] := max(0,(AProbMap[p, t]-peak_min)) / (DerivativeMaximumValue - peak_min);

        //skalowanie  wartość minimalna -> 0  ; wartość maksymalna -> 1
        //peak_min := max(DerivativeMinimumValue, min_deriv);
        //peak_max := max(DerivativeMaximumValue, max_deriv);
        //AProbMap[p, t] := max(0,(AProbMap[p, t]-peak_min)) / (peak_max - peak_min);

      end;

    tm := tm + time_step;
  end;

end;

procedure TWaveMethod.GetResponse_old(var AProbMap: TProbMap; var AEventList: TProbList; PosMin,
  PosMax: Double; PosIndexMin, PosIndexMax: Word; TimeMin, TimeMax: TDateTime; TimeIndexMin, TimeIndexMax: Word);

type
  TEvent = record
              time: TDateTime;
              pos: Double;
              node: TNode;
              node_index: Integer;
              value: Double;
            end;

var
  peaks: array of TEvent;
  leaks: array of TEvent;
  pos, pos_step: Double;
  tm, time_step: TDateTime;
  time_min: TDateTime;
  time_max: TDateTime;
  index1, index2, event_begin : TSampleindex;
  range: Cardinal;
  new_deriv, last_deriv, min_deriv, max_deriv: Double;
  unique: Boolean;
  time_tolerance: TDateTime;




  i,j,k,p,t: Integer;


  max_pos, min_pos, tmp, peak_min, peak_max: Double;
  max_offset: Integer;


begin
  time_tolerance := 0.01 * OneSecond;


  //ustalenie przedziałów do analizy trendów
  time_min := TimeMin - WaveTime(PosMin, PosMax);
  time_max := TimeMax + WaveTime(PosMax, PosMin);


  //przeszukanie kolejnych trendów
  SetLength(peaks,0);
  for i := 0 to FSegment.NodeCount-1 do
    with FSegment.Nodes[i].FTrend do
    begin
      index1 := DateTimeToIndex(time_min);
      index2 := DateTimeToIndex(time_max);
      range := DiffIndex(index1, index2);
      event_begin := index1;
      last_deriv := MinDouble;

      for j := 0 to range-1 do
      begin
        new_deriv := RescaleValue(GetRawValue(index1));
        if new_deriv > last_deriv then
          event_begin := index1
        else
          if last_deriv > DerivativeMaximumValue then
          begin
            SetLength(peaks,Length(peaks)+1);
            with peaks[Length(peaks)-1] do
            begin
              node := FSegment.Nodes[i];
              time := IndexToDateTime(event_begin);
              pos := FSegment.Nodes[i].Position;
              value := last_deriv;
            end;
          end;

        last_deriv := new_deriv;
        FSegment.Nodes[i].FTrend.IncIndex(index1);
      end;
    end;

  //odszukanie wycieków
  //wyciek jest gdy:
  // - dwa czujniki mają przekroczenie w odstępnie mniejszym niż czas przejścia fali między nimi (z teolerancją?)
  // - czuniki sąsiadujace z czujnikami które zasygnalizowały przekroczenie nie sygnalizowały przekroczenia w czasie równym czasowi pzejścia fali (z toleranją?)
  SetLength(leaks,0);
  for i := 0 to Length(peaks)-2 do
    for j := i+1 to Length(peaks)-1 do
    begin
      //podejrzenie wycieku - odległośc między zdarzeniami mniejsza od odległości między czujnikami
      if WaveTime(peaks[i].node.Position, peaks[j].node.Position) > abs(peaks[i].time-peaks[j].time) then
      begin
        //weryfikacja - czy zdarzenie było już wykryte przez inny czujnik
        unique := True;
        for k := 0 to Length(peaks)-1 do
        begin
          if abs(WaveTime(peaks[i].node.Position, peaks[k].node.Position) - abs(peaks[i].time-peaks[k].time)) < time_tolerance  then
            unique := False;
        end;
        for k := 0 to Length(peaks)-1 do
        begin
          if abs(WaveTime(peaks[j].node.Position, peaks[k].node.Position) - abs(peaks[j].time-peaks[k].time)) < time_tolerance  then
            unique := False;
        end;
        if unique then
        begin
          //wyciek
          SetLength(leaks, Length(leaks)+1);
          with leaks[Length(leaks)-1] do
          begin
            pos :=  0;
            time := 0;
            value := 0;
          end;
        end;
      end;
    end;

  //zdarzenia z tej samej chwili wygenerowane przez różne czujniki scalamy w jedno (rozważyć zastosowanie korelacji i regresji liniowej)

  //zdarzenia wygenerowane poza przedziałem z zapytania pomijamy ???



  //generowanie mapy


end;


{ TBalanceMethod }

procedure TBalanceMethod.GetResponse(var AProbMap: TProbMap;
  var AEventList: TProbList; PosMin, PosMax: Double; PosIndexMin,
  PosIndexMax: Word; TimeMin, TimeMax: TDateTime; TimeIndexMin,
  timeIndexMax: Word);
var
  res, flow1, flow2, pressure1, pressure2: Double;
  est_press1, est_press2, est_accurency: Double;
  leak, pressure_drop, leak_pos, begin_pos, end_pos: Double;
  pos, pos_step: Double;
  tm, time_step: TDateTime;
  t,p: Integer;

  first, last: Cardinal;
  r1, r2: Double;

begin
  //BaseFlowFactor := 830.34; //0.075;
  //BaseFlowOffset := 856.83;
  FlowCurveA := 4.32134019e-07;
  FlowCurveB := 3.76451551e-05;
  FlowCurveC := 1.90000000e-02;

  begin_pos := FSegment.BeginPos;
  end_pos := FSegment.EndPos;

  LeakMinimumValue := 0.0; //m3/h
  LeakMaximumValue := 1.5; //m3/h
  MinFlow := 20;
  CorrectionOffset := 0.4;
  CorrectionFactor := 1.0; //(0.5+524)/524;

  pos_step :=  IfThen(PosIndexMax > PosIndexMin, (PosMax - PosMin) / (PosIndexMax-PosIndexMin), 0);
  time_step :=  IfThen(TimeIndexMax > TimeIndexMin, (TimeMax - TimeMin) / (TimeIndexMax-TimeIndexMin), 0);

  //wymuszenie odswizenia - po poprawieniu cachowania CalcTrendów należy usunąć
  first := Flow1Trend.DateTimeToIndex(TimeMin).Chunk;
  last := Flow1Trend.DateTimeToIndex(TimeMax).Chunk;
  Flow1Trend.UpdateCache(first, last);

  first := Flow2Trend.DateTimeToIndex(TimeMin).Chunk;
  last := Flow2Trend.DateTimeToIndex(TimeMax).Chunk;
  Flow2Trend.UpdateCache(first, last);

  first := Pressure1Trend.DateTimeToIndex(TimeMin).Chunk;
  last := Pressure1Trend.DateTimeToIndex(TimeMax).Chunk;
  Pressure1Trend.UpdateCache(first, last);

  first := Pressure2Trend.DateTimeToIndex(TimeMin).Chunk;
  last := Pressure2Trend.DateTimeToIndex(TimeMax).Chunk;
  Pressure2Trend.UpdateCache(first, last);


  tm := TimeMin;
  for t := TimeIndexMin to TimeIndexMax do
  begin
    flow1 := Flow1Trend.GetValue(tm, True);
    flow2 := Flow2Trend.GetValue(tm+1.5*OneSecond, False);
    pressure1 := Pressure1Trend.GetValue(tm, True);
    pressure2 := Pressure2Trend.GetValue(tm, True);
    //na razie wyłączam lokalizację
    //pressure1 := NaN;
    //pressure2 := NaN;

    res := 0;

    if not IsNaN(flow1) and not IsNaN(flow2) and (flow1 > MinFlow) and (flow2 > MinFlow) then
    begin
      flow1 := max(0, flow1); //nie analizujemy tłoczenia wstecz
      flow2 := max(0, flow2*CorrectionFactor + CorrectionOffset);
      leak := max(0, flow1 - flow2); //jeśli na wyjściu jest więcej to nie ma wycieku
      res := min(1, (leak-LeakMinimumValue)/(LeakMaximumValue-LeakMinimumValue));

      if (res > 0) and not IsNaN(pressure1) and not IsNaN(pressure2)  then
      begin
        pos := PosMin;

        pressure_drop := pressure1 - pressure2;
        est_press1 := flow1*flow1*FlowCurveA + flow1*FlowCurveA + FlowCurveC;
        est_press2 := flow2*flow2*FlowCurveA + flow2*FlowCurveA + FlowCurveC;

        leak_pos := pressure_drop*(end_pos-begin_pos)/(est_press1-est_press2) +
                   end_pos-est_press1*(end_pos-begin_pos)/(est_press1-est_press2);
        leak_pos := min(begin_pos, max(end_pos, leak_pos));

        for p := PosIndexMin to PosIndexMax do
        begin
          //szerokość powinna zależeć od różnicy przepływów
          //np.:
          //LeakMaximumValue -> pełna szerokość
          //potem LeakMaximumValue/leak całej długości
          est_accurency := (end_pos-begin_pos) * max(1,LeakMaximumValue/leak);

          //w punkcie -> res * 1
          //200 m od punktu -> res * 0
          //AProbMap[p, t] := res * max(0, (200-abs(pos-leak_pos))/200);
          AProbMap[p, t] := res * max(0, (est_accurency-abs(pos-leak_pos))/est_accurency);

          pos := pos + pos_step;
        end;
      end
      else
      begin
        //brak pomiaru ciśnienia - wyciek na całej długości
        pos := PosMin;
        for p := PosIndexMin to PosIndexMax do
        begin
          AProbMap[p, t] := res;
          pos := pos + pos_step;
        end;
      end;
    end
    else
    begin
      //zerwoy przepływ - brak wycieku
      pos := PosMin;
      for p := PosIndexMin to PosIndexMax do
      begin
        AProbMap[p, t] := 0;
        pos := pos + pos_step;
      end;
    end;

    tm := tm + time_step;
  end;
end;

{ TMaskMethod }

procedure TMaskMethod.GetResponse(var AProbMap: TProbMap; var AEventList: TProbList;
                            PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                            TimeMin, TimeMax: TDateTime; TimeIndexMin, timeIndexMax: Word);
var
  res, val: Double;
  pos, pos_step: Double;
  tm, time_step: TDateTime;
  t,p: Integer;

begin
  pos_step :=  IfThen(PosIndexMax > PosIndexMin, (PosMax - PosMin) / (PosIndexMax-PosIndexMin), 0);
  time_step :=  IfThen(TimeIndexMax > TimeIndexMin, (TimeMax - TimeMin) / (TimeIndexMax-TimeIndexMin), 0);


  tm := TimeMin;
  for t := TimeIndexMin to TimeIndexMax do
  begin
    val := MaskTrend.GetValue(tm + 10*OneSecond); //ofset powinien być ustawiany
    if IsNaN(val) or (val < 0.5) then
      res := 1
    else
      res := 0;
    for p := PosIndexMin to PosIndexMax do
    begin
      AProbMap[p, t] := res;
      pos := pos + pos_step;
    end;
    tm := tm + time_step;
  end;
end;

{ TMaxFinder }

constructor TMaxFinder.Create();
begin
  inherited Create;

  FMaximums := TObjectList.Create;
end;


procedure TMaxFinder.Find(var AProbMap: TProbMap; var AEventList: TProbList;
                                PosMin, PosMax: Double; PosIndexMin, PosIndexMax: Word;
                                TimeMin, TimeMax: TDateTime; TimeIndexMin, TimeIndexMax: Word;
                                DerivativeAlarmValue: Double; PosTolerance: Double);
var
  p,t,i: Integer;
  tmp, last, new: TMaximum;
  pos_step, pos: Double;
  time_step, time: TDateTime;
  range: Word;

  function IsMax(PosIndex: Word; TimeIndex: Word; Range: Word): Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := max(PosIndexMin,PosIndex-Range) to max(PosIndexMin,PosIndex-1) do
      if AProbMap[i,TimeIndex] > AProbMap[PosIndex,TimeIndex] then
        Result := False;
    for i := min(PosIndexMax,PosIndex+1) to min(PosIndexMax,PosIndex+Range) do
      if AProbMap[i,TimeIndex] >= AProbMap[PosIndex,TimeIndex] then
        Result := False;
  end;

  function GetMax(TimeIndex: Word): Integer;
  var
    max: Double;
    max_pos: Integer;
    p: Integer;
  begin
    max_pos := -1;
    max := 0;
    for p := PosIndexMin to PosIndexMax do
      if AProbMap[p,TimeIndex] > max then
      begin
        max := AProbMap[p,TimeIndex];
        max_pos := p;
      end;
    Result := max_pos;
  end;


begin
  pos_step :=  IfThen(PosIndexMax > PosIndexMin, (PosMax - PosMin) / (PosIndexMax-PosIndexMin), 0);
  time_step :=  IfThen(TimeIndexMax > TimeIndexMin, (TimeMax - TimeMin) / (TimeIndexMax-TimeIndexMin), 0);
  range := Round(PosTolerance/pos_step);

  for t := TimeIndexMin to TimeIndexMax do
  begin
    time := TimeMin + (t-TimeIndexMin)*time_step ;
    //for p := PosIndexMin to PosIndexMax do
    p := GetMax(t);
    begin
      //if IsMax(p,t, (PosIndexMax - PosIndexMin) div 2) then //1/2 zakresu ?
      if p > -1 then      
      begin
        pos := PosMin + (p-PosIndexMin)*pos_step;
        new := TMaximum.Create;
        with new do
        begin
          StartPos := pos;
          StartTime := time;
          LastTime := time;
          MaxValue := AProbMap[p,t];
          PosSum := pos;
          Count := 1;
        end;
        FMaximums.Add(new);

        //czy to jest nowy maks czy kontunuacja
        i := 0;
        while i < FMaximums.Count - 1 do
        begin
          last := FMaximums[i] as TMaximum;
          if (abs(new.StartPos - last.StartPos) <= PosTolerance) and
             (new.LastTime <= last.LastTime + time_step*1.5) then  //tolerancja 150% kroku na błedy zaokrągleń
          begin
            with new do
            begin
              if MaxValue < last.MaxValue then
                MaxValue := last.MaxValue;
              StartPos := last.StartPos; //(MeanPos + last.MeanPos)/2; //zmienić na lepsze uśrednienie
              StartTime := last.StartTime;
              if last.Count < 5 then //uśrendniamy pierwszych n=5 pozycji
              begin
                PosSum := PosSum + last.PosSum;
                Count := last.Count + 1;
              end
              else
              begin
                PosSum :=last.PosSum;
                Count := last.Count;
              end;
              FMaximums.Remove(last);
            end
          end
          else
            Inc(i); //przesuwamy gdy nie usuwamy
        end;
      end
    end;
  end;


  //kopiowanie alarmowych maksimów do listy zdarzeń
  i := 0;
  while i < FMaximums.Count do
  begin
    last := FMaximums[i] as TMaximum;
    if last.LastTime+time_step < time then
    begin
      if last.MaxValue > DerivativeAlarmValue then
      begin
        SetLength(AEventList, Length(AEventList)+1);
        with AEventList[Length(AEventList)-1] do
        begin
          Position := last.StartPos;// last.PosSum/last.Count;
          Time := last.StartTime;
          Value := last.MaxValue;
        end;
      end;
      FMaximums.Remove(last)
    end
    else
      Inc(i);

  end;

end;


end.
