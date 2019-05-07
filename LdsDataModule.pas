unit LdsDataModule;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Data.DB, MemDS, DBAccess,
  MSAccess, System.Math,
  DateUtils, ProfilerDataModule, Variants, AppLogs,
  Vcl.Dialogs, LdsPipeline, LdsTrend, LdsTrendDB, LdsTrendCalc, CL;


const
  c_device_types:array[1..3] of cardinal=(CL_DEVICE_TYPE_CPU, CL_DEVICE_TYPE_GPU, CL_DEVICE_TYPE_ACCELERATOR);

type
	// platform+device_type couples
	t_platform_device=record
		platform_id: cl_platform_id; // index for platform_id
		device_type: cl_device_type; // CL_DEVICE_TYPE_CPU; CL_DEVICE_TYPE_GPU; CL_DEVICE_TYPE_ACCELERATOR
	end;

type

  TTrendType = (ttNormal, ttCalc);

  TdatLDS = class(TDataModule)
    qryQuickTrendDefs: TMSQuery;
    qryQuickTrendDefsID: TIntegerField;
    qryQuickTrendDefsNAME: TStringField;
    qryQuickTrendDefsTIME_EXPONENT: TIntegerField;
    qryQuickTrendDefsRAW_MIN: TIntegerField;
    qryQuickTrendDefsRAW_MAX: TIntegerField;
    qryQuickTrendDefsSCALED_MIN: TFloatField;
    qryQuickTrendDefsSCALED_MAX: TFloatField;
    qryQuickTrendDefsHOST_NAME: TStringField;
    qryQuickTrendDefsPORT_NO: TIntegerField;
    qryQuickTrendDefsSLAVE_ID: TIntegerField;
    qryQuickTrendDefsBEGIN_ADDR: TIntegerField;
    qryPipelines: TMSQuery;
    connTest: TMSConnection;
    qryPipelinesID: TIntegerField;
    qryPipelinesPIPELINE_ID: TIntegerField;
    qryPipelinesSYMBOL: TStringField;
    qryPipelinesDESCRIPTION: TStringField;
    qryPipelinesPRESSURE1_ID: TIntegerField;
    qryPipelinesTEMPERATURE1_ID: TIntegerField;
    qryPipelinesFLOW1_ID: TIntegerField;
    qryPipelinesDENSITY1_ID: TIntegerField;
    qryPipelinesVALVE1_ID: TIntegerField;
    qryPipelinesPUMP1_ID: TIntegerField;
    qryPipelinesPRESSURE2_ID: TIntegerField;
    qryPipelinesTEMPERATURE2_ID: TIntegerField;
    qryPipelinesFLOW2_ID: TIntegerField;
    qryPipelinesDENSITY2_ID: TIntegerField;
    qryPipelinesVALVE2_ID: TIntegerField;
    qryPipelinesPUMP2_ID: TIntegerField;
    qryPipelinesBEGIN_POS: TFloatField;
    qryPipelinesEND_POS: TFloatField;
    qryPipelinesWAVE_METHOD_RATIO: TFloatField;
    qryPipelinesMASS_METHOD_RATIO: TFloatField;
    qryPipelinesWAVE_METHOD_TYPE: TIntegerField;
    qryPipelinesMASS_METHOD_TYPE: TIntegerField;
    qryQuickTrendCalcs: TMSQuery;
    qryQuickTrendCalcsID: TIntegerField;
    qryQuickTrendCalcsMETHOD: TStringField;
    qryQuickTrendCalcsPARAM1: TIntegerField;
    qryQuickTrendCalcsPARAM2: TIntegerField;
    qryQuickTrendCalcsNAME: TStringField;
    qryQuickTrendCalcsSIUNIT: TStringField;
    qryQuickTrendCalcsWINDOW: TIntegerField;
    qryQuickTrendDefsSIUNIT: TStringField;
    qryPipelineNodes: TMSQuery;
    qryPipelineNodesID: TIntegerField;
    qryPipelineNodesTYPE: TStringField;
    qryPipelineNodesPOSITION: TFloatField;
    qryPipelineNodesTREND_ID: TIntegerField;
    qryPipelineNodesCALC_TREND_ID: TIntegerField;
    qryPipelinesWAVE_METHOD_MIN: TFloatField;
    qryPipelinesWAVE_METHOD_MAX: TFloatField;
    qryPipelinesWAVE_METHOD_BASE_SPEED: TFloatField;
    qryPipelinesWAVE_METHOD_ALARM: TFloatField;
    qryQuickTrendCalcsTIME_EXPONENT: TIntegerField;
  private
    { Private declarations }
    FTrends: Array of TTrend;
    FCalcTrends: Array of TTrend;
    FPipeline: TPipeline;
    conMain: TMSConnection;
    FCLContext: cl_context;
    FCLDevice: cl_device_id;
    FCLPlatformNo: Integer;
    FCLDeviceNo: Integer;

    function GetTrend(index: Integer): TTrend;
    function GetTrendCount: Integer;
    function LogEvent(AVerbosityLevel : TVerbosityLevel; AMessage : string): string;
    function GetCalcTrendCount: Integer;
    function GetCalcTrend(index: Integer): TTrend;

  public
    AppLogs: TAppLogs;

    Pressure1: TTrend;
    Pressure2: TTrend;
    Temperature1: TTrend;
    Temperature2: TTrend;
    Flow: TTrend;

    property TrendCount: Integer read GetTrendCount;
    property Trends[index: Integer]: TTrend read GetTrend;

    property CalcTrendCount: Integer read GetCalcTrendCount;
    property CalcTrends[index: Integer]: TTrend read GetCalcTrend;

    constructor Create(Owner: TComponent; AConnection: TMSConnection; ACLPlatformNo:Integer; ACLDeviceNo:Integer; ALogs: TAppLogs = nil);
    destructor Destroy; override;

    function BuildPipeline(PipelineID: Integer): TPipeline;
    function GetTrendByID(AID: Integer; AType: TTrendType = ttNormal): TTrend;
  end;

