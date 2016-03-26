unit uPublicIP;

interface

uses
  SysUtils, Classes, uTimer, httpsend, synautil, ssl_openssl;

const
  PublicIPLink = 'http://www.simawb.com/whatismyip.php';
  //http://www.myexternalip.com/raw
  //https://api.ipify.org
  //http://ip.42.pl/raw
  //http://www.dubaron.com/myip/

type
  TOnGetIP = procedure(Sender: TObject; const IP: string) of object;
  TOnError = procedure(Sender: TObject; const ErrorCode: integer) of object;

  TPublicIP = class(TComponent)
  private
    FTimerThread: TTimerThread;
    FInterval: integer;
    FLink: string;
    FPublicIP: string;
    FIsRunning: boolean;
    FOnGetIP: TOnGetIP;
    FOnError: TOnError;

    procedure TimerThreadOk(Sender: TObject);
    procedure DoRemoveTimerThread;
    procedure DoOnError(ErrCode: integer);
    procedure SetInterval(const Value: integer);
  protected
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;

    property PublicIP: string read FPublicIP;
    property IsActive: boolean read FIsRunning;
  published
    property Interval: integer read FInterval write SetInterval; //Saniye cinsinden
    property Link: string read FLink write FLink;
    property OnGetIP: TOnGetIP read FOnGetIP write FOnGetIP;
    property OnError: TOnError read FOnError write FOnError;
  end;

procedure Register;
function IsIPAdress(const Value:String): Boolean;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TPublicIP]);
end;

function IsIPAdress(const Value: String): Boolean;
var
  n,x,i: Integer;
  Posi: Array[1..4]of Integer;
  Oktet: Array[1..4]of String;
begin
  if Length(Value) > 15 then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  x := 0;
  for n := 1 to Length(Value) do
    if not (CharInSet(Value[n],['0'..'9','.'])) then
    begin
      Result := false;
      Break;
    end
    else begin
      if Value[n] = '.' then
      begin
        Inc(x);
        Posi[x] := n;
      end
      else
         Oktet[x+1] := Oktet[x+1] + Value[n];
    end;

  for i := 1 to 4 do
    if (StrToInt(Oktet[i])>255)then Result := false;

  if x <> 3 then
    Result := false;
end;

{ TPublicIP }

constructor TPublicIP.Create(aOwner: TComponent);
begin
  inherited;
  FIsRunning := False;
  FPublicIP := '';
  Interval := 15; // Default olarak 15 dk'da bir
  FLink := PublicIPLink;
end;

destructor TPublicIP.Destroy;
begin
  DoRemoveTimerThread;
  inherited;
end;

procedure TPublicIP.DoOnError(ErrCode: integer);
begin
  if Assigned(FOnError) then
    FOnError(Self, ErrCode);
end;

procedure TPublicIP.DoRemoveTimerThread;
begin
  if Assigned(FTimerThread) then
  begin
    FTimerThread.OnTimer := nil;
    FTimerThread.Finish;
  end;
end;

procedure TPublicIP.SetInterval(const Value: integer);
begin
  if FInterval <> Value then
    FInterval := Value;
end;

procedure TPublicIP.Start;
begin
  if FIsRunning then Exit;

  DoRemoveTimerThread;

  FTimerThread := TTimerThread.Create(FInterval);
  FTimerThread.OnTimer := TimerThreadOk;

  FIsRunning := True;
end;

procedure TPublicIP.Stop;
begin
  if not FIsRunning then Exit;

  DoRemoveTimerThread;
  FIsRunning := False;
end;

procedure TPublicIP.TimerThreadOk(Sender: TObject);
var
  HTTP: THTTPSend;
  rsp: string;
begin
  HTTP := THTTPSend.Create;
  try
    HTTP.Timeout := 30000;
    HTTP.HTTPMethod('GET', FLink);
    if HTTP.ResultCode = 200 then
    begin
      rsp := ReadStrFromStream(HTTP.Document, HTTP.Document.Size);
      if IsIPAdress(rsp) then
      begin
        FPublicIP := rsp;
        if Assigned(FOnGetIP) then
          FOnGetIP(Self, FPublicIP);
      end
      else
        DoOnError(199);
    end
    else
      DoOnError(HTTP.ResultCode);
  finally
    HTTP.Free;
  end;
end;

end.
