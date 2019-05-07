unit ProfilerDataModule;

interface

uses
  Winapi.Windows, SysUtils, Classes, Dialogs;

type
  TTimerData = record
    TimerLast: Uint64;
    TimerSum: Uint64;
    Runs: Uint64;
  end;

  TdatProfiler = class(TDataModule)
  private
    FTimers: Array of TTimerData;
  public

    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;

    procedure TimerStart(const ATimer: Integer); inline;
    function TimerStop(const ATimer: Integer): Cardinal; inline;
    procedure TimerReset(const ATimer: Integer); inline;
  end;

var
  prof: TdatProfiler;

implementation

{$R *.dfm}

{ TdatProfiler }

constructor TdatProfiler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetLength(FTimers, 50);
end;

destructor TdatProfiler.Destroy;
var
  msg: String;
  i: Integer;
  f: TextFile;
begin
  msg := '';
  for i := 0 to Length(FTimers) - 1 do
  begin
    if FTimers[i].Runs > 0 then
      msg := msg + IntToStr(i) + ' - ' + IntToStr(FTimers[i].TimerSum) + '(' + IntToStr(FTimers[i].Runs) + ') ticks'#13#10;
  end;
  if msg <> '' then
  begin
    //ShowMessage(msg);
    AssignFile(f, 'profiler' + FormatDateTime('yyyymmddhhnnss', Now) + '.txt');
    Rewrite(f);
    try
      Write(f, msg);
    finally
      CloseFile(f);
    end;
  end;
  inherited;
end;

procedure TdatProfiler.TimerReset(const ATimer: Integer);
begin
  FTimers[ATimer].TimerSum := 0;
end;

procedure TdatProfiler.TimerStart(const ATimer: Integer);
begin
  FTimers[ATimer].TimerLast := GetTickCount;
end;

function TdatProfiler.TimerStop(const ATimer: Integer): Cardinal;
begin
  FTimers[ATimer].TimerSum := FTimers[ATimer].TimerSum + (GetTickCount - FTimers[ATimer].TimerLast);
  FTimers[ATimer].Runs := FTimers[ATimer].Runs + 1;
  Result := FTimers[ATimer].TimerSum;
end;

initialization
   prof := TdatProfiler.Create(nil)

finalization
   prof.Free;

end.
