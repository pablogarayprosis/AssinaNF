program AssinaNF;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {FmPrincipal},
  Vcl.Themes,
  Vcl.Styles,
  XSuperObject in 'XSuperObject.pas',
  Winapi.Windows,
  UMsg in 'UMsg.pas' {FmMsg},
  Geral in 'Geral.pas' {FmGeral},
  superdate in '..\..\Componentes\superobject\superdate.pas',
  superobject in '..\..\Componentes\superobject\superobject.pas',
  supertimezone in '..\..\Componentes\superobject\supertimezone.pas',
  supertypes in '..\..\Componentes\superobject\supertypes.pas',
  superxmlparser in '..\..\Componentes\superobject\superxmlparser.pas',
  uApi in '..\REP\Services\uApi.pas',
  uTipos in '..\REP\Geral\uTipos.pas';

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