var
  datLDS: TdatLDS;


implementation

{$R *.dfm}

{ TdatLDS }


constructor TdatLDS.Create(Owner: TComponent; AConnection: TMSConnection; ACLPlatformNo:Integer; ACLDeviceNo:Integer; ALogs: TAppLogs);
var
  i: Integer;

  errcode_ret: cl_int;
  platform_devices: array of t_platform_device;
  num_devices_returned, num_platforms_returned: cl_uint;
  device_ids: array of cl_device_id; // compute device IDs
  platform_id: array of cl_platform_id;
  trend_count: Integer;


begin
  inherited Create(Owner);
  conMain := AConnection;
  qryQuickTrendDefs.Connection := AConnection;
  qryPipelineSegments.Connection := AConnection;
  qryPipelines.Connection := AConnection;
  AppLogs := ALogs;

  FCLPlatformNo := ACLPlatformNo;
  FCLDeviceNo := ACLDeviceNo;
  FCLContext := nil;
  FCLDevice := nil;

  try

    if ((FCLPlatformNo<0) or (FCLDeviceNo<0)) then
    begin
      LogEvent(vlWarning, 'OpenCL CPU emulation forced' );

    end else

    //Budowanie cl_context
    if OpenCL_loaded and (ACLPlatformNo > -1) and (ACLDeviceNo > -1) then
    try
      // Get platforms
      errcode_ret:=clGetPlatformIDs(0, nil, @num_platforms_returned);
      SetLength(platform_id, num_platforms_returned);
      errcode_ret:=clGetPlatformIDs(num_platforms_returned, @platform_id[0], @num_platforms_returned);
      if (errcode_ret <> CL_SUCCESS) then begin
        raise Exception.Create('clGetPlatformIDs: ' + IntToStr(errcode_ret) );
      end;

      // Get compute devices from platform
      errcode_ret:=clGetDeviceIDs(platform_id[FCLPlatformNo], CL_DEVICE_TYPE_ALL, 0, nil, @num_devices_returned);
      SetLength(device_ids, num_devices_returned);
      errcode_ret:=clGetDeviceIDs(platform_id[FCLPlatformNo], CL_DEVICE_TYPE_ALL, num_devices_returned, @device_ids[0], @num_devices_returned);
      FCLDevice := device_ids[FCLDeviceNo];
      if (errcode_ret<>CL_SUCCESS) then begin
        raise Exception.Create('clGetDeviceIDs: ' + IntToStr(errcode_ret) );
      end;

      // Create a compute context
      FCLContext := clCreateContext(nil, 1, @FCLDevice, nil, nil, @errcode_ret);
      if (errcode_ret<>CL_SUCCESS) then begin
        raise Exception.Create('clCreateContext: ' + IntToStr(errcode_ret) );
      end;
    except
      on E: Exception do
      begin
        LogEvent(vlWarning, 'Unable to initialize OpenCL: ' +E.Message );
        FCLContext := nil;
        FCLDevice := nil;
      end;
    end
    else
      LogEvent(vlWarning, 'OpenCL not installed' );


    //³adowanie trendów
    qryQuickTrendDefs.Connection := conMain;
    qryQuickTrendDefs.Active := True;
    qryQuickTrendDefs.First;
    SetLength(FTrends, qryQuickTrendDefs.RecordCount);
    trend_count := Length(FTrends);
    for i := 0 to trend_count - 1 do
    begin
      //FTrends[i] := TTrendDB.Create(qryQuickTrendDefsID.Value, conMain.Server, conMain.Database, conMain.Username, conMain.Password);
      FTrends[i] := TTrendDB.Create(qryQuickTrendDefsID.Value, conMain);
      FTrends[i].AppLogs := AppLogs;
      with FTrends[i] as TTrendDB do
      begin
        //skalowanie
        TimeExponent := qryQuickTrendDefsTIME_EXPONENT.Value;
        RawMin := qryQuickTrendDefsRAW_MIN.Value;
        RawMax := qryQuickTrendDefsRAW_MAX.Value;
        ScaledMin := qryQuickTrendDefsSCALED_MIN.Value;
        ScaledMax := qryQuickTrendDefsSCALED_MAX.Value;
        //modbus
        HostName := qryQuickTrendDefsHOST_NAME.Value;
        PortNo := qryQuickTrendDefsPORT_NO.Value;
        SlaveID := qryQuickTrendDefsSLAVE_ID.Value;
        BeginAddr := qryQuickTrendDefsBEGIN_ADDR.Value;
        Name := qryQuickTrendDefsNAME.Value;
        SIUnit := qryQuickTrendDefsSIUNIT.Value;

        LogEvent(vlDebug, 'LDSDataModule Trend created: ' + IntToStr(FTrends[i].TrendDef) + ' ' + HostName + ' ' +  IntToStr(BeginAddr));
      end;
      qryQuickTrendDefs.Next;
    end;

    //³adowanie trendów liczonych
    qryQuickTrendCalcs.Connection := conMain;
    qryQuickTrendCalcs.Active := True;
    qryQuickTrendCalcs.First;
    SetLength(FCalcTrends, qryQuickTrendCalcs.RecordCount);
    for i := 0 to Length(FCalcTrends) - 1 do
    begin
      if qryQuickTrendCalcsMETHOD.Value = 'DERIV' then
        FCalcTrends[i] := TTrendDeriv.Create(qryQuickTrendCalcsID.Value, GetTrendByID(qryQuickTrendCalcsPARAM1.Value), qryQuickTrendCalcsWINDOW.Value)
      else if qryQuickTrendCalcsMETHOD.Value = 'MEAN' then
        FCalcTrends[i] := TTrendMean.Create(qryQuickTrendCalcsID.Value, GetTrendByID(qryQuickTrendCalcsPARAM1.Value), qryQuickTrendCalcsWINDOW.Value)
      else
        raise Exception.Create('Wrong calc tend method');
      FCalcTrends[i].AppLogs := AppLogs;
      (FCalcTrends[i] as TTrendCalc).CLContext := FCLContext;
      (FCalcTrends[i] as TTrendCalc).CLDevice := FCLDevice;
      (FCalcTrends[i] as TTrendCalc).Name := qryQuickTrendCalcsNAME.Value;
      (FCalcTrends[i] as TTrendCalc).SIUnit := qryQuickTrendCalcsSIUNIT.Value;
      (FCalcTrends[i] as TTrendCalc).TimeExponent := qryQuickTrendCalcsTIME_EXPONENT.Value;

      LogEvent(vlDebug, 'LDSDataModule Trend derivative created: ' + IntToStr(FCalcTrends[i].TrendDef));
      qryQuickTrendCalcs.Next;
    end;

  except
    on E: Exception do
      LogEvent(vlFatal, 'LDSDataModule Trends creating FATAL ' +E.Message );
  end;

