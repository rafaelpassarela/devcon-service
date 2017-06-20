unit uDevConHelper;

interface

uses
  Classes, SysUtils, Forms, uServiceLog, StrUtils, uServiceExec;

type
  TDevConHelper = class
  private
    FPath: string;
    FDevConPath: string;
    FDriverList: TStringList;
    procedure LoadList;
    procedure ExecuteCommand(const ADriverName : string);
    procedure DoExecuteCommand(const ADriver : string; const AEnable : Boolean);
  public
    constructor Create;
    destructor Destory;

    function Execute : Boolean;
  end;

implementation

{ TDevConHelper }

constructor TDevConHelper.Create;
begin
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  FDevConPath := FPath + 'devcon.exe';
  FDriverList := TStringList.Create;
end;

destructor TDevConHelper.Destory;
begin
  FreeAndNil( FDriverList );
end;

procedure TDevConHelper.DoExecuteCommand(const ADriver: string; const AEnable: Boolean);
var
  lCmd : string;
begin
  if AEnable then
    lCmd := 'enable'
  else
    lCmd := 'disable';

  lCmd := lCmd + ' ' + ADriver;
  TServiceExec.FileExecuteWait(FDevConPath, lCmd, FPath, esHidden);
end;

function TDevConHelper.Execute: Boolean;
var
  i: Integer;
begin
  LoadList;

  if FileExists(FDevConPath) then
  begin
    for i := 0 to FDriverList.Count - 1 do
    begin
      ExecuteCommand( FDriverList[i] );
      Sleep(1000);
    end;
  end else
    WriteLog('File not found: ' + FDevConPath);

  Result := True;
end;

procedure TDevConHelper.ExecuteCommand(const ADriverName: string);
var
  lPos: Integer;
  lName: string;
  lAction: string;
begin
  if ADriverName <> EmptyStr then
  begin
    WriteLog('-- Checking ' + ADriverName);
    lPos := Pos('=', ADriverName);
    if lPos > 0 then
    begin
      lName := Copy(ADriverName, 1, lPos - 1);
      lAction := Copy(ADriverName, lPos + 1, 1);
      WriteLog('Driver> ' + lName + ' - ' + IfThen(lAction = '0', 'Disable', 'Enable') );

      DoExecuteCommand(lName, lAction = '1');
    end;
  end;
end;

procedure TDevConHelper.LoadList;
var
  lFileName: string;
begin
  lFileName := FPath + 'DevConList.txt';
  if FileExists(lFileName) then
    FDriverList.LoadFromFile(lFileName)
  else
    FDriverList.Clear;
end;

end.
