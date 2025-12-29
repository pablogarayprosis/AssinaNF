program AssinaNF;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {FmPrincipal},
  Vcl.Themes,
  Vcl.Styles,
  Winapi.Windows,
  UMsg in 'UMsg.pas' {FmMsg},
  Geral in 'Geral.pas' {FmGeral},
  superdate in 'superobject\superdate.pas',
  superobject in 'superobject\superobject.pas',
  supertimezone in 'superobject\supertimezone.pas',
  supertypes in 'superobject\supertypes.pas',
  superxmlparser in 'superobject\superxmlparser.pas',
  uApi in 'uApi.pas',
  uTipos in 'uTipos.pas';

{$R *.res}
   var
  handle: Thandle;


begin
   handle := FindWindow('TFmPrincipal',nil);
   if Handle<>0 then
begin
   if not ISWindowVisible(Handle) then
    showWindow (handle, sw_restore);
   setForegroundWindow(handle);
  application.Terminate;
 end;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  //Application.ShowMainForm := False;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TFmPrincipal, FmPrincipal);
  Application.CreateForm(TFmMsg, FmMsg);
  Application.CreateForm(TFmGeral, FmGeral);
  Application.Run;
end;

end.
