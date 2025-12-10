unit Geral;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

  type
   TErros = Record
      varCfo : String;
      varMen : String;
   end;

type
  TFmGeral = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmGeral: TFmGeral;

  varErrCon : Array of TErros;

implementation

{$R *.dfm}

end.
