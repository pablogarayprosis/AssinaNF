unit uComum;

interface

uses
   Winapi.Windows, StrUtils, SysUtils, Types, DateUtils, uTipos;

type
   TComum = class
   private
      function RunProcess(FileName: string; ShowCmd: DWORD; wait: Boolean; ProcID: PDWORD): Longword;
   public
      function SplitString(s, Delimiter: string): TStringDynArray;
      function GerarSenhaDemonstracao(Dia, Mes, Ano: integer): string;
      function ParametrosParaIntegradorHenry(rep: TRep): string;
      function ParametrosParaIntegradorRwTech(rep:TRep): string;
      function ParametrosParaIntegradorTopDataV5(rep: TRep): string;
      function RodarExecutavel(arquivo, parametros: String): Integer;
      function RetornarErroKurumin(erro: Integer): String;
   end;

implementation

{ TComum }

function TComum.GerarSenhaDemonstracao(dia, mes, ano: integer): string;
var
   x: smallint;
begin
   if (dia mod 2 = 0) then
   begin
      case DayOfTheWeek(StrToDate(IntToStr(dia) + '/' + IntToStr(mes) + '/' + IntToStr(ano))) of
         1:
            x := 26;
         2:
            x := 17;
         3:
            x := 33;
         4:
            x := 45;
         5:
            x := 63;
         6:
            x := 54;
         7:
            x := 83;
      end;
   end
   else
   begin
      case DayOfTheWeek(StrToDate(IntToStr(dia) + '/' + IntToStr(mes) + '/' + IntToStr(ano))) of
         1:
            x := 72;
         2:
            x := 91;
         3:
            x := 67;
         4:
            x := 15;
         5:
            x := 28;
         6:
            x := 34;
         7:
            x := 49;
      end;
   end;
   result := IntToStr((ano * 63) + (mes * 15) + (dia * x) + 2471);
end;

function TComum.ParametrosParaIntegradorHenry(rep: TRep): string;
var
   parametros: string;
begin
   parametros := IntToStr(rep.id)
                  + ' ' + IntToStr(rep.marca)
                  + ' ' + rep.ip
                  + ' ' + IntToStr(rep.porta);
      if rep.marca = 9 then
         parametros := parametros + ' ' + rep.usuario + ' ' + rep.senha;

      parametros := parametros + ' ' + IntToStr(rep.nsr)
                     + ' ' + rep.portaria671;

   Result := parametros;
end;

function TComum.ParametrosParaIntegradorRwTech(rep: TRep): string;
begin
   Result := IntToStr(rep.id)
      + ' ' + rep.ip
      + ' ' + IntToStr(rep.porta)
      + ' 4EC0CB85402C4E5A7E541913CA57373D6828E2C323AD1AF1C7D5D1801F6BDFC0'
      + ' ' + IntToStr(rep.nsr)
      + ' ' + rep.portaria671;
end;

function TComum.ParametrosParaIntegradorTopDataV5(rep: TRep): string;
begin
   Result := IntToStr(rep.id)
      + ' ' + IntToStr(rep.nsr)
      + ' ' + rep.ip
      + ' ' + rep.portaria671;
end;

function TComum.RetornarErroKurumin(erro: Integer): String;
begin
   case erro of
      16001: Result := 'Alerta';
      16002: Result := ' Erro.';
      16003: Result := ' Informação.';
      16004: Result := ' Erro: parâmetro “NR” não encontrado.';
      16005: Result := ' Erro: número de série inválido.';
      16006: Result := ' Erro: parâmetro inválido.';
   end;
end;

function TComum.RodarExecutavel(arquivo, parametros: String): Integer;
var
   ProcID: Cardinal;
begin
   ProcID := 0;
   if Length(Trim(parametros)) > 0 then
      arquivo := arquivo + ' ' + parametros;

   Result := RunProcess(arquivo, SW_SHOWMINIMIZED, TRUE, @ProcID);
end;

function TComum.RunProcess(FileName: string; ShowCmd: DWORD; wait: Boolean; ProcID: PDWORD): Longword;
var
   StartupInfo: TStartupInfo;
   ProcessInfo: TProcessInformation;
begin
   FillChar(StartupInfo, SizeOf(StartupInfo), #0);
   StartupInfo.cb := SizeOf(StartupInfo);
   StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
   StartupInfo.wShowWindow := ShowCmd;
   if not CreateProcess(nil,
      @FileName[1],
      nil,
      nil,
      False,
      CREATE_NEW_CONSOLE or
      NORMAL_PRIORITY_CLASS,
      nil,
      nil,
      StartupInfo,
      ProcessInfo) then
      Result := WAIT_FAILED
   else
   begin
      if wait = FALSE then
      begin
         if ProcID <> nil then
            ProcID^ := ProcessInfo.dwProcessId;
         result := WAIT_FAILED;
         exit;
      end;
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      GetExitCodeProcess(ProcessInfo.hProcess, Result);
   end;
   if ProcessInfo.hProcess <> 0 then
      CloseHandle(ProcessInfo.hProcess);
   if ProcessInfo.hThread <> 0 then
      CloseHandle(ProcessInfo.hThread);
end;

function TComum.SplitString(s, Delimiter: string): TStringDynArray;
var
   StartIdx: Integer;
   FoundIdx: Integer;
   SplitPoints: Integer;
   CurrentSplit: Integer;
   i: Integer;
begin
   Result := nil;
   StartIdx := 1;
   SplitPoints := 1;
   if s <> '' then
   begin
    { Determine the length of the resulting array }
      for i := 0 to Length(s) - 1 do
         if s[i] = Delimiter then
         begin
            setLength(Result, SplitPoints);
            Result[SplitPoints - 1] := Copy(s, StartIdx, i - StartIdx);
            Inc(SplitPoints);
            StartIdx := i + 1;
         end;

      setLength(Result, SplitPoints);
      Result[SplitPoints - 1] := Copy(s, StartIdx, i - StartIdx + 1);
   end;
end;

end.

