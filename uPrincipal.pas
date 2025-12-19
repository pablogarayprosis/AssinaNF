unit uPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
   Vcl.ExtCtrls, Vcl.ImgList, Vcl.Imaging.pngimage, IdMultipartFormData, IniFiles, Vcl.ToolWin, Vcl.ComCtrls, DCPcrypt2, DCPsha1, IdCoder, IdCoder3to4,
   IdCoderMIME, IdBaseComponent, ACBrNFe, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdGlobal, IdExplicitTLSClientServerBase,
   System.IOUtils, XSuperObject, Vcl.AppEvnts, DateUtils, pcnConversaoNFe, PSAPI, TlHelp32, Registry, ACBrDFeSSL, Shellapi, Vcl.ExtDlgs, ACBrEAD,
   ACBrUtil, ACBrDFeUtil, ACBrBase, ACBrDFe, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, blcksock, SuperObject, RestClient,
   RestUtils, HttpConnection, ActiveX;

const
   ARQ_CONF = 'conf.ini';

   COD_SISTEMA = 91;
   COD_ATUALIZADOR = 92;
   {$IFDEF DEBUG}
     BASEURL = 'http://localhost/affinconfgithub/';
   {$ELSE}
     BASEURL = 'https://farol6592.c33.integrator.host/';
   {$ENDIF}
   CAMINHO_XML_NAO_ASSINADO = 'nfephp/Empresas/$emp/1/Nfe/$amb/entradas/A3/';
   CAMINHO_XML_ASSINADO = 'nfephp/Empresas/$emp/1/Nfe/$amb/assinadas/';

type TMyClass = class
  private
    FDestination: string;
    procedure HandleResponse(Response: TStream);
  public
    constructor create;
    procedure Download(FileURL, Destination: string);
  end;

