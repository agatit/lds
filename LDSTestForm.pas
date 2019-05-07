unit LDSTestForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils,  System.DateUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids,
  LdsDataModule, Vcl.ComCtrls, Vcl.StdCtrls, System.Types, System.IOUtils,
  System.Math, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs,
  VCLTee.Chart, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxCore, cxDateUtils, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, Vcl.Samples.Spin, VCLTee.TeeGDIPlus, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  DBAccess, MSAccess, dxSkinsCore, Data.DB, AppLogs, AppParams, LdsPipeline, uSmoothInternalControls,
  Vcl.ExtDlgs, LdsTrend, LdsTrendDB, LdsTrendCalc, VCLTee.TeeShape, uSmoothBaseControl, uSmoothColorGraph,
  VCLTee.TeeFunci, SdacVcl, Vcl.CheckLst, cxCheckBox, cxCheckComboBox;

const
  SEC_PER_DAY = 86400;
  MSEC_PER_DAY = 86400000;

type
  TPlotDef = class(TObject)
    Offset: Double;
    Factor: Double;
    Trend: TTrend;
    Series: TChartSeries;
    constructor Create();
    destructor Destroy(); override;
  end;

  TfrmTest = class(TForm)
    FileOpenDialog1: TFileOpenDialog;
    btnPlotChunk: TButton;
    TeeGDIPlus1: TTeeGDIPlus;
    conMain: TMSConnection;
    AppLogs: TAppLogs;
    IniParamSet: TIniParamSet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dtStart: TcxDateEdit;
    edtTimeResolution: TSpinEdit;
    edtTime: TSpinEdit;
    GroupBox3: TGroupBox;
    dlgSaveData: TSaveTextFileDialog;
    btnDate1: TButton;
    btnDate2: TButton;
    btnDate3: TButton;
    btnDate4: TButton;
    btnRaw: TButton;
    SmoothColorGraph1: TSmoothColorGraph;
    cbDeriv1: TCheckBox;
    cbDeriv2: TCheckBox;
    cbDeriv3: TCheckBox;
    cbDeriv4: TCheckBox;
    MSConnectDialog1: TMSConnectDialog;
    btnNow: TButton;
    pcTabs: TPageControl;
    TabSheet1: TTabSheet;
    btnLoadTimePlot: TButton;
    btnPrev: TButton;
    btnNext: TButton;
    btnSaveToFile: TButton;
    chaTime: TChart;
    FastLineSeries4: TFastLineSeries;
    LineSeries1: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series9: TLineSeries;
    TimeSlice: TTabSheet;
    Label14: TLabel;
    lblSliceTime: TLabel;
    chaTimeSlice: TChart;
    FastLineSeries1: TFastLineSeries;
    Series4: TFastLineSeries;
    btnReadTimeSlice: TButton;
    btnReadTimeSliceMinus: TButton;
    btnReadTimeSlicePlus: TButton;
    tabPosSlice: TTabSheet;
    Label9: TLabel;
    lblSlicePos: TLabel;
    chaPosSlice: TChart;
    FastLineSeries3: TFastLineSeries;
    Series5: TFastLineSeries;
    btnReadPosSlice: TButton;
    btnReadPosSliceMinus: TButton;
    btnReadPosSlicePlus: TButton;
    TabSheet3: TTabSheet;
    chaMaximum: TChart;
    FastLineSeries2: TFastLineSeries;
    Series3: TFastLineSeries;
    btnMax: TButton;
    lbTrends: TCheckListBox;
    Label7: TLabel;
    Label11: TLabel;
    edtDerivativeMax: TSpinEdit;
    edtDerivativeMin: TSpinEdit;
    Label10: TLabel;
    edtProportion: TSpinEdit;
    Label13: TLabel;
    edtWaveSpeed: TSpinEdit;
    Label12: TLabel;
    edtDumping: TSpinEdit;
    Label4: TLabel;
    edtDerivativeAlarm: TSpinEdit;
    GroupBox2: TGroupBox;
    lbSegments: TListBox;
    GroupBox4: TGroupBox;
    ListBox2: TListBox;
    GroupBox5: TGroupBox;
    Label18: TLabel;
    edtMinPos: TSpinEdit;
    Label6: TLabel;
    edtMaxPos: TSpinEdit;
    Label5: TLabel;
    edtLengthResolution: TSpinEdit;
    btnMax2D: TButton;
    TabSheet2: TTabSheet;
    chaReflections: TChart;
    lbReflections: TCheckListBox;
    lbMaximums: TListBox;
    btnAddRef: TButton;
    btnDelRef: TButton;
    edtOffsetRef: TEdit;
    edtFactorRef: TEdit;
    cbTrendsRef: TComboBox;
    Label8: TLabel;
    Label15: TLabel;
    dtStartRef: TcxDateEdit;
    btnUpdateRef: TButton;
    btnCalcWindow: TButton;
    cbMethods: TcxCheckComboBox;
    procedure btnPlotChunkClick(Sender: TObject);
