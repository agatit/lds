program LDSTest;

uses
  Vcl.Forms,
  LdsDataModule in 'LdsDataModule.pas' {datLDS: TDataModule},
  ProfilerDataModule in 'ProfilerDataModule.pas' {datProfiler: TDataModule},
  LDSTestForm in 'LDSTestForm.pas' {frmTest},
  AppLogs in '..\..\Shared6\src_agat\AppLogs.pas',
  AppParams in '..\..\Shared6\src_agat\AppParams.pas',
  EIAESUtils in '..\..\Shared6\src_agat\EIAESUtils.pas',
  ElAES in '..\..\Shared6\src_agat\ElAES.pas',
  LdsPipeline in 'LdsPipeline.pas',
  LdsTrend in 'LdsTrend.pas',
  CL in '..\..\Shared6\src_opencl\CL.pas',
  LdsTrendDB in 'LdsTrendDB.pas',
  LdsTrendCalc in 'LdsTrendCalc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