type
   TFmPrincipal = class(TForm)
      PnConf: TPanel;
      Label1: TLabel;
      Label2: TLabel;
      EdEmp: TEdit;
      EdFil: TEdit;
      Label3: TLabel;
      BtConf: TButton;
      Label4: TLabel;
      Label5: TLabel;
      EdUsu: TEdit;
      EdSen: TEdit;
      ImageList1: TImageList;
      ToolBar1: TToolBar;
      IdEnc: TIdEncoderMIME;
      IdDec: TIdDecoderMIME;
      TbConf: TToolButton;
      TmProNot: TTimer;
      MmLog: TMemo;
      TmFtp: TTimer;
      GroupBox1: TGroupBox;
      Button1: TButton;
      Label6: TLabel;
      EdPin: TEdit;
      LbCer: TLabel;
      TrayIcon1: TTrayIcon;
      ImageList2: TImageList;
      LbEmp: TLabel;
      ApplicationEvents1: TApplicationEvents;
      PnAviso: TPanel;
      Image2: TImage;
      Label8: TLabel;
      Bevel1: TBevel;
      OpenPictureDialog1: TOpenPictureDialog;
      RadioGroup1: TRadioGroup;
      IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
      CbSSL: TComboBox;
      Label10: TLabel;
      RestClient1: TRestClient;
    TbBuscarNotas: TToolButton;
    TbPararTimer: TToolButton;
    LbStatus: TLabel;
    StatusBar1: TStatusBar;
        LbHomologacao: TLabel;
      procedure FormShow(Sender: TObject);
      procedure TbConfClick(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure TmProNotTimer(Sender: TObject);
      procedure TmFtpTimer(Sender: TObject);
      procedure TrayIcon1DblClick(Sender: TObject);
      procedure ApplicationEvents1Minimize(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtConfClick(Sender: TObject);
      procedure Label8Click(Sender: TObject);
      procedure PnConfClick(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure ApplicationEvents2Exception(Sender: TObject; E: Exception);
      procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure Button2Click(Sender: TObject);
    procedure TbPararTimerClick(Sender: TObject);
    procedure TbBuscarNotasClick(Sender: TObject);


   private
    { Private declarations }
      arquivoConfiguracao, codigoEmpresa, filial, usuario, senha, Certificado,
      Pin, arquivoConfiguracaoXML, diretorioXmlAssinado,
      CNPJemp, ambiente, tokenid, token, diretorioRaiz,
      diretorioXmlBaixado, caminhoXMLNaoAssinado, caminhoXMLAssinado: string;
      pararThread: Boolean;
      mes, ano, codigoAmbiente: Integer;
      ACBrNFe1: TACBrNFe;
      function GravaArquivoConfiguracao: Boolean;
      procedure ConfigurarAcbr;
      function LeArquivoConfiguracao: Boolean;
      function ValidaCampos: Boolean;
      function AssinaXML(arquivoConfiguracao, varXml: string; varNF: Integer): string;
      function FileSize(fileName: WideString): Int64;
      function FormatByteSize(const bytes: LongInt): string;
      function VerificaAtualizacoes: Boolean;
      procedure ConfiguraCertificadoDigital;
      procedure Log(varMsg: string);
      procedure TrocaIcone(varIco: Integer);
      procedure AtualizaSistema(varSis: Integer; varCaminho, varExecutavel, varAtualizador: string);
      procedure BuscaAssinaNota;
      procedure CriaEntradaRegistro;
      function RodarComoAdministrador(HWND: HWND; arquivoConfiguracao, varPar: string): Boolean;
      function Buscadados: Boolean;
      function CartaCorrecao(arq: TStrings; xml: string): TStrings;
      function CancelarNota(arq: TStrings; xml: string): TStrings;
      function Manifesto(arq: TStrings; xml: string): TStrings;
      function Inutilizar(arq: TStrings; xml: string): TStrings;
      function AtualizarCarta(chave: string): Boolean;
      procedure buscaToken;
      procedure PostExcluirArquivo(xmlNome: String);
      function atualizacancela(chave, xjust: string): Boolean;
      function atualizamanifesto(chave, tipo: string): Boolean;
      function atualizaInutilizadas(serie, ini, fim, modelo: string): Boolean;
      function VersaoExe: string;
      procedure ChamaAtualizador;
      function VerificarSeAplicaticoEstarRodandoPeloNomeDoExecutavel(Nome: string): Boolean;
      function Post(url, postString: string): string;
      procedure MostrarNotificacao(titulo, mensagem: String);

   public

    { Public declarations }
   end;

var
   FmPrincipal: TFmPrincipal;
   ThAssina, ThEventos: TThread;

implementation

uses
   pcnConversao, load, uApi;

{$R *.dfm}

procedure TFmPrincipal.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  //
end;

procedure TFmPrincipal.ApplicationEvents1Minimize(Sender: TObject);
begin
  { Hide the window and set its state variable to wsMinimized. }
  // Hide();
  // WindowState := wsMinimized;

  { Show the animated tray icon and also a hint balloon. }
  // TrayIcon1.Visible := True;
  // TrayIcon1.Animate := True;
  // TrayIcon1.ShowBalloonHint;
end;

procedure TFmPrincipal.ApplicationEvents2Exception(Sender: TObject; E: Exception);
begin
  //
end;

function TFmPrincipal.AssinaXML(arquivoConfiguracao, varXml: string; varNF: Integer): string;
begin
   Log('Carregando arquivo XML.');
   if ACBrNFe1.NotasFiscais.Count > 0 then
      ACBrNFe1.NotasFiscais.Delete(0);
   Log((arquivoConfiguracao));
   Log(IntToStr(varNF));
   ConfigurarAcbr;
   ACBrNFe1.NotasFiscais.LoadFromFile(arquivoConfiguracao, False);
   tokenid := '';
   token := '';
   if ACBrNFe1.NotasFiscais.Items[0].NFe.ide.modelo = 65 then
   begin
      ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFCe;
      buscaToken;
      ACBrNFe1.Configuracoes.Geral.IdCSC := tokenid;
      ACBrNFe1.Configuracoes.Geral.CSC := token;
   end
   else
      ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFe;
   Log('Assinando...');

   ConfigurarAcbr;
  // ACBrNFe1.Configuracoes.Geral.IncluirQRCodeXMLNFCe := false;
   ACBrNFe1.NotasFiscais.Assinar;
   Result := ACBrNFe1.NotasFiscais.Items[0].xml;
   Log('Nota assinada com sucesso.');
   MostrarNotificacao('Nota Número: ' + IntToStr(varNF), 'Nota assinada com sucesso.');

  // verifica se o arquivo já existe localmente
   if FileExists(diretorioXmlAssinado + varXml) then
   begin
      Log('Arquivo assinado já existe. Excluindo.');
      TFile.Delete(diretorioXmlAssinado + varXml);
   end;

   Log('Salvando nota fiscal.');
   Log(diretorioXmlAssinado + varXml);

   ACBrNFe1.NotasFiscais.Items[0].GravarXML(varXml, diretorioXmlAssinado);
end;

function TFmPrincipal.atualizamanifesto(chave, TIPO: string): Boolean;
var
   postString, S: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := False;

   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=atualizamanifesto';
         postString := postString + '&CHAVE=' + chave;
         postString := postString + '&TIPO=' + TIPO;
         S := Post('buscadados.php', postString);
         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
            Result := False;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
      Result := True;
   finally

   end;
end;

function TFmPrincipal.atualizacancela(chave, xjust: string): Boolean;
var
   postString, S: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := False;

   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=atualizacancela';
         postString := postString + '&CHAVE=' + chave;
         postString := postString + '&JUST=' + xjust;
         S := Post('buscadados.php', postString);
         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
            Result := False;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
      Result := True;
   finally

   end;
end;

procedure TFmPrincipal.buscaToken;
var
   S, postString: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin

   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=Buscatoken';
         postString := postString + '&COD_EMPRESA=' + codigoEmpresa;
         S := Post('buscadados.php', postString);
         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
         end
         else
         begin
            if Length(S) > 0 then
            begin
               S := StringReplace(S, 'null', '""', [rfReplaceAll]);
               obj := SO(S);
               for i := 0 to obj.AsArray.Length - 1 do
               begin
                  obj2 := SO(obj.AsArray.S[i]);
                  tokenid := obj2.AsObject.S['tokenid'];
                  token := obj2.AsObject.S['token'];
               end;
            end;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
   finally

   end;
end;

function TFmPrincipal.atualizaInutilizadas(serie, ini, fim, modelo: string): Boolean;
var
   S, postString: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := False;

   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=atualizaInutilizadas';
         postString := postString + '&COD_EMPRESA=' + codigoEmpresa;
         postString := postString + '&SERIE=' + serie;
         postString := postString + '&INI=' + ini;
         postString := postString + '&FIM=' + fim;
         postString := postString + '&MODELO=' + modelo;
         S := Post('buscadados.php', postString);
         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
            Result := False;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
      Result := True;
   finally

   end;
end;

function TFmPrincipal.AtualizarCarta(chave: string): Boolean;
var
   S, postString: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := False;

   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=atualizacarta';
         postString := postString + '&CHAVE=' + chave;
         S := Post('buscadados.php', postString);
         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
            Result := False;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
      Result := True;
   finally

   end;
end;

procedure TFmPrincipal.AtualizaSistema(varSis: Integer; varCaminho, varExecutavel, varAtualizador: string);
begin
   if varAtualizador = 'S' then
   begin
    // é uma atualização do atualizador, então ele vai baixar e atualizar
   end;
end;

procedure TFmPrincipal.BtConfClick(Sender: TObject);
begin
   if ValidaCampos then
      if GravaArquivoConfiguracao then
      begin
         ShowMessage('Configuração salva com sucesso!');
         LeArquivoConfiguracao;
         PnConf.Visible := False;
         ConfiguraCertificadoDigital;
         if Buscadados then
            TmFtp.Enabled := True;

      end;
end;

procedure TFmPrincipal.BuscaAssinaNota;
var
   FileNames: TStringList;
   varNF, varErro, i: Integer;
   cami: string;
   arq: TextFile; { declarando a variável "arq" do tipo arquivo texto }
   linha, pasta, postString, xmlBaixados, xmlNome: string;
   Arquivo, resposta: TStrings;
   api: TApi;
   obj, objXML: ISuperObject;
   MyClass: TMyClass;
begin
   TmFtp.Enabled := False;
   FileNames := TStringList.Create;
   varErro := 0;
   api := TApi.Create('AFFINCONF');
   MyClass := TMyClass.Create;
   try

      TrocaIcone(1);
      try
         LbStatus.Caption := 'Procurando notas para assinar...';
         LbStatus.Refresh;

         postString := 'CONTROLE=010889&FUNCAO=listarArquivos' +
            '&PATH=' + caminhoXMLNaoAssinado;

         api.Post('buscadados.php', postString);

         if Copy(api.responseBody, 1, 4) = 'Erro' then
         begin
            Log(api.responseBody);
            Exit;
         end;

         xmlBaixados := api.responseBody;
         obj := SO(xmlBaixados);

         if obj.AsArray.Length > 0 then
         begin
            Log(IntToStr(obj.AsArray.Length) + ' nota(s) encontrada(s)');
            LbStatus.Caption := IntToStr(obj.AsArray.Length) + ' nota(s) encontrada(s)';
            LbStatus.Refresh;
         end
         else
         begin
            LbStatus.Caption := 'Nenhuma nota encontrada';
            LbStatus.Refresh;
            Exit;
         end;

         Buscadados;

         for i := 0 to obj.AsArray.Length - 1 do
         begin
            try
               Sleep(100);
               objXML := SO(obj.AsArray.S[i]);
               xmlNome := objXML.AsObject.S['nome'];
               Log(xmlNome);


               FmPrincipal.Show;
               try
                  MyClass.Download(BASEURL + caminhoXmlNaoAssinado + xmlNome,
                      diretorioXmlBaixado + xmlNome);
               except
                  on e:Exception do
                  begin
                     Log('Erro ao baixar arquivo: ' + e.message);
                     Continue;
                  end;
               end;

               if not FileExists(diretorioXmlBaixado + xmlNome) then
               begin
                  Log('O arquivo ' + xmlNome + ' não foi baixado');
                  Continue;
               end;

               linha := diretorioXmlBaixado + xmlNome;
               Arquivo := TStringList.Create;
               Arquivo.LoadFromFile(diretorioXmlBaixado + xmlNome);
               linha := Trim(Arquivo[0]);
               pasta := '';
               if (linha = 'canc') then
               begin
                  resposta := CancelarNota(Arquivo, xmlNome);
                  if resposta.count = 0 then
                  begin
                     PostExcluirArquivo(xmlNome);
                     Continue;
                  end;
                  pasta := 'canceladas'
               end;

               if (linha = 'mani') then
               begin
                  resposta := manifesto(Arquivo, xmlNome);
                  if resposta.count = 0 then
                  begin
                     PostExcluirArquivo(xmlNome);
                     Continue;
                  end;
                  pasta := 'eventos'
               end;

               if (linha = 'inut') then
               begin
                  resposta := Inutilizar(Arquivo, xmlNome);
                  if resposta.count = 0 then
                  begin
                     log('excluindo arquivos');
                     PostExcluirArquivo(xmlNome);
                     Continue;
                  end;
                  pasta := 'inutilizadas';
               end;

               if (linha = 'carta') then
               begin
                  resposta := CartaCorrecao(Arquivo, xmlNome);
                  if resposta.count = 0 then
                  begin
                     PostExcluirArquivo(xmlNome);
                     Continue;
                  end;
                  pasta := 'cartacorrecao';
               end;

               if pasta = '' then
               begin
                  pasta := 'assinadas';
                  varNF := StrToInt(Copy(xmlNome, 26, 9));
                  Log('Nota: ' + IntToStr(varNF));
                  AssinaXML(diretorioXmlBaixado + xmlNome, xmlNome, varNF);
               end;

               Sleep(50);

               Log('atualizar nota assinada: ' + postString + ' >> ' + diretorioXmlAssinado + xmlNome);

               postString := 'CONTROLE=010889&FUNCAO=receberArquivo' +
                  '&diretorio_upload=' + caminhoXmlAssinado;
               api.Post('buscadados.php', postString, 'arquivo=' + diretorioXmlAssinado + xmlNome);

               log('resposta enviar nota: ' + api.responseBody);
               Sleep(100);

               Log('Arquivo XML assinado da Nota número: ' + IntToStr(varNF)
                  + ' enviado corretamente. Sua nota pode ser transmitida.');


               PostExcluirArquivo(xmlNome);
            except
               on e:Exception do
                  Log('Erro ao ler as notas: ' + e.message);
            end;
         end
      except
         on E: Exception do
         begin

            // varErro := 1;
            Log('1 ' + E.message);
         end;
      end;
   finally
      TrocaIcone(1);
      Application.ProcessMessages;
     // TerminateThread(ThAssina.Handle,0);
      TmFtp.Enabled := True;
   end;
end;

procedure TFmPrincipal.Button1Click(Sender: TObject);
var
   Certificado: string;
begin

   ConfigurarAcbr;
   Certificado := ACBrNFe1.SSL.SelecionarCertificado;
   LbCer.Caption := Certificado;
end;

procedure TFmPrincipal.Button2Click(Sender: TObject);
var
  MyClass: TMyClass;
  Api: TApi;
  postString: String;
begin
   BuscaAssinaNota;
//  MyClass := TMyClass.Create;
//            MyClass.Download(BASEURL +
//                StringReplace(CAMINHO_XML_NAO_ASSINADO, '$emp', '237', []) +
//                '/' + '43251211296369000100550020000010431869113395-nfe.xml',
//                diretorioXmlBaixado + '43251211296369000100550020000010431869113395-nfe.xml');
//  Api := TApi.Create('AFFINCONF');
//  try
//     try
//        postString := 'CONTROLE=010889&FUNCAO=receberArquivo' +
//         '&diretorio_upload=' + StringReplace(CAMINHO_XML_ASSINADO, '$emp', '237', []) + '/';
//
//        api.Post('buscadados.php', postString, 'arquivo='+diretorioXmlAssinado + '43251211296369000100550020000010431869113395-nfe.xml');
//        ShowMessage(api.responseBody);
//     except
//        on e:Exception do
//           ShowMessage(e.message);
//
//     end;
//  finally
//     api.Destroy;
//  end;
//  showMessage('concluído');
end;

function TFmPrincipal.manifesto(arq: TStrings; xml: string): TStrings;
var
   mensagem, S: string;
   ArquivoTexto: TextFile; { handle do arquivo texto }
   retorno: Boolean;
   ret: Integer;
begin
   try
      Result := TStringList.Create;
      ACBrNFe1.NotasFiscais.Clear;
      ACBrNFe1.EventoNFe.Evento.Clear;
      Buscadados;
      ACBrNFe1.Configuracoes.Geral.VersaoDF := ve400;
      if codigoAmbiente = 1 then
         ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao
      else
         ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
      ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFe;

      with ACBrNFe1.EventoNFe.Evento.Add do
      begin
         Log('Enviando Manifestação de destinatario de nota ');
         infEvento.chNFe := arq[1]; // Trim(Edit1.Text);
         infEvento.CNPJ := CNPJemp;
         InfEvento.cOrgao := 91;
         InfEvento.nSeqEvento := 1;
         infEvento.dhEvento := Now;
         if arq[2] = '210200' then
            infEvento.tpEvento := teManifDestConfirmacao;
         if arq[2] = '210210' then
            infEvento.tpEvento := teManifDestCiencia;
         if arq[2] = '210220' then
            infEvento.tpEvento := teManifDestDesconhecimento;
         if arq[2] = '210240' then
            infEvento.tpEvento := teManifDestOperNaoRealizada;
      //infEvento.detEvento.nProt := arq[2]; // '143160001498040';
         infEvento.detEvento.xjust := arq[3]; // 'Teste de cancelamento';
         infEvento.dhEvento := Now;
      end;
      ConfigurarAcbr;
      retorno := ACBrNFe1.EnviarEvento(codigoAmbiente);
    // MmLog.Lines.Text := UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.XML);
      Result.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
            Items[0].RetInfEvento.xml));
    // res.Add(inttostr(ACBrNFe1.WebServices.EnvEvento.cStat));
      ret := ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
         .RetInfEvento.cStat;
      if (ret = 135) or (ret = 136) then
         atualizamanifesto(arq[1], arq[2]);
      if FileExists(diretorioXmlAssinado + xml) then
      begin
         Log('Arquivo assinado já existe. Excluindo.');
         TFile.Delete(diretorioXmlAssinado + xml);
      end;

      Log('Salvando xml');
      Log(diretorioXmlAssinado + xml);
      Result.SaveToFile(diretorioXmlAssinado + xml);
      mensagem :=
         (IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
         .RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.
         EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo);
      Log(mensagem);
      MostrarNotificacao('Manifesto de destinatario de NF', mensagem);
   except
      on E: Exception do
         Log('Error Message: ' + E.message);
   end;
end;

procedure TFmPrincipal.MostrarNotificacao(titulo, mensagem: String);
begin
   TrayIcon1.BalloonTitle := titulo;
   TrayIcon1.ShowBalloonHint;
   TrayIcon1.BalloonHint := mensagem;
end;

function TFmPrincipal.CancelarNota(arq: TStrings; xml: string): TStrings;
var
   mensagem, S: string;
   ArquivoTexto: TextFile; { handle do arquivo texto }
   retorno: Boolean;
begin
   try
      Result := TStringList.Create;
      ACBrNFe1.NotasFiscais.Clear;
      ACBrNFe1.EventoNFe.Evento.Clear;
      Buscadados;
      ACBrNFe1.Configuracoes.Geral.VersaoDF := ve400;
      if codigoAmbiente = 1 then
         ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao
      else
         ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
      if arq[5] = '65' then
         ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFCe
      else
         ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFe;

      with ACBrNFe1.EventoNFe.Evento.Add do
      begin
         Log('Enviando cancelamento de nota ');
         infEvento.chNFe := arq[1]; // Trim(Edit1.Text);
         infEvento.CNPJ := CNPJemp;
         infEvento.dhEvento := Now;
         infEvento.tpEvento := teCancelamento;
         infEvento.detEvento.nProt := arq[2]; // '143160001498040';
         infEvento.detEvento.xjust := arq[3]; // 'Teste de cancelamento';
      end;
      ConfigurarAcbr;
      retorno := ACBrNFe1.EnviarEvento(codigoAmbiente);

      if ACBrNFe1.WebServices.EnvEvento.cStat <> 135 then
      begin
         Log('Status: ' + IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
            .RetInfEvento.cStat));
      end
      else
      begin

         Result.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
               Items[0].RetInfEvento.xml));

         if (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
            .RetInfEvento.cStat = 135) then
            atualizacancela(arq[1], arq[3]);

         if FileExists(diretorioXmlAssinado + xml) then
         begin
            Log('Arquivo assinado já existe. Excluindo.');
            TFile.Delete(diretorioXmlAssinado + xml);
         end;

         Log('Salvando xml');
         Log(diretorioXmlAssinado + xml);
         Result.SaveToFile(diretorioXmlAssinado + xml);
      end;

      mensagem :=
         (IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
         .RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.
         EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo);
      Log(mensagem);
      MostrarNotificacao('Cancelamento de NF', mensagem);
   except
      on E: Exception do
         Log('Error Message: ' + E.message);
   end;
