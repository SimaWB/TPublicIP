unit uTimer;

interface

uses
  Windows, SysUtils, Classes;

type
  TTimerThread = class(TThread)
    private
    FEvent: THandle;
    FOnTimer: TNotifyEvent;
    FInterval: Integer;
  protected
    procedure Execute; override;
    procedure DoTimer;
  public
    constructor Create(Interval: Integer = 1);
    destructor Destroy; override;
    procedure Finish;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

implementation

{ TTimerThread }

constructor TTimerThread.Create(Interval: Integer = 1);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FEvent := CreateEvent(nil, True, False, nil);
  FInterval := Interval * 1000 * 60;//Dakika
end;

destructor TTimerThread.Destroy;
begin
  CloseHandle(FEvent);
  inherited;
end;

procedure TTimerThread.DoTimer;
begin
  if Assigned(FOnTimer) then
    FOnTimer(Self);
end;

procedure TTimerThread.Execute;
begin
  while not Terminated do
    if WaitForSingleObject(FEvent, FInterval) = WAIT_TIMEOUT then
      Synchronize(DoTimer);
end;

procedure TTimerThread.Finish;
begin
  SetEvent(FEvent);
  Terminate;
end;

end.
