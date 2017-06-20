unit uServiceDevCon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  Registry, uDevConHelper, uServiceLog, StrUtils;

type
  TServiceDevCon = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ServiceDevCon: TServiceDevCon;

implementation

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ServiceDevCon.Controller(CtrlCode);
end;

function TServiceDevCon.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TServiceDevCon.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create( KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey( '\SYSTEM\CurrentControlSet\Services\' + Name, False) then
    begin
      Reg.WriteString('Description', 'MrRafael.ca DevCon Service is a Microsoft DevCon service, '
                    + 'for easy initialization on Windows boot. You can disable a problematic driver '
                    + 'and start Windows normally. In the DevConList.txt, on the same path of exe, '
                    + 'insert one driver per line, following by 0 (disable) or 1 (enable). '
                    + 'Ex.: To disable and enable the Intel HD Graphics: ' + sLineBreak 
                    + '*DEV_0102*=0' + sLineBreak
                    + '*DEV_0102*=1' );
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TServiceDevCon.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  WriteLog('ServiceContinue = ' + IfThen(Continued, 'True', 'False') );
end;

procedure TServiceDevCon.ServiceCreate(Sender: TObject);
begin
  WriteLog( StringOfChar('-', 60) );
  WriteLog('ServiceCreate');
end;

procedure TServiceDevCon.ServiceDestroy(Sender: TObject);
begin
  WriteLog('ServiceDestroy');
end;

procedure TServiceDevCon.ServiceExecute(Sender: TService);
var
  lHelper : TDevConHelper;
  lCount: Smallint;
begin
  WriteLog('ServiceExecute = Begin');
  lCount := 0;
  lHelper := TDevConHelper.Create;
  try
    while not Self.Terminated do
    begin
      if lCount > 5 then
      begin
        if lHelper.Execute and Assigned(Self.ServiceThread) then
          Self.ServiceThread.Terminate;
      end else
      begin
        Inc(lCount);
        Sleep(1000);
      end;
      ServiceThread.ProcessRequests(False);
    end;
  finally
    FreeAndNil( lHelper );
  end;
  WriteLog('ServiceExecute = End');
end;

procedure TServiceDevCon.ServicePause(Sender: TService; var Paused: Boolean);
begin
  WriteLog('ServicePause = ' + IfThen(Paused, 'True', 'False') );
end;

procedure TServiceDevCon.ServiceShutdown(Sender: TService);
begin
  WriteLog('ServiceShutdown');
end;

procedure TServiceDevCon.ServiceStart(Sender: TService; var Started: Boolean);
begin
  WriteLog('ServiceStart = ' + IfThen(Started, 'True', 'False') );
end;

procedure TServiceDevCon.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  WriteLog('ServiceStop = ' + IfThen(Stopped, 'True', 'False') );
end;

end.