end;

function TFmPrincipal.Inutilizar(arq: TStrings; xml: string): TStrings;
var
   S: string;
begin
   ACBrNFe1.NotasFiscais.Clear;
   Result := TStringList.Create;
   if codigoAmbiente = 1 then
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao
   else
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
   ConfigurarAcbr;
   try
      Log('Inutilizando Notas');
      ACBrNFe1.WebServices.Inutiliza(arq[5], // cnpj
         arq[4], // justificativa
         StrToInt(arq[7]), // ano
         StrToInt(arq[6]), // modelo de nota(nfce 65 ou nfe 55)
         StrToInt(arq[1]), // serie
         StrToInt(arq[2]), // inicio
         StrToInt(arq[3])); // fim
      Log('Inutilização OK');
   except
      on E: Exception do
      begin
         Log('Inutilização não efetuada. ' + E.message);

         Exit;
      end;
   end;

   Log('Inutilização concluida');
   MostrarNotificacao('Inutilização de NF', 'Inutilização concluida');
   Result.Add(UTF8Encode(ACBrNFe1.WebServices.Inutilizacao.XML_ProcInutNFe));
   if FileExists(diretorioXmlAssinado + xml) then
   begin
      Log('Arquivo assinado já existe. Excluindo.');
      TFile.Delete(diretorioXmlAssinado + xml);
   end;
   atualizaInutilizadas(arq[1], arq[2], arq[3], arq[6]);
   Log('Salvando xml.');
   Log(diretorioXmlAssinado + xml);
   Result.SaveToFile(diretorioXmlAssinado + xml);
   TFile.Delete(diretorioXmlBaixado + xml);