end;

destructor TdatLDS.Destroy;
begin
  if Assigned(FCLContext) then
    clReleaseContext(FCLContext);

  inherited;
end;

function TdatLDS.BuildPipeline(PipelineID: Integer): TPipeline;

var
  v: Variant;
  i,j: Integer;
  trends: array of TTrend;
  pipelines: array of TPipeline;

begin

  qryPipelines.Connection := conMain;
  qryPipelines.Active := True;
  qryPipelines.Locate('ID', PipelineID,[]);
  Result := TPipeline.Create();
  with Result do
  begin
    BeginPos := qryPipelinesBEGIN_POS.Value;
    EndPos := qryPipelinesEND_POS.Value;
  end;

  qryPipelineSegments.Connection := conMain;
  qryPipelineSegments.Active := False;
  qryPipelineSegments.ParamByName('PIPELINE_ID').Value := PipelineID;
  qryPipelineSegments.Active := True;
  qryPipelineSegments.First;
  for i := 0 to qryPipelineSegments.RecordCount - 1 do
  begin
    Result.Segments[i] := TSegment.Create();
    Result.Segments[i].AppLogs := AppLogs;
    with Result.Segments[i] do
    begin
      BeginPos := qryPipelineSegmentsBEGIN_POS.Value;
      EndPos := qryPipelineSegmentsEND_POS.Value;

      //tu dodaæ ³adowanie metod ró¿nych typów
      Methods[0] := TWaveMethod.Create(Result.Segments[i]);
      with Result.Segments[i].Methods[0] as TWaveMethod do
      begin
        DerivativeMinimumValue := qryPipelineSegmentsWAVE_METHOD_MIN.Value;
        DerivativeMaximumValue := qryPipelineSegmentsWAVE_METHOD_MAX.Value;
        DerivativeAlarmValue := qryPipelineSegmentsWAVE_METHOD_ALARM.Value; //do usuniêcia i zat¹pienia wartoœcia AlarmLevel w segmencie
        BaseWaveSpeed := qryPipelineSegmentsWAVE_METHOD_BASE_SPEED.Value;
        BaseDumping := 0; //dodaæ do BD
      end;

      Methods[1] := TMaskMethod.Create(Result.Segments[i]);
      with Result.Segments[i].Methods[1] as TMaskMethod do
      begin
        MaskTrend := GetTrendByID(qryPipelineSegmentsVALVE1_ID.Value); //TODO: odzielna konfiguracja dla metod
      end;

      Methods[2] := TBalanceMethod.Create(Result.Segments[i]);
      with Result.Segments[i].Methods[2] as TBalanceMethod do
      begin
        Flow1Trend := GetTrendByID(qryPipelineSegmentsFLOW1_ID.Value, ttCalc); //TODO: odzielna konfiguracja dla metod
        Flow2Trend := GetTrendByID(qryPipelineSegmentsFLOW2_ID.Value, ttCalc);
        Pressure1Trend := GetTrendByID(qryPipelineSegmentsPRESSURE1_ID.Value, ttCalc);
        Pressure2Trend := GetTrendByID(qryPipelineSegmentsPRESSURE2_ID.Value, ttCalc);
      end;

      //uzupe³nic ³adowanie
      qryPipelineNodes.Connection := conMain;
      qryPipelineNodes.Active := False;
      qryPipelineNodes.ParamByName('PIPELINE_SEGMENT_ID').Value := qryPipelineSegmentsID.Value;
      qryPipelineNodes.Active := True;
      qryPipelineNodes.First;
      for j := 0 to qryPipelineNodes.RecordCount - 1 do
      begin
        if qryPipelineNodesTYPE.Value = 'VALVE' then
          Result.Segments[i].Nodes[Result.Segments[i].NodeCount] := TValveNode.Create(qryPipelineNodesPOSITION.Value, GetTrendByID(qryPipelineNodesTREND_ID.Value))
        else if qryPipelineNodesTYPE.Value = 'PRESS' then
          Result.Segments[i].Nodes[Result.Segments[i].NodeCount] := TPressureNode.Create(qryPipelineNodesPOSITION.Value, GetTrendByID(qryPipelineNodesCALC_TREND_ID.Value ,ttCalc));
        qryPipelineNodes.Next;
      end;

    end;
    qryPipelineSegments.Next;
  end;



end;

function TdatLDS.GetCalcTrendCount: Integer;
begin
  Result := Length(FCalcTrends);
end;

function TdatLDS.GetCalcTrend(index: Integer): TTrend;
begin
  Result := FCalcTrends[index];
end;

function TdatLDS.GetTrendCount: Integer;
begin
  Result := Length(FTrends);
end;

function TdatLDS.GetTrend(index: Integer): TTrend;
begin
  Result := FTrends[index];
end;

function TdatLDS.LogEvent(AVerbosityLevel: TVerbosityLevel;
  AMessage: string): string;
begin
  if Assigned(AppLogs) then
    AppLogs.LogEvent(AVerbosityLevel, AMessage);

end;

function TdatLDS.GetTrendByID(AID: Integer; AType: TTrendType): TTrend;
var
  i: Integer;
begin
  Result := nil;

  if AType = ttNormal then
  begin
    for i := 0 to Length(FTrends)-1 do
      if FTrends[i].TrendDef = AID then
      begin
        Result := FTrends[i];
        break;
      end;
  end
  else
  begin
    for i := 0 to Length(FCalcTrends)-1 do
      if FCalcTrends[i].TrendDef = AID then
      begin
        Result := FCalcTrends[i];
        break;
      end;
  end

end;

end.
