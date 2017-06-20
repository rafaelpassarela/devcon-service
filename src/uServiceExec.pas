unit uServiceExec;

interface

uses
  ShellAPI, Windows, Forms;

type
  TExecState = (esNormal, esMinimized, esMaximized, esHidden);

  TServiceExec = class
  public
    class function FileExecuteWait(const FileName, Params, StartDir: string;
      InitialState: TExecState): Integer;
  end;

implementation

{ TServiceExec }

class function TServiceExec.FileExecuteWait(const FileName, Params, StartDir: string; InitialState: TExecState): Integer;
const
  ShowCommands: array[TExecState] of Integer = (SW_SHOWNORMAL, SW_MINIMIZE, SW_SHOWMAXIMIZED, SW_HIDE);
var
  Info: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(TShellExecuteInfo);
  with Info do
  begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := Application.Handle;
    lpFile := PChar(FileName);
    lpParameters := PChar(Params);
    lpDirectory := PChar(StartDir);
    nShow := ShowCommands[InitialState];
  end;
  if ShellExecuteEx(@Info) then
  begin
    repeat
      Application.ProcessMessages;
      GetExitCodeProcess(Info.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
    Result := ExitCode;
  end
  else
    Result := -1;
end;

end.