end;

function TFmPrincipal.CartaCorrecao(arq: TStrings; xml: string): TStrings;
var
   mensagem, S: string;
begin
   Result := TStringList.Create;
   ACBrNFe1.NotasFiscais.Clear;
   ACBrNFe1.EventoNFe.Evento.Clear;
   if arq[5] = '65' then
      ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFCe
   else
      ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFe;
   if codigoAmbiente = 1 then
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao
   else
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
   with ACBrNFe1.EventoNFe.Evento.new do
   begin
      Log('Enviando carta de correção');
      infEvento.chNFe := arq[1];
      infEvento.CNPJ := arq[4];
      infEvento.dhEvento := Now;
      infEvento.tpEvento := teCCe;
      infEvento.nSeqEvento := StrToInt(arq[2]);
      infEvento.detEvento.xCorrecao := arq[3];
   end;
   ConfigurarAcbr;
   ACBrNFe1.EnviarEvento(1);
  // MmLog.Lines.Text := UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.XML);
   Result.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
         Items[0].RetInfEvento.xml));
  // res.Add(inttostr(ACBrNFe1.WebServices.EnvEvento.cStat));
   if FileExists(diretorioXmlAssinado + xml) then
   begin
      Log('Arquivo assinado já existe. Excluindo.');
      TFile.Delete(diretorioXmlAssinado + xml);
   end;
   if (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
      .RetInfEvento.cStat = 135) then
      AtualizarCarta(arq[1]);
   Log('Salvando xml.');
   Log(diretorioXmlAssinado + xml);
   Result.SaveToFile(diretorioXmlAssinado + xml);
   mensagem := IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
      Items[0].RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.
      EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo;
   Log(mensagem);
   MostrarNotificacao('Carta de correção de NF', mensagem);
