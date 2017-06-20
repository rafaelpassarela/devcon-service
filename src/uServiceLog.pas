unit uServiceLog;

interface

uses
  SysUtils, DateUtils, Forms, Windows;

const
  C_Max_LogSize =  2097152; // 2MB


procedure WriteLog(const AMessage : string); overload;

procedure WriteLog(const AFileName: TFileName; const AMenssage: string;
  const AIncludeDateTime : Boolean = True; const ALineBreak : Boolean = True); overload;

implementation

procedure WriteLog(const AMessage : string);
var
  lName: string;
begin
  lName := StringReplace(Application.ExeName, '.exe', '.log', [rfIgnoreCase]);
  WriteLog(lName, AMessage);
end;

procedure WriteLog(const AFileName: TFileName; const AMenssage: string;
  const AIncludeDateTime : Boolean = True; const ALineBreak : Boolean = True);
var
  lText: TextFile;
  lFileName, lBaseFile : TFileName;
  lLine : string;
  lNomeBase: string;
  lRec: TSearchRec;
  lCount: Integer;

  function FileSize: Int64;
  var
    sr : TSearchRec;
  begin
    if FindFirst(lFileName, faAnyFile, sr ) = 0 then
      Result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
    else
      Result := -1;
  end;

begin
  lBaseFile := AFileName;
  if lBaseFile = '' then
    lBaseFile := ParamStr(0);

  lFileName := ExtractFileName(lBaseFile);
  lBaseFile := StringReplace(lBaseFile, lFileName, 'Logs\' + lFileName, [rfIgnoreCase]);

  ForceDirectories(ExtractFilePath(lBaseFile));

  lFileName := ChangeFileExt(lBaseFile, '') + IntToStr(DayOf(Date + 1)) + '.log';
  if FileExists(lFileName) then
    DeleteFile(PChar(lFileName));
    
  lNomeBase := StringReplace(lFileName, '.log', '', [rfIgnoreCase, rfReplaceAll]);
  if FindFirst(lNomeBase + '.bkp*', faAnyFile, lRec) = 0 then
  begin
    lNomeBase := IncludeTrailingPathDelimiter(ExtractFilePath(lNomeBase));
    repeat
      if FileExists(lNomeBase + lRec.Name) then
        DeleteFile( PChar(lNomeBase + lRec.Name) );
    until FindNext(lRec) <> 0;
  end;

  lFileName := ChangeFileExt(lBaseFile, '') + IntToStr(DayOf(Date)) + '.log';

  if FileSize > C_Max_LogSize then
  begin
    lNomeBase := StringReplace(lFileName, '.log', '', [rfIgnoreCase]);
    lCount := 0;

    if FindFirst(lNomeBase + '.bkp*', faAnyFile, lRec) = 0 then
    begin
      repeat
        Inc(lCount);
      until FindNext(lRec) <> 0;
    end;
    Inc(lCount);
    RenameFile(PChar(lFileName), PChar(lNomeBase + '.bkp' + IntToStr(lCount)));
  end;

{$I-}
  AssignFile(lText, lFileName);
  try
    if FileExists(lFileName) then
      Append(lText)
    else
      Rewrite(lText);

    lLine := '';
    if AIncludeDateTime then
      lLine := lLine + FormatDateTime('dd/mm hh:nn:ss zzz', Now) + ' ';

    lLine :=  lLine + AMenssage;

    if ALineBreak then
      lLine := lLine + #13 + #10;

    Write(lText, lLine);
  finally
    CloseFile(lText);
  end;
{$I+}
end;

end.