//    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnLoadTimePlotClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure chaMouseDownOnTime(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnReadTimeSliceClick(Sender: TObject);
    procedure btnMaxClick(Sender: TObject);
    procedure btnReadPosSliceClick(Sender: TObject);
    procedure chaMouseDownOnPos(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure SmoothColorGraph1GetDataInThread(Sender: TObject; const Rect: TRectDouble;
      const ExpectedPointCount: TPoint; var Data: TSmoothColorGraphGetDataArray; var ReplaceMarks: Boolean;
      var Marks: TSmoothColorGraphMarkArray);
    procedure btnDate1Click(Sender: TObject);
    procedure btnDate2Click(Sender: TObject);
    procedure chaTimeAfterDraw(Sender: TObject);
    procedure btnDate3Click(Sender: TObject);
    procedure btnDate4Click(Sender: TObject);
    procedure btnRawClick(Sender: TObject);
    procedure btnCorrelPlotClick(Sender: TObject);
    procedure SmoothColorGraph1MouseButtonDown(Sender: TObject; X, Y: Double;
      State: TShiftState; Area: TSmoothGraphOnMouseDownArea);
    procedure btnNowClick(Sender: TObject);
    procedure lbSegmentsClick(Sender: TObject);
    procedure btnMax2DClick(Sender: TObject);
    procedure FloatEditExit(Sender: TObject);
    procedure lbReflectionsClickCheck(Sender: TObject);
    procedure btnAddRefClick(Sender: TObject);
    procedure btnDelRefClick(Sender: TObject);
    procedure btnUpdateRefClick(Sender: TObject);
    procedure lbReflectionsClick(Sender: TObject);
    procedure btnCalcWindowClick(Sender: TObject);
    procedure cxCheckComboBox1PropertiesChange(Sender: TObject);
  private
    { Private declarations }
    StartData: TDateTime;
    FLastLength, FLastLengthResolution, FLastWindow, FLastTime, FLastTimeResolution: Integer;
//    FGraphBmp: TGPBitmap;

    FPipeline: TPipeline;
    FSegment: TPipeline;
    FMaxFinder: TMaxFinder;
    FProbMap: TProbList;
    FLastTimeSlice1: TDateTime;
    FLastPosSlice1: Double;
    FLastTimeSlice2: TDateTime;
    FLastPosSlice2: Double;
    FMiddle: TDateTime;
    FMethods: TLdsLayers;

    procedure PlotMax();
    procedure PlotMax2();
    procedure PlotTimeSlice(ATime: TDateTime; ASeries: TChartSeries);
    procedure PlotPosSlice(APos: Double; ASeries: TChartSeries);
    procedure AddAllReflections(APos: Double; ATime: TDateTime);
    procedure AddReflection(AOffset: TDateTime; AFactor: Double; ATrend: TTrend);
    procedure PlotReflections();
    procedure SetDetectionParams;
    procedure GetDetectionParams;
    procedure PlotTrend(ATrend: TTrend; ASeries: TChartSeries; AStart:TDateTime;  AOffset: TDateTime = 0; AFactor: Double = 1);
    procedure LoadSegments;
    procedure SelectSegment(ASegment: TPipeline);
    procedure LoadTrends;

  public
    { Public declarations }

  end;

var
  frmTest: TfrmTest;

implementation

{$R *.dfm}


uses
  ProfilerDataModule;


procedure TfrmTest.btnAddRefClick(Sender: TObject);
begin
  if Assigned(cbTrendsRef.Items.Objects[cbTrendsRef.ItemIndex]) then
    AddReflection(StrToFloat(edtOffsetRef.Text)*OneSecond, StrToFloat(edtFactorRef.Text), cbTrendsRef.Items.Objects[cbTrendsRef.ItemIndex] as TTrend);
  PlotReflections;
end;

procedure TfrmTest.btnDelRefClick(Sender: TObject);
var
  i: Integer;
  def: TPlotDef;
begin
  i := lbReflections.ItemIndex;
  if i <> -1 then
  begin
    def := lbReflections.Items.Objects[i] as TPlotDef;
    lbReflections.Items.Delete(i);
    def.Series.Free;
  end;
  PlotReflections;
end;

procedure TfrmTest.btnUpdateRefClick(Sender: TObject);
var
  i: Integer;
  def: TPlotDef;
begin
  i := lbReflections.ItemIndex;
  if i <> -1 then
  begin
    def := lbReflections.Items.Objects[i] as TPlotDef;
    def.Offset := StrToFloat(edtOffsetRef.Text)*OneSecond;
    def.Factor := StrToFloat(edtFactorRef.Text);

    PlotTrend(def.Trend, def.Series, def.Offset, def.Factor);
  end;
  PlotReflections;
end;

procedure TfrmTest.btnCalcWindowClick(Sender: TObject);
var
  i: Integer;
  first, last: Cardinal;

  dat: TProbList;
  events: TProbList;
  pos_min: Double;
  pos_max: Double;
  pos_count: Word;
  time_min: TDateTime;
  time_max: TDateTime;
  time_count: Word;

begin
  {
  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  time_min := dtStart.Date;
  time_max := dtStart.Date+edtTime.Value*OneSecond;
  time_count := edtTimeResolution.Value;

  FPipeline.GetProbabilityList(dat, events,
                      pos_min, pos_max, pos_count,
                      time_min, time_max, time_count,
                      FMethods);
   }

FPipeline.GetProbabilityList(dat, events,
  26,
  384,
  717,
  43342.5511352778,
  43342.5532186111,
  201,
  llResult
);

end;

procedure TfrmTest.lbReflectionsClick(Sender: TObject);
var
  i,j: Integer;
  def: TPlotDef;
begin
  i := lbReflections.ItemIndex;
  if i <> -1 then
  begin
    def := lbReflections.Items.Objects[i] as TPlotDef;
    edtOffsetRef.Text := FloatToStr(def.Offset/OneSecond);
    edtFactorRef.Text := FloatToStr(def.Factor);

    for j := 0 to cbTrendsRef.Items.Count-1  do
      if (cbTrendsRef.Items.Objects[j] as TTrend) = def.Trend then
      begin
        cbTrendsRef.ItemIndex := j;
        break;
      end;
  end;
end;

procedure TfrmTest.btnCorrelPlotClick(Sender: TObject);
begin
  //PlotCorrelation(datLDS.GetTrendByID(1), datLDS.GetTrendByID(2), chaCorrel.Series[0], dtStart.Date, edtOffset.Value*OneMillisecond);
  //PlotCorrelation(datLDS.GetTrendByID(11), datLDS.GetTrendByID(10), chaCorrel.Series[1], dtStart.Date, edtOffset.Value*OneMillisecond);
end;

procedure TfrmTest.btnDate1Click(Sender: TObject);
begin
  dtStart.Date := StrToDateTime('2016-07-28 07:58:00');
  btnPlotChunkClick(Sender);
end;

procedure TfrmTest.btnDate2Click(Sender: TObject);
begin
  dtStart.Date := StrToDateTime('2016-07-28 08:46:20');
  btnPlotChunkClick(Sender);
end;


procedure TfrmTest.btnDate3Click(Sender: TObject);
begin
  dtStart.Date := StrToDateTime('2016-07-28 08:13:25');
  btnPlotChunkClick(Sender);
end;

procedure TfrmTest.btnDate4Click(Sender: TObject);
begin
  dtStart.Date := StrToDateTime('2016-07-28 08:59:30');
  btnPlotChunkClick(Sender);
end;

procedure TfrmTest.PlotTrend(ATrend: TTrend; ASeries: TChartSeries; AStart: TDateTime;  AOffset: TDateTime = 0; AFactor: Double = 1);
var
  data: array of Double;
  i: Integer;
  index: TSampleIndex;
  val: Double;
  first, last: Cardinal;
begin
  ASeries.Clear;
  index := ATrend.DateTimeToIndex(AStart+AOffset);

  first := index.Chunk;
  last := ATrend.DateTimeToIndex(AStart+(edtTime.Value*OneSecond)+AOffset).Chunk;
  ATrend.UpdateCache(first, last);

  for i := 0 to Round(edtTime.Value*OneSecond/ATrend.SampleTime)-1 do
  begin
    val := ATrend.GetValue(index, True);
    //val := ATrend.GetValue(index);
    if not IsNaN(val) then
      ASeries.AddXY(AStart + i*ATrend.SampleTime, val*AFactor);
    ATrend.IncIndex(index);
  end;
end;


procedure TfrmTest.btnLoadTimePlotClick(Sender: TObject);
var
  i: Integer;
  series: TChartSeries;
begin
  chaTime.BottomAxis.SetMinMax(dtStart.Date, dtStart.Date + edtTime.Value * OneSecond);

  chaTime.SeriesList.Clear;
  for i := 0 to lbTrends.Count-1 do
  begin
    if lbTrends.Checked[i] then
    begin
      series := chaTime.AddSeries(TLineSeries);
      chaTime.Axes.Left.Automatic := True;
      chaTime.Axes.Right.Automatic := True;
      series.HorizAxis := aBottomAxis;
      series.XValues.DateTime := True;
      if lbTrends.Items.Objects[i] is TTrendCalc then
        series.VertAxis := aLeftAxis
      else
        series.VertAxis := aRightAxis;
      PlotTrend(lbTrends.Items.Objects[i] as TTrend, series, dtStart.Date)
    end;
  end;
end;

procedure TfrmTest.btnMax2DClick(Sender: TObject);
var
  i,k1, k2: Integer;
  step: Integer;

  time_min, time_max, time, time_step: TDateTime;
  time_count: Word;

  pos_min, pos_max, pos, pos_step: Double;
  pos_count: Word;

  pos_found, val_found: Double;

  data: TProbMap;
  events: TProbList;
begin

  time_min := dtStart.Date;
  time_max := dtStart.Date + OneSecond*edtTime.Value ;
  time_count :=  edtTimeResolution.Value;
  time_step := (time_max - time_min)/(time_count-1);

  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  pos_step := (pos_max - pos_min)/(pos_count-1);

  SetDetectionParams;

  SetLength(data, pos_count, time_count);
  FPipeline.GetProbabilityMap(data, events, pos_min, pos_max, 0, pos_count-1, time_min, time_max, 0, time_count-1, llResult);


  SetLength(events,0);
  FMaxFinder.Find(data, events, pos_min, pos_max, 0, pos_count-1, time_min, time_max, 0, time_count-1, edtDerivativeAlarm.Value/10000, (pos_max-pos_min)/2);

  // test podziału na bloki
  {
  step := 2;
  for i := 0 to (time_count div step)-1 do
  begin
    k1 := step*i;
    k2 := step*(i+1)-1;
    FMaxFinder.Find(data, events, pos_min, pos_max, 0, pos_count-1, time_min+k1*time_step, time_min+k2*time_step, k1, k2, edtDerivativeAlarm.Value/10000, (pos_max-pos_min)/2);
  end;
  }

  SmoothColorGraph1.Marks.Clear;
  lbMaximums.Clear;

  for i := 0 to Length(events)-1 do
  begin
    with SmoothColorGraph1.Marks.Add do
    begin
      X := events[i].Position;
      Y := events[i].Time;
      Color := clYellow;
    end;
    lbMaximums.AddItem(FloatToStr(events[i].Position) + ' ' + FloatToStr(events[i].Value), nil);
  end;


end;

procedure TfrmTest.btnMaxClick(Sender: TObject);
begin
  PlotMax;
end;

procedure TfrmTest.btnPrevClick(Sender: TObject);
begin
  dtStart.Date := dtStart.Date-edtTime.Value/SEC_PER_DAY;
  btnLoadTimePlotClick(Sender);
end;

procedure TfrmTest.btnRawClick(Sender: TObject);
var
  data: TProbMap;
  evants: TProbList;
  llResult:TLdsLayers;
begin
  SetLength(data, 2000, 300);
  FPipeline.Segments[0].GetProbabilityMap(data, evants, 280, 11193, 0, 1090, StrToDateTime('2016-08-02 10:32:08')+816*OneMillisecond , StrToDateTime('2016-08-02 10:33:08')+816*OneMillisecond, 0, 119, llResult);

end;

procedure TfrmTest.btnReadPosSliceClick(Sender: TObject);
var
  pos_min, pos_max, time, pos_step: Double;
  pos_count: Word;
begin
  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  pos_step := (pos_max - pos_min)/(pos_count-1);

  if Sender = btnReadPosSliceMinus then
  begin
    FLastPosSlice1 := FLastPosSlice1 - pos_step;
    FLastPosSlice2 := FLastPosSlice2 - pos_step;
  end;

  if Sender = btnReadPosSlicePlus then
  begin
    FLastPosSlice1 := FLastPosSlice1 + pos_step;
    FLastPosSlice2 := FLastPosSlice2 + pos_step;
  end;

  PlotPosSlice(FLastPosSlice1, chaPosSlice.Series[0]);
  //PlotPosSlice(FLastPosSlice2, chaPosSlice.Series[1]);
end;


procedure TfrmTest.btnReadTimeSliceClick(Sender: TObject);
var
  time_min, time_max, time, time_step: TDateTime;
  time_count: Word;
begin
  time_min := dtStart.Date;
  time_max := dtStart.Date + OneSecond*edtTime.Value ;
  time_count :=  edtTimeResolution.Value;
  time_step := (time_max - time_min)/(time_count-1);

  if Sender = btnReadTimeSliceMinus then
  begin
    FLastTimeSlice1 := FLastTimeSlice1 - time_step;
    FLastTimeSlice2 := FLastTimeSlice2 - time_step;
  end;

  if Sender = btnReadTimeSlicePlus then
  begin
    FLastTimeSlice1 := FLastTimeSlice1 + time_step;
    FLastTimeSlice2 := FLastTimeSlice2 + time_step;
  end;

  PlotTimeSlice(FLastTimeSlice1, chaTimeSlice.Series[0]);
  //PlotPosSlice(FLastPosSlice2, chaPosSlice.Series[1]);
end;

procedure TfrmTest.btnSaveToFileClick(Sender: TObject);
var
  time: TDateTime;
  time_min: TDateTime;
  time_max: TDateTime;
  trends : array[0..3] of TTrend;
  indices : array[0..3] of TSampleIndex;
  value: Word;
  i: integer;
  f: TextFile;
begin

  trends[0] := datLDS.GetTrendByID(1);
  trends[1] := datLDS.GetTrendByID(2);
  trends[2] := datLDS.GetTrendByID(10);
  trends[3] := datLDS.GetTrendByID(11);

  if dlgSaveData.Execute then
  begin
    AssignFile(f, dlgSaveData.FileName);
    try
      Rewrite(f);

      time_min := dtStart.Date;
      time_max := dtStart.Date+edtTime.Value*OneSecond;
      time := time_min;

      for i := Low(trends) to High(trends) do
        indices[i] := trends[i].DateTimeToIndex(time_min);

      while time < time_max do
      begin
        Write(f, DateTimeToUnix(time),'.',Format('%03.3d', [MilliSecondOfTheSecond(time)]));
        for i := Low(trends) to High(trends) do
        begin
          value := trends[i].GetRawValue(indices[i]);
          Write(f, ';', value);
          trends[i].IncIndex(indices[i]);
        end;
        Writeln(f);
        time := trends[0].IndexToDateTime(indices[0]);
      end;
    finally
      CloseFile(f);
    end;
  end;
end;

procedure TfrmTest.chaMouseDownOnTime(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [ssLeft, ssShift] then
  begin
    FLastTimeSlice1 := TChart(Sender).Series[0].XScreenToValue(X);
    PlotTimeSlice(FLastTimeSlice1, chaTimeSlice.Series[0])
  end
  else if Shift = [ssLeft, ssCtrl] then
  begin
    FLastTimeSlice2 := TChart(Sender).Series[0].XScreenToValue(X);
    PlotTimeSlice(FLastTimeSlice2, chaTimeSlice.Series[1]);
  end;
end;

procedure TfrmTest.chaTimeAfterDraw(Sender: TObject);
begin

  if FMiddle <> 0 then
    with (Sender as TChart) do
    begin
      //Canvas.DoVertLine(BottomAxis.CalcXPosValue(FMiddle-edtDerivativeWindow.Value*OneSecond/200), LeftAxis.IStartPos,LeftAxis.IEndPos);
      //Canvas.DoVertLine(BottomAxis.CalcXPosValue(FMiddle+edtDerivativeWindow.Value*OneSecond/200), LeftAxis.IStartPos,LeftAxis.IEndPos);
      //Canvas.DoVertLine(BottomAxis.CalcXPosValue(FMiddle-edtWindow.Value*OneSecond/200), LeftAxis.IStartPos,LeftAxis.IEndPos);
      //Canvas.DoVertLine(BottomAxis.CalcXPosValue(FMiddle+edtWindow.Value*OneSecond/200), LeftAxis.IStartPos,LeftAxis.IEndPos);
      Canvas.DoVertLine(BottomAxis.CalcXPosValue(FMiddle), LeftAxis.IStartPos, LeftAxis.IEndPos);
    end;
end;

procedure TfrmTest.cxCheckComboBox1PropertiesChange(Sender: TObject);
begin
  FMethods := [];
  if cbMethods.States[0] = cbsChecked then
    FMethods := FMethods + [llWave];
  if cbMethods.States[1] = cbsChecked then
    FMethods := FMethods + [llMass];
  if cbMethods.States[2] = cbsChecked then
    FMethods := FMethods + [llMask];
end;

procedure TfrmTest.FloatEditExit(Sender: TObject);
var
  f: Double;
begin
  f := StrToFloat((Sender as TEdit).Text);
end;

procedure TfrmTest.chaMouseDownOnPos(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [ssLeft, ssShift] then
  begin
    FLastPosSlice1 := TChart(Sender).Series[0].XScreenToValue(X);
    PlotPosSlice(FLastPosSlice1, chaPosSlice.Series[0])
  end
  else if Shift = [ssLeft, ssCtrl] then
  begin
    FLastPosSlice2 := TChart(Sender).Series[0].XScreenToValue(X);
    PlotPosSlice(FLastPosSlice2, chaPosSlice.Series[1])
  end;
end;

procedure TfrmTest.btnNextClick(Sender: TObject);
begin
  dtStart.Date := dtStart.Date+edtTime.Value*OneSecond;
  btnLoadTimePlotClick(Sender)
end;


procedure TfrmTest.btnNowClick(Sender: TObject);
begin
  dtStart.Date := TTimeZone.Local.ToUniversalTime(Now);
end;

procedure TfrmTest.btnPlotChunkClick(Sender: TObject);
var
  i,j: Integer;
  max_value: Double;
  max_time: TDateTime;
  max_pos: Double;
  leak: Boolean;

  pos_min: Double;
  pos_max: Double;
  pos_count: Word;
  time_min: TDateTime;
  time_max: TDateTime;
  time_count: Word;

begin

  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  time_min := dtStart.Date;
  time_max := dtStart.Date+edtTime.Value*OneSecond;
  time_count := edtTimeResolution.Value;

  SetDetectionParams;

  SmoothColorGraph1.DataProvider.Cancel;
  SmoothColorGraph1.XAxisDataPPU:=pos_count/(pos_max-pos_min);
  SmoothColorGraph1.YAxis.YAxisDataPPU:=time_count/(time_max-time_min);
  SmoothColorGraph1.SetRect(pos_min, time_min, pos_max-pos_min, time_max-time_min);
end;

procedure TfrmTest.FormCreate(Sender: TObject);

  function StrToVL(AValue: string): TVerbosityLevel;
  begin
    Result := vlWarning;

    if AnsiContainsText(AValue, 'debug') then
      Result := vlDebug
    else
      if AnsiContainsText(AValue, 'warn') then
        Result := vlWarning
      else
        if AnsiContainsText(AValue, 'err') then
          Result := vlError
        else
          if AnsiContainsText(AValue, 'fatal') then
            Result := vlFatal
          else
            if AnsiContainsText(AValue, 'info') then
              Result := vlInfo;
  end;


  function FindVolumeSerial(const Drive : PChar) : string;
  var
     VolumeSerialNumber : DWORD;
     MaximumComponentLength : DWORD;
     FileSystemFlags : DWORD;
     SerialNumber : string;
  begin
     Result:='';

     GetVolumeInformation(
          Drive,
          nil,
          0,
          @VolumeSerialNumber,
          MaximumComponentLength,
          FileSystemFlags,
          nil,
          0) ;
     SerialNumber :=
           IntToHex(HiWord(VolumeSerialNumber), 4) +
           '-' +
           IntToHex(LoWord(VolumeSerialNumber), 4) ;

     Result := SerialNumber;
  end;

var
  CLPlatformNo, CLDeviceNo: Integer;
  dk: String;
begin
  IniParamset.FileName := ExtractFilePath(Application.ExeName) + 'Config\Settings.ini';

  //log file parameters
  AppLogs.FileName := ChangeFileExt(ExtractFileName(Application.ExeName), '.log');
  AppLogs.MaxLogFileSize := IniParamset['Log.MaxFileSize'].AsIntegerDef(20);
  AppLogs.MaxLogFileCount := IniParamset['Log.MaxFileCount'].AsIntegerDef(20);
  AppLogs.HistoricalLogSubdirectory := IniParamset['Log.HistoricalSubdirectory'].AsStringDef('arch');
  AppLogs.MaxLogFileAge := IniParamset['Log.MaxFileAge'].AsIntegerDef(0);
  AppLogs.LogDirectory := IniParamset['Log.Directory'].AsstringDef('');
  AppLogs.VerbosityLevel := StrToVL(IniParamSet['Log.VerbosityLevel'].AsStringDef('Warning'));

  CLPlatformNo := IniParamset['OpenCL.Platform'].AsIntegerDef(-1);
  CLDeviceNo := IniParamset['OpenCL.Device'].AsIntegerDef(-1);

  if (CLPlatformNo >-1) and (CLDeviceNo > -1) then
    frmTest.Caption := frmTest.Caption + ' (OpenCL Platform ' + IntToStr(CLPlatformNo) + ',Device ' +  IntToStr(CLDeviceNo) + ')'
  else
    frmTest.Caption := frmTest.Caption + ' (CPU)';


  dk := FindVolumeSerial('c:\');
  conMain.Server := IniParamset['Database.ServerName'].AsstringDef('serverdb,1446');
  conMain.Database := IniParamset['Database.Database'].Decode(dk);
  conMain.Username := IniParamset['Database.SrvUser'].Decode(dk);
  conMain.Password := IniParamset['Database.SrvPasswd'].Decode(dk);


  conMain.Connected := True;

  datLDS := TdatLDS.Create(Self, conMain, CLPlatformNo, CLDeviceNo, AppLogs);
  LoadTrends;

  FPipeline := datLDS.BuildPipeline(1);
  LoadSegments;

  FMaxFinder := TMaxFinder.Create;

  FLastTimeSlice1 := dtStart.Date;
  FLastPosSlice1 := 0;
  FLastTimeSlice2 := dtStart.Date;
  FLastPosSlice2 := 0;
  FMiddle := 0;

  FMethods := [llMass];

  GetDetectionParams;

end;

procedure TfrmTest.lbReflectionsClickCheck(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to lbReflections.Count-1 do
    (lbReflections.Items.Objects[i] as TPlotDef).Series.Visible := lbReflections.Checked[i];
end;

procedure TfrmTest.lbSegmentsClick(Sender: TObject);
begin
  SelectSegment(lbSegments.Items.Objects[lbSegments.ItemIndex] as TPipeline);
end;

procedure TfrmTest.LoadSegments;
var
  i: Integer;
begin
  for i := 0 to FPipeline.SegmentCount-1 do
  begin
    lbSegments.AddItem(FPipeline.Segments[i].Name, FPipeline.Segments[i]);
  end;
  if FPipeline.SegmentCount > 0 then
  begin
    lbSegments.ItemIndex := 0;
    SelectSegment(FPipeline.Segments[0])
  end
  else
    FSegment := nil;

end;

procedure TfrmTest.SelectSegment(ASegment: TPipeline);
var
  i: Integer;
begin
  if ASegment <> FSegment then
  begin
    FSegment := lbSegments.Items.Objects[lbSegments.ItemIndex] as TPipeline;
    edtMinPos.Value := Round(FSegment.BeginPos);
    edtMaxPos.Value := Round(FSegment.EndPos);
    edtLengthResolution.Value := Round(FSegment.EndPos - FSegment.BeginPos);  //FSegment.ResolutionPos;
  end;
end;


procedure TfrmTest.LoadTrends;
var
  i: Integer;
begin
  for i := 0 to datLDS.TrendCount-1 do
  begin
    lbTrends.AddItem(datLDS.Trends[i].Name, datLDS.Trends[i]);
  end;

  for i := 0 to datLDS.CalcTrendCount-1 do
  begin
    lbTrends.AddItem(datLDS.CalcTrends[i].Name, datLDS.CalcTrends[i]);
    cbTrendsRef.AddItem(datLDS.CalcTrends[i].Name, datLDS.CalcTrends[i]);
  end;

end;

procedure TfrmTest.PlotMax();
var
  i,j: Integer;
  dval: Double;

  time_min, time_max, time, time_step: TDateTime;
  time_count: Word;

  pos_min, pos_max, pos, pos_step: Double;
  pos_count: Word;

  pos_found, val_found: Double;

  data: TProbMap;
  evants: TProbList;
begin

  time_min := dtStart.Date;
  time_max := dtStart.Date + OneSecond*edtTime.Value ;
  time_count :=  edtTimeResolution.Value;
  time_step := (time_max - time_min)/(time_count-1);

  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  pos_step := (pos_max - pos_min)/(pos_count-1);

  SetDetectionParams;

  SetLength(data, pos_count, time_count);
  FPipeline.GetProbabilityMap(data, evants, pos_min, pos_max, 0, pos_count-1, time_min, time_max, 0, time_count-1, llResult);

  chaMaximum.Series[0].Clear;
  chaMaximum.Series[1].Clear;
  SmoothColorGraph1.Marks.Clear;

  time := time_min;
  for j := 0 to time_count-1 do
  begin
    pos := pos_min;

    pos_found := 0;
    val_found := -MaxDouble;
    for i := 0 to pos_count-1 do
    begin
      if data[i,j] > val_found then
      begin
        val_found := data[i,j];
        pos_found := pos;
      end;
      pos := pos + pos_step;
    end;
    chaMaximum.Series[0].AddXY(time, val_found);
    chaMaximum.Series[1].AddXY(time, pos_found);
    with SmoothColorGraph1.Marks.Add do
    begin
      X := pos_found;
      Y := time;
      Color := clYellow;
    end;
    time := time + time_step;
  end;

end;

procedure TfrmTest.PlotMax2;
begin

end;

procedure TfrmTest.PlotPosSlice(APos: Double; ASeries: TChartSeries);
var
  i,j: Integer;
  dval: Double;

  time_min, time_max, time, time_step: Double;
  time_count: Word;

  data: TProbMap;
  events: TProbList;
begin

  time_min := dtStart.Date;
  time_max := time_min + edtTime.Value * OneSecond;
  time_count :=  edtTimeResolution.Value;
  time_step := (time_max - time_min)/(time_count-1);

  SetDetectionParams;

  SetLength(data, 2, time_count);
  FPipeline.GetProbabilityMap(data, events, APos, APos, 0, 0, time_min, time_max, 0, time_count-1, llResult);

  time := time_min;
  ASeries.Clear;
  for i := 0 to time_count-1 do
  begin
    ASeries.AddXY(time, data[0][i]);
    time := time + time_step;
  end;

  lblSlicePos.Caption := FloatToStr(APos);
end;

procedure TfrmTest.PlotTimeSlice(ATime: TDateTime; ASeries: TChartSeries);
var
  i,j: Integer;
  dval: Double;

  pos_min, pos_max, pos, pos_step: Double;
  pos_count: Word;

  data: TProbMap;
  events: TProbList;
begin

  pos_min := edtMinPos.Value;
  pos_max := edtMaxPos.Value;
  pos_count :=  edtLengthResolution.Value;
  pos_step := (pos_max - pos_min)/(pos_count-1);

  SetDetectionParams;

  SetLength(data, pos_count, 2);
  FPipeline.GetProbabilityMap(data, events, pos_min, pos_max, 0, pos_count-1, ATime, ATime, 0, 0, llResult);

  pos := pos_min;
  ASeries.Clear;
  for i := 0 to pos_count-1 do
  begin
    ASeries.AddXY(pos, data[i][0]);
    pos := pos + pos_step;
  end;

  lblSliceTime.Caption := DateTimeToStr(ATime);
end;


procedure TfrmTest.AddAllReflections(APos: Double; ATime: TDateTime);
var
  start, offset: TDateTime;
  trace_count: Integer;
  trace_array: array of TTracePoint;
  i: Integer;
begin
  FMiddle := ATime;

  for i := 0 to lbReflections.Count-1 do
    lbReflections.Items.Objects[i].Free;
  lbReflections.Clear;
  //chaReflections.SeriesList.Clear;

  dtStartRef.Date := ATime;

  SetLength(trace_array, WaveTracesLimit);
  //przyczyny
  trace_count := (FPipeline.Segments[0].Methods[0] as TWaveMethod).GetTracePoints(APos, ATime, -1, trace_array); //hardcode
  for i := Low(trace_array) to trace_count-1 do
  begin
    if Assigned(trace_array[i].Node) then
      AddReflection(trace_array[i].Time-ATime, -1, trace_array[i].Node.Trend);
  end;
  //skutki
  trace_count := (FPipeline.Segments[0].Methods[0] as TWaveMethod).GetTracePoints(APos, ATime, 1, trace_array); //hardcode
  for i := Low(trace_array) to trace_count-1 do
  begin
    if Assigned(trace_array[i].Node) then
      AddReflection(trace_array[i].Time-ATime, 1, trace_array[i].Node.Trend);
  end;

  PlotReflections;
end;

procedure TfrmTest.AddReflection(AOffset: TDateTime; AFactor: Double;
  ATrend: TTrend);
var
  series: TChartSeries;
  def: TPlotDef;
  item: Integer;

begin
  series := chaReflections.AddSeries(TLineSeries);
  series.HorizAxis := aBottomAxis;
  series.XValues.DateTime := True;
  series.VertAxis := aRightAxis;
  series.Color := clGreen;

  def := TPlotDef.Create;
  def.Offset := AOffset;
  def.Factor := AFactor;
  def.Trend := ATrend;
  def.Series := series;

  item := lbReflections.Items.AddObject(def.Trend.Name + ':' + FloatToStr(def.Offset/OneSecond) + ':' + FloatToStr(def.Factor) , def);
  lbReflections.Checked[item] := True;
end;

procedure TfrmTest.PlotReflections;
var
  sum: TChartSeries;
  fun: TTeeFunction;
  i: Integer;
  def: TPlotDef;
begin
  for i := 0 to chaReflections.SeriesCount-1 do
    if Assigned(chaReflections.Series[i].FunctionType) then
    begin
      chaReflections.Series[i].Free;
      break;
    end;

  chaReflections.BottomAxis.SetMinMax(dtStartRef.Date - (edtTime.Value * OneSecond)/2, dtStartRef.Date + (edtTime.Value * OneSecond)/2);

  sum := chaReflections.AddSeries(TLineSeries);
  sum.HorizAxis := aBottomAxis;
  sum.XValues.DateTime := True;
  sum.VertAxis := aRightAxis;
  sum.Color := clBlack;

  for i := 0 to lbReflections.Items.Count-1 do
  begin
    def := lbReflections.Items.Objects[i] as TPlotDef;
    sum.DataSources.Add(def.Series);
    PlotTrend(def.Trend, def.Series, dtStartRef.Date-edtTime.Value*OneSecond/2, def.Offset, def.Factor);
  end;

  sum.SetFunction(TAddTeeFunction.Create(chaReflections));
end;


procedure TfrmTest.SetDetectionParams;
begin
  if Assigned(FSegment) and (FSegment.MethodCount > 0) then
    with FSegment.Methods[0] as TWaveMethod do //hardcode
    begin
      DerivativeMaximumValue := edtDerivativeMax.Value/10000.0;
      DerivativeMinimumValue := edtDerivativeMin.Value/10000.0;
      DerivativeAlarmValue := edtDerivativeMin.Value/10000.0;
      BaseWaveSpeed := edtWaveSpeed.Value;
      BaseDumping := edtDumping.Value / 1000000.0;
      Ratio := edtProportion.Value / 1000.0;
    end;
end;

procedure TfrmTest.GetDetectionParams;
begin
  if Assigned(FSegment) and (FSegment.MethodCount > 0) then
    with FSegment.Methods[0] as TWaveMethod do //hardcode
    begin
      edtDerivativeMax.Value := Round(DerivativeMaximumValue * 10000.0);
      edtDerivativeMin.Value := Round(DerivativeMinimumValue * 10000.0);
      edtDerivativeAlarm.Value := Round(DerivativeAlarmValue * 10000.0);
      edtWaveSpeed.Value := Round(BaseWaveSpeed);
      edtDumping.Value := Round(BaseDumping * 1000000.0);
      edtProportion.Value := Round(Ratio * 1000);
    end;
end;

procedure TfrmTest.SmoothColorGraph1GetDataInThread(Sender: TObject; const Rect: TRectDouble;
  const ExpectedPointCount: TPoint; var Data: TSmoothColorGraphGetDataArray; var ReplaceMarks: Boolean;
  var Marks: TSmoothColorGraphMarkArray);
var
  dat: TProbList;
  events: TProbList;
  l,i,ival: integer;
begin
  prof.TimerStart(1);
  FPipeline.GetProbabilityList(dat, events, Rect.Left, Rect.Right, ExpectedPointCount.X, Rect.Top, Rect.Bottom, ExpectedPointCount.Y, FMethods);

  l:=Length(dat);
  SetLength(Data, l);
  if l>0 then
  begin
    for i := 0 to l-1 do
    begin
      with Data[i] do
      begin
        X := dat[i].Position;
        Y := dat[i].Time;
        ival := min(255, max(0, Round(dat[i].Value*255)));
        //Z:=MakeColor(255,  ifthen(ival>0,ival), ifthen(ival<0,-ival), 255-abs(ival));
        Z:=MakeColor(255, ival, ival, ival);
      end;
    end;
  end;

  SetLength(Marks, Length(events));
  for i := 0 to Length(events)-1 do
  begin
    with Marks[i] do
    begin
      X := events[i].Position;
      Y := events[i].Time;
      color := clYellow;
    end;
  end;
  ReplaceMarks := True;

  //ShowMessage(FloatToStr(Rect.Left) + ' - ' + FloatToStr(Rect.Right) + ' , ' + FloatToStr(Rect.Top) + ' - ' + FloatToStr(Rect.Bottom));
  prof.TimerStop(1);
end;

procedure TfrmTest.SmoothColorGraph1MouseButtonDown(Sender: TObject; X,
  Y: Double; State: TShiftState; Area: TSmoothGraphOnMouseDownArea);
begin
  SetDetectionParams;

  if State = [ssLeft, ssShift] then
  begin
    PlotTimeSlice(Y, chaTimeSlice.Series[0]);
    PlotPosSlice(X, chaPosSlice.Series[0]);
    FLastTimeSlice1 := Y;
    FLastPosSlice1 := X;
  end
  else if State = [ssLeft, ssCtrl] then
  begin
    AddAllReflections(X,Y);
  end;
end;


{ TPlotDef }

constructor TPlotDef.Create;
begin
  inherited;
  Series := nil;
end;

destructor TPlotDef.Destroy;
begin
  if Assigned(Series) then
    Series.Free;
  inherited;
end;

end.