end;

procedure TFmPrincipal.ChamaAtualizador;
begin
   try
      ShellExecute(Handle, 'open', PChar(diretorioRaiz + '\AtualizadorAssina.exe'),
         nil, nil, SW_SHOWNORMAL);
   except
      on E: Exception do
         Log('Erro ao abrir atualizador - ' + E.message);
   end;
end;

procedure TFmPrincipal.ConfigurarAcbr;
begin
   ACBrNFe1.Configuracoes.Geral.SSLLib := libWinCrypt;
  // ACBrNFe1.Configuracoes.WebServices.SSLType := LT_TLSv1_2;
  // ACBrNFe1.SSL.SSLType := LT_TLSv1_2;

   case CbSSL.ItemIndex of
      0:
         ACBrNFe1.SSL.SSLType := LT_all;
      1:
         ACBrNFe1.SSL.SSLType := LT_SSLv2;
      2:
         ACBrNFe1.SSL.SSLType := LT_SSLv3;
      3:
         ACBrNFe1.SSL.SSLType := LT_TLSv1;
      4:
         ACBrNFe1.SSL.SSLType := LT_TLSv1_1;
      5:
         ACBrNFe1.SSL.SSLType := LT_TLSv1_2;
      6:
         ACBrNFe1.SSL.SSLType := LT_SSHv2;
   else
      ACBrNFe1.SSL.SSLType := LT_all;
   end;

   case CbSSL.ItemIndex of
      0:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_all;
      1:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_SSLv2;
      2:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_SSLv3;
      3:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_TLSv1;
      4:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_TLSv1_1;
      5:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_TLSv1_2;
      6:
         ACBrNFe1.Configuracoes.WebServices.SSLType := LT_SSHv2;
   else
      ACBrNFe1.Configuracoes.WebServices.SSLType := LT_all;
   end;

   ACBrNFe1.Configuracoes.Geral.SSLCryptLib := cryWinCrypt;
   ACBrNFe1.Configuracoes.Geral.SSLHttpLib := httpWinHttp;
   ACBrNFe1.Configuracoes.Geral.SSLXmlSignLib := xsLibXml2;
   ACBrNFe1.Configuracoes.Geral.VersaoDF := ve400;
   ACBrNFe1.Configuracoes.Geral.VersaoQRCode := veqr200;
   ACBrNFe1.Configuracoes.arquivos.PathSchemas := 'Schemas\ve400\';

  //
   ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := 0;
   ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet := False;
  // ACBrNFe1.Configuracoes.WebServices.Ambiente                 := StrToTpAmb(Ok,varAmb);
   ACBrNFe1.Configuracoes.WebServices.Tentativas := 10;
   ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := 5000;
   ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas := 3000;
   ACBrNFe1.Configuracoes.WebServices.TimeOut := (30 * 3000);
  // ACBrNFe1.configuracoes.WebServices.UF                       := varUF;
   ACBrNFe1.Configuracoes.WebServices.Visualizar := False;
   ACBrNFe1.Configuracoes.WebServices.ProxyHost := '';
   ACBrNFe1.Configuracoes.WebServices.ProxyPort := '';
   ACBrNFe1.Configuracoes.WebServices.ProxyUser := '';
   ACBrNFe1.Configuracoes.WebServices.ProxyPass := '';
   ACBrNFe1.Configuracoes.WebServices.Salvar := False;
end;

procedure TFmPrincipal.ConfiguraCertificadoDigital;
begin
   ACBrNFe1.Configuracoes.Certificados.NumeroSerie := Certificado;
   ACBrNFe1.Configuracoes.Certificados.Senha := Pin;
   ACBrNFe1.Configuracoes.arquivos.PathSchemas := 'Schemas\ve400\';
end;

procedure TFmPrincipal.CriaEntradaRegistro;
var
   varReg: TRegistry;
   varAux: string;
   arquivoConfiguracaoIni: TIniFile;
begin
   Log('Adicionando entrada no registro do windows');
   varReg := TRegistry.Create;
   varAux := ExtractFileDir(Application.ExeName) + '\' +
      ExtractFileName(Application.ExeName);
   varReg.rootkey := HKEY_LOCAL_MACHINE;
   varReg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN', False);
   varReg.WriteString('AssinaNf', '"' + varAux + '"');
   varReg.closekey;
   varReg.Free;
   Log('Concluído.');
