unit load;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Image1: TImage;
  private
    { Private declarations }
  public
    constructor CreateWithImage(AOwner: TComponent);
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation

{$R *.dfm}


constructor TForm1.CreateWithImage(AOwner: TComponent);
begin
  Create(AOwner);
  Image1.Picture.LoadFromFile('C:\TEMP\logo.bmp');
end;
end.
