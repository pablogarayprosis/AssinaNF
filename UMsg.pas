unit UMsg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, newbtn,
  Vcl.ExtCtrls;

type
  TFmMsg = class(TForm)
    Panel1: TPanel;
    MmMsg: TMemo;
    Panel13: TPanel;
    BtOK: TNewBtn;
    procedure BtOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure MmMsgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmMsg: TFmMsg;

implementation

{$R *.dfm}

procedure TFmMsg.BtOKClick(Sender: TObject);
begin
   Close;
end;

procedure TFmMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := Cafree;
   FmMsg := Nil;
end;

procedure TFmMsg.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = #27) and (BtOk.Enabled) then
      Close;
end;

procedure TFmMsg.MmMsgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = 87) and (BtOk.Enabled) then
      Close;
end;

end.