end;

procedure TFmPrincipal.PostExcluirArquivo(xmlNome: String);
var
   Api: TApi;
   postString: String;
begin
   Api := TApi.Create('AFFINCONF');
   try

      postString := 'CONTROLE=010889&FUNCAO=excluirArquivo' +
                    '&diretorio='+caminhoXmlNaoAssinado+
                    '&arquivo='+xmlNome;

      api.post('buscadados.php', postString);
      Log('Excluir arquivo: ' + api.responseBody);
   finally
      api.Destroy;
   end;

end;

function TFmPrincipal.FileSize(fileName: WideString): Int64;
var
   sr: TSearchRec;
begin
   if FindFirst(fileName, faAnyFile, sr) = 0 then
      Result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) +
         Int64(sr.FindData.nFileSizeLow)
   else
      Result := -1;
   FindClose(sr);
end;

function TFmPrincipal.FormatByteSize(const bytes: Integer): string;
const
   B = 1; // byte
   KB = 1024 * B; // kilobyte
   MB = 1024 * KB; // megabyte
   GB = 1024 * MB; // gigabyte
begin
   if bytes > GB then
      Result := FormatFloat('#.## GB', bytes / GB)
   else if bytes > MB then
      Result := FormatFloat('#.## MB', bytes / MB)
   else if bytes > KB then
      Result := FormatFloat('#.## KB', bytes / KB)
   else
      Result := FormatFloat('#.## bytes', bytes);
end;

procedure TFmPrincipal.FormCreate(Sender: TObject);
begin
   CoInitialize(nil);
   pararThread := False;

   diretorioRaiz := ExtractFilePath(Application.Exename);
   diretorioXmlBaixado := diretorioRaiz + 'xmls\';
   diretorioXmlAssinado := diretorioRaiz + 'assinadas\';

   Log(diretorioRaiz);
   Log(diretorioXmlBaixado);
   Log(diretorioXmlAssinado);

   if not DirectoryExists(diretorioXmlBaixado) then
      CreateDir(diretorioXmlBaixado);

   if not DirectoryExists(diretorioXmlAssinado) then
      CreateDir(diretorioXmlAssinado);

   arquivoConfiguracao := diretorioRaiz + ARQ_CONF;

   if not FileExists(arquivoConfiguracao) then
   begin
      PnConf.Top := 8;
      PnConf.Left := 42;
      PnConf.Visible := True;
      Exit;
   end;

   ACBrNFe1 := TACBrNFe.Create(Self);

   if not LeArquivoConfiguracao then
      Exit;

   if Buscadados then
   begin
      caminhoXMLNaoAssinado := StringReplace(CAMINHO_XML_NAO_ASSINADO,
         '$emp', codigoEmpresa, [rfReplaceAll, rfIgnoreCase]);

      caminhoXMLNaoAssinado := StringReplace(caminhoXMLNaoAssinado,
         '$amb', ambiente, [rfReplaceAll, rfIgnoreCase]);

      caminhoXMLAssinado := StringReplace(CAMINHO_XML_ASSINADO,
         '$emp', codigoEmpresa, [rfReplaceAll, rfIgnoreCase]);

      caminhoXMLAssinado := StringReplace(caminhoXMLAssinado,
         '$amb', ambiente, [rfReplaceAll, rfIgnoreCase]);
      TmFtp.Enabled := True;
   end;
end;

procedure TFmPrincipal.FormDestroy(Sender: TObject);
begin
   ThAssina.Terminate;
end;

function TFmPrincipal.VerificarSeAplicaticoEstarRodandoPeloNomeDoExecutavel(Nome: string): Boolean;
var
   rId: array[0..999] of DWord;
   i, NumProc, NumMod: DWord;
   HProc, HMod: THandle;
   sNome: string;
   Tamanho, Count: Integer;
   sNomeTratado: string;
begin
   sNomeTratado := '';
   Result := False;
   SetLength(sNome, 256);
  // Aqui vc pega os IDs dos processos em execução
   EnumProcesses(@rId[0], 4000, NumProc);

  // Aqui vc faz um for p/ pegar cada processo
   for i := 0 to NumProc div 4 do
   begin
    // Aqui vc seleciona o processo
      HProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
         False, rId[i]);
      if HProc = 0 then
         Continue;
    // Aqui vc pega os módulos do processo
    // Como vc só quer o nome do programa, então será sempre o primeiro
      EnumProcessModules(HProc, @HMod, 4, NumMod);
    // Aqui vc pega o nome do módulo; como é o primeiro, é o nome do programa
      GetModuleBaseName(HProc, HMod, @sNome[1], 256);
      sNomeTratado := Trim(sNome);
      Tamanho := Length(sNomeTratado);
      Count := 1;
      while Count <= Tamanho do
      begin
         if sNomeTratado[Count] = '' then
            Break;
         Count := Count + 1;
      end;
      sNomeTratado := Copy(sNomeTratado, 1, Count - 1);
      if AnsiUpperCase(sNomeTratado) = AnsiUpperCase(Nome) then
      begin
         Result := True;
         CloseHandle(HProc);
         Exit;
      end
      else
         Result := False;
    // Aqui vc libera o handle do processo selecionado
      CloseHandle(HProc);
   end;
end;

procedure TFmPrincipal.FormShow(Sender: TObject);

begin


   StatusBar1.Panels[0].Text := VersaoExe + '.2025.12.19';
end;

function TFmPrincipal.GravaArquivoConfiguracao: Boolean;
var
   ArqIni: TIniFile;
begin
   Result := False;
   ArqIni := TIniFile.Create(arquivoConfiguracao);
   try
      try
         ArqIni.WriteString('CONFIGURACAO', 'EMPRESA', EdEmp.text);
         ArqIni.WriteString('CONFIGURACAO', 'FILIAL', EdFil.text);
         ArqIni.WriteString('CONFIGURACAO', 'USUARIO', EdUsu.text);
         ArqIni.WriteString('CONFIGURACAO', 'SENHA',
            IdEnc.EncodeString(EdSen.text));
         ArqIni.WriteString('CONFIGURACAO', 'CERTIFICADO',
            IdEnc.EncodeString(LbCer.Caption));
         ArqIni.WriteString('CONFIGURACAO', 'PIN', IdEnc.EncodeString(EdPin.text));
         ArqIni.WriteString('CONFIGURACAO', 'SSL', IntToStr(CbSSL.ItemIndex));
         Result := True;
      except
         on E: Exception do
         begin
            ShowMessage('Erro ao gravar o arquivo de configuração: ' + E.message);
            Result := False;
         end;
      end;
   finally
      ArqIni.Free;
   end;
end;


procedure TFmPrincipal.Label8Click(Sender: TObject);
begin
   PnAviso.Visible := False;
end;

function TFmPrincipal.LeArquivoConfiguracao: Boolean;
var
   ArqIni: TIniFile;
   Ok: Boolean;
   SSL: Integer;
begin
   Result := False;
   ArqIni := TIniFile.Create(arquivoConfiguracao);
   try
      try
         codigoEmpresa := ArqIni.ReadString('CONFIGURACAO', 'EMPRESA', '000');
         filial := ArqIni.ReadString('CONFIGURACAO', 'FILIAL', '000');
         usuario := ArqIni.ReadString('CONFIGURACAO', 'USUARIO', '000');
         senha := IdDec.DecodeString(ArqIni.ReadString('CONFIGURACAO',
               'SENHA', '000'));
         Certificado := IdDec.DecodeString(ArqIni.ReadString('CONFIGURACAO',
               'CERTIFICADO', '000'));
         Pin := IdDec.DecodeString(ArqIni.ReadString('CONFIGURACAO',
               'PIN', '000'));
         SSL := StrToInt(ArqIni.ReadString('CONFIGURACAO', 'SSL', '5'));
         EdEmp.text := codigoEmpresa;
         EdFil.text := filial;
         EdUsu.text := 'prosis';
         EdSen.text := 'prosis';
         LbCer.Caption := Certificado;
         EdPin.text := Pin;
         CbSSL.ItemIndex := SSL;
         ACBrNFe1.Configuracoes.Certificados.NumeroSerie := LbCer.Caption;
         ACBrNFe1.Configuracoes.arquivos.PathSchemas := 'Schemas\ve400\';
         ACBrNFe1.Configuracoes.Geral.FormaEmissao := TpcnTipoEmissao(0);
         ACBrNFe1.Configuracoes.Geral.ModeloDF := TpcnModeloDF(0);
         ACBrNFe1.Configuracoes.Geral.VersaoDF := TpcnVersaoDF(2);

         ACBrNFe1.Configuracoes.WebServices.UF := 'RS';
         ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao;

         Result := True;
      except
         on E: Exception do
         begin
            ShowMessage('Erro ao ler o arquivo de configuração: ' + E.message);
            Result := False;
         end;
      end;
   finally
      ArqIni.Free;
   end;
end;

procedure TFmPrincipal.Log(varMsg: string);
begin

   FmPrincipal.MmLog.Lines.Add(DateTimeToStr(Now) + ' :: ' + varMsg);
end;

procedure TFmPrincipal.PnConfClick(Sender: TObject);
begin
   BtConfClick(Sender);
end;

function TFmPrincipal.RodarComoAdministrador(hWnd: hWnd; arquivoConfiguracao, varPar: string): Boolean;
var
   sei: TShellExecuteInfo;
begin
   Log('Rodando instalação capicom.');
   ZeroMemory(@sei, SizeOf(sei));
   sei.cbSize := SizeOf(TShellExecuteInfo);
   sei.Wnd := hWnd;
   sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
   sei.lpVerb := PWideChar('runas');
   sei.lpFile := PWideChar(arquivoConfiguracao); // PAnsiChar;
   if varPar <> '' then
      sei.lpParameters := PWideChar(varPar); // PAnsiChar;
   sei.nShow := SW_SHOWNORMAL; // Integer;
   Result := ShellExecuteEx(@sei);
   Log('Instalação capicom concluída.');
end;

procedure TFmPrincipal.TbBuscarNotasClick(Sender: TObject);
begin
   ThAssina := TThread.CreateAnonymousThread(
      procedure
      begin
         BuscaAssinaNota;
      end);
   ThAssina.start();
end;

procedure TFmPrincipal.TbConfClick(Sender: TObject);
begin
   TmFtp.Enabled := False;
   PnConf.Top := 0;
   PnConf.Left := 0;
   PnConf.Visible := True;
   if PnAviso.Visible then
      PnAviso.Visible := False;
end;

procedure TFmPrincipal.TbPararTimerClick(Sender: TObject);
begin
   Application.ProcessMessages;

   pararThread := True;

   TmFtp.Enabled := not TmFtp.Enabled;
   Application.ProcessMessages;
   if TmFtp.Enabled then
      TbPararTimer.Caption := 'Parar timer'
   else
      TbPararTimer.Caption := 'Iniciar timer';
   TbPararTimer.Refresh;
end;

procedure TFmPrincipal.TmFtpTimer(Sender: TObject);
begin
  // só procura por notas se o sistema não estiver em atualização.
  // if not varEmAtu then
   if pararThread  then
   begin
      Log('a thread deve parar');
      Exit;
   end;

   ThAssina := TThread.CreateAnonymousThread(
      procedure
      begin
         BuscaAssinaNota;
      end);
   ThAssina.FreeOnTerminate := True;
   ThAssina.start();
end;

procedure TFmPrincipal.TmProNotTimer(Sender: TObject);
var
   S: string;
begin

end;

procedure TFmPrincipal.TrayIcon1DblClick(Sender: TObject);
begin
  { Hide the tray icon and show the window,
    setting its state property to wsNormal. }
   Show();
   WindowState := wsNormal;
   Application.BringToFront();
end;

procedure TFmPrincipal.TrocaIcone(varIco: Integer);
begin
   TrayIcon1.IconIndex := varIco;
   Application.ProcessMessages;
end;

function TFmPrincipal.ValidaCampos: Boolean;
begin
   Result := True;
   if StrToIntDef(EdEmp.text, 0) = 0 then
   begin
      ShowMessage('Código da empresa não informado.');
      EdEmp.SetFocus;
      Result := False;
      Exit;
   end;

   if StrToIntDef(EdFil.text, 0) = 0 then
   begin
      ShowMessage('Código da filial não informado.');
      EdFil.SetFocus;
      Result := False;
      Exit;
   end;

   if Length(Trim(EdUsu.text)) = 0 then
   begin
      ShowMessage('Nome do usuário não informado.');
      EdUsu.SetFocus;
      Result := False;
      Exit;
   end;

   if Length(Trim(EdSen.text)) = 0 then
   begin
      ShowMessage('Nome do usuário não informado.');
      EdSen.SetFocus;
      Result := False;
      Exit;
   end;
end;


procedure CloseMessageBox(AWnd: HWND; AMsg: UINT; AIDEvent: UINT_PTR; ATicks: DWord); stdcall;
var
   Wnd: HWND;
begin
   KillTimer(AWnd, AIDEvent);
  // active window of the calling thread should be the message box
   Wnd := GetActiveWindow;
   if IsWindow(Wnd) then
      PostMessage(Wnd, WM_CLOSE, 0, 0);
end;

function TFmPrincipal.Buscadados: Boolean;
var
   S, postString: string;
   api: TApi;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := False;
   api := TApi.Create('AFFINCONF');
   try
      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=BuscaCliente';
         postString := postString + '&COD_EMPRESA=' + codigoEmpresa;
         api.post('buscadados.php', postString);
         S := api.responseBody;

         S := Trim(S);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
            Result := False;
         end
         else
         begin
            if Length(S) > 0 then
            begin
               S := StringReplace(S, 'null', '""', [rfReplaceAll]);
               obj := SO(S);
               for i := 0 to obj.AsArray.Length - 1 do
               begin
                  obj2 := SO(obj.AsArray.S[i]);
                  CNPJemp := obj2.AsObject.S['cnpj'];
                  codigoAmbiente := obj2.AsObject.I['ambiente'];
                  if obj2.AsObject.S['razao'] = '' then
                  begin
                     ShowMessage('Razão Social não encontrada. Não é possível continuar');
                     Exit;
                  end;
                  LbEmp.Caption := obj2.AsObject.S['razao'];
               end;
               if codigoAmbiente = 2 then
                  ambiente := 'homologacao'
               else
                  ambiente := 'producao';

               LbHomologacao.Visible := codigoAmbiente = 2;

               Result := True;
            end;
         end;
      except
         on E: Exception do
         begin
            Log('Error Message: ' + E.message);
            ShowMessage
               ('Erro ao buscar dados da empresa. Nâo é possível continuar');
            Exit;
         end;
      end;
   finally
      api.Destroy;
   end;
end;

function TFmPrincipal.Post(url, postString: string): string;
var
   api: TApi;
begin
   api := TApi.Create('AFFINCONF');
   try
      try
         api.post(url, postString);
         Result := api.responseBody;
      except
         on E: Exception do
            Result := 'Erro: ' + E.message;
      end;
   finally
      api.Destroy;
   end;
end;



function TFmPrincipal.VersaoExe: string;
type
   PFFI = ^VS_FIXEDFILEINFO;
var
   F: PFFI;
   Handle: DWord;
   Len: LongInt;
   Data: PChar;
   Buffer: Pointer;
   Tamanho: DWord;
   Parquivo: PChar;
   Arquivo: string;
begin
   Arquivo := Application.ExeName;
   Parquivo := StrAlloc(Length(Arquivo) + 1);
   StrPCopy(Parquivo, Arquivo);
   Len := GetFileVersionInfoSize(Parquivo, Handle);
   Result := '';
   if Len > 0 then
   begin
      Data := StrAlloc(Len + 1);
      if GetFileVersionInfo(Parquivo, Handle, Len, Data) then
      begin
         VerQueryValue(Data, '\', Buffer, Tamanho);
         F := PFFI(Buffer);
         Result := Format('%d.%d.%d.%d', [HiWord(F^.dwFileVersionMs),
               LOWORD(F^.dwFileVersionMs), HiWord(F^.dwFileVersionLs),
               LOWORD(F^.dwFileVersionLs)]);
      end;
      StrDispose(Data);
   end;
   StrDispose(Parquivo);
end;

function TFmPrincipal.VerificaAtualizacoes: Boolean;
var
   S, varVersao, versaoatual, varDtVersao, varCaminho, varExecutavel, varAtualizador, postString: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   Result := True;

   try
      try
         versaoatual := VersaoExe;
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=VerificaAtualizacao';
         postString := postString + '&versao=' + versaoatual;
         S := Post('VerificaVersao.php', postString);
         S := Trim(S);
         S := StringReplace(S, 'null', '""', [rfReplaceAll]);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            ShowMessage(S);
         end
         else
         begin
            if Length(S) > 0 then
            begin
               obj := SO(S);
               if obj.AsArray.Length > 0 then
               begin
                  for i := 0 to obj.AsArray.Length - 1 do
                  begin
                     obj2 := SO(obj.AsArray.S[i]);
                     varVersao := obj.AsObject.S['versao'];
                     varDtVersao := obj.AsObject.S['DATA_VERSAO'];
                  end;
                  if varVersao <> versaoatual then
                  begin
                     Result := False;
                     Log('Programa desatualizado, preparando para atualizar');
                  end
                  else
                  begin
                     Result := True;
                     Log('Programa atualizado');
                  end;
               end;
            end;
         end;
      except
         on E: Exception do
            Log('Error Message: ' + E.message);
      end;
   finally

   end;
end;

{ TMyClass }

constructor TMyClass.create;
begin
   CoInitialize(nil);
end;

procedure TMyClass.Download(FileURL, Destination: string);
var
  RestClient: TRestClient;
begin
  RestClient := TRestClient.Create(nil);
  try
    RestClient.ConnectionType := hctWinHttp;

    FDestination := Destination;
    RestClient.Resource(FileURL).Get(HandleResponse);
  finally
    RestClient.Free;
  end;
end;

procedure TMyClass.HandleResponse(Response: TStream);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FDestination, fmCreate);
  try
    Response.Position := 0;
    FileStream.CopyFrom(Response, Response.Size);
  finally
    FileStream.Free;
  end;

end;

end.

