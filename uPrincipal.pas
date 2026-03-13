unit uPrincipal;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
   Vcl.ExtCtrls, Vcl.ImgList, Vcl.Imaging.pngimage, IdMultipartFormData, IniFiles, Vcl.ToolWin, Vcl.ComCtrls, DCPcrypt2, DCPsha1, IdCoder, IdCoder3to4,
   IdCoderMIME, IdBaseComponent, ACBrNFe, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdGlobal, IdExplicitTLSClientServerBase,
   System.IOUtils, Vcl.AppEvnts, DateUtils, pcnConversaoNFe, PSAPI, TlHelp32, Registry, ACBrDFeSSL, Shellapi, Vcl.ExtDlgs, ACBrEAD,
   ACBrUtil, ACBrDFeUtil, ACBrBase, ACBrDFe, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, blcksock, SuperObject, RestClient,
   RestUtils, HttpConnection, ActiveX, ACBrEnterTab, Vcl.Buttons;

const
   ARQ_CONF = 'conf.ini';
   URL_API = 'api.php';
   COD_SISTEMA = 91;
   COD_ATUALIZADOR = 92;
   CAMINHO_XML_NAO_ASSINADO = 'nfephp/Empresas/$emp/1/Nfe/$amb/entradas/A3/';
   CAMINHO_XML_ASSINADO = 'nfephp/Empresas/$emp/1/Nfe/$amb/';
   VERSAO = '2026.03.13.01';

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
      ImageList1: TImageList;
      ToolBar1: TToolBar;
      IdEnc: TIdEncoderMIME;
      IdDec: TIdDecoderMIME;
      TbConf: TToolButton;
    TmVoltarBuscar: TTimer;
      MmLog: TMemo;
    TmBuscar: TTimer;
      TrayIcon1: TTrayIcon;
      ImageList2: TImageList;
      LbEmp: TLabel;
      ApplicationEvents1: TApplicationEvents;
      PnAviso: TPanel;
      Image2: TImage;
      Label8: TLabel;
      OpenPictureDialog1: TOpenPictureDialog;
      IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
      RestClient1: TRestClient;
    TbBuscarNotas: TToolButton;
    TbPararTimer: TToolButton;
    LbStatus: TLabel;
    StatusBar1: TStatusBar;
        LbHomologacao: TLabel;
    ACBrEnterTab1: TACBrEnterTab;
    PnModoTeste: TPanel;
    BtModoTeste: TBitBtn;
    Label7: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    PnConf: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label10: TLabel;
    EdEmp: TEdit;
    EdFil: TEdit;
    EdUsu: TEdit;
    EdSen: TEdit;
    GroupBox1: TGroupBox;
    Label6: TLabel;
    LbCer: TLabel;
    Button1: TButton;
    EdPin: TEdit;
    RadioGroup1: TRadioGroup;
    BtConf: TButton;
    CbSSL: TComboBox;
    ACBrNFe1: TACBrNFe;
      procedure FormShow(Sender: TObject);
      procedure TbConfClick(Sender: TObject);
      procedure Button1Click(Sender: TObject);
      procedure TmVoltarBuscarTimer(Sender: TObject);
      procedure TmBuscarTimer(Sender: TObject);
      procedure TrayIcon1DblClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
      procedure BtConfClick(Sender: TObject);
      procedure Label8Click(Sender: TObject);
      procedure PnConfClick(Sender: TObject);
    procedure TbPararTimerClick(Sender: TObject);
    procedure TbBuscarNotasClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtModoTesteClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);


   private
    { Private declarations }
      arquivoConfiguracao, codigoEmpresa, filial, usuario, senha, Certificado,
      Pin, arquivoConfiguracaoXML, diretorioXmlAssinado,
      CNPJemp, ambiente, tokenid, token, diretorioRaiz,
      diretorioXmlBaixado, caminhoXMLNaoAssinado, caminhoXMLAssinado: string;
      pararThread, modoTeste: Boolean;
      mes, ano, codigoAmbiente: Integer;
      function GravaArquivoConfiguracao: Boolean;
      procedure ConfigurarAcbr;
      function LeArquivoConfiguracao: Boolean;
      function ValidaCampos: Boolean;
      function AssinaXML(arquivoConfiguracao, varXml: string; varNF: Integer): Boolean;
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
      function CartaCorrecao(arq: TStrings; xml: string): Boolean;
      function CancelarNota(arq: TStrings; xml: string): Boolean;
      function Manifesto(arq: TStrings; xml: string): Boolean;
      function Inutilizar(arq: TStrings; xml: string): Boolean;
      function PostAtualizarCarta(chave: string): Boolean;
      function buscaToken: Boolean;
      function PostExcluirArquivo(nomeXML: String): Boolean;
      function PostCancelar(chave, xjust: string): Boolean;
      function PostAtualizaManifesto(chave, tipo: string): Boolean;
      function atualizaInutilizadas(serie, ini, fim, modelo: string): Boolean;
      function VersaoExe: string;
      procedure ChamaAtualizador;
      function VerificarSeAplicaticoEstarRodandoPeloNomeDoExecutavel(Nome: string): Boolean;
      function Post(url, postString, postFiles: string): string;
      procedure MostrarNotificacao(titulo, mensagem: String);
      function BuscarNotas: ISuperObject;
      function PostListarArquivos: String;
      function PostEnviarXML(nomeXML, pasta: String): Boolean;
      function DownloadXML(nomeXML: String): Boolean;
      function TratarRetornoPost(S: String): Boolean;
      procedure ExibirStatusModoTeste;
   public

    { Public declarations }
   end;

var
   FmPrincipal: TFmPrincipal;
   ThAssina, ThEventos: TThread;

implementation

uses
   pcnConversao, load, uApi, uComum;

{$R *.dfm}

function TFmPrincipal.AssinaXML(arquivoConfiguracao, varXml: string; varNF: Integer): Boolean;
begin
   Log('Carregando arquivo XML.');
   if ACBrNFe1.NotasFiscais.Count > 0 then
      ACBrNFe1.NotasFiscais.Delete(0);

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

   if not modoTeste then
   begin
      try
         ACBrNFe1.NotasFiscais.Assinar;
      except
         on e:exception do
         begin
            Log('erro ao assinar a nf: ' + e.message);
            Result := False;
            Exit;
         end;
      end;
   end;
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

   Result := True;
end;

function TFmPrincipal.PostAtualizaManifesto(chave, TIPO: string): Boolean;
var
   postString, S: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   try
      postString := 'CONTROLE=010889';
      postString := postString + '&FUNCAO=PostAtualizaManifesto';
      postString := postString + '&CHAVE=' + chave;
      postString := postString + '&TIPO=' + TIPO;
      S := Post(URL_API, postString, '');
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
   end;
end;

function TFmPrincipal.PostCancelar(chave, xjust: string): Boolean;
var
   postString, S: string;
begin
   try
      postString := 'CONTROLE=010889';
      postString := postString + '&FUNCAO=atualizacancela';
      postString := postString + '&CHAVE=' + chave;
      postString := postString + '&JUST=' + xjust;
      S := Post(URL_API, postString, '');
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
   end;
end;

function TFmPrincipal.buscaToken: Boolean;
var
   S, postString: string;
   obj, obj2: ISuperObject;
   i: Integer;
begin
   try
      postString := 'CONTROLE=010889';
      postString := postString + '&FUNCAO=Buscatoken';
      postString := postString + '&COD_EMPRESA=' + codigoEmpresa;
      S := Post(URL_API, postString, '');
      obj := SO(S);
      for i := 0 to obj.AsArray.Length - 1 do
      begin
         obj2 := SO(obj.AsArray.S[i]);
         tokenid := obj2.AsObject.S['tokenid'];
         token := obj2.AsObject.S['token'];
      end;
      Result := True;
   except
      on E: Exception do
      begin
         Log('Erro: ' + E.message);
         Result := False;
      end;
   end;
end;

function TFmPrincipal.atualizaInutilizadas(serie, ini, fim, modelo: string): Boolean;
var
   S, postString: string;
begin
   try
      postString := 'CONTROLE=010889';
      postString := postString + '&FUNCAO=atualizaInutilizadas';
      postString := postString + '&COD_EMPRESA=' + codigoEmpresa;
      postString := postString + '&SERIE=' + serie;
      postString := postString + '&INI=' + ini;
      postString := postString + '&FIM=' + fim;
      postString := postString + '&MODELO=' + modelo;
      S := Post(URL_API, postString, '');
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
   end;

end;

function TFmPrincipal.PostAtualizarCarta(chave: string): Boolean;
var
   S, postString: string;
begin
   try
      postString := 'CONTROLE=010889';
      postString := postString + '&FUNCAO=atualizacarta';
      postString := postString + '&CHAVE=' + chave;
      S := Post(URL_API, postString, '');
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
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
         MmLog.Visible := True;
         ConfiguraCertificadoDigital;
         if Buscadados then
            TmBuscar.Enabled := True;

      end;
end;

procedure TFmPrincipal.BtModoTesteClick(Sender: TObject);
begin
   modoTeste := not modoTeste;
   GravaArquivoConfiguracao;
   ExibirStatusModoTeste;

end;

procedure TFmPrincipal.BuscaAssinaNota;
var
   FileNames: TStringList;
   varNF, varErro, i: Integer;
   arq: TextFile; { declarando a variável "arq" do tipo arquivo texto }
   cami, res, pasta, postString, xmlBaixados, nomeXML: string;
   Arquivo: TStrings;
   obj, objXML: ISuperObject;
   retorno: Boolean;
begin
   TmBuscar.Enabled := False;
   FileNames := TStringList.Create;
   varErro := 0;

   if not Buscadados then
      Exit;

   try
      obj := BuscarNotas;
      if (obj = nil) then
      begin
         TrocaIcone(4);
         Application.ProcessMessages;
         TmBuscar.Enabled := True;
         Exit;
      end;

   except
      Log('Nenhuma nota encontrada');
      TrocaIcone(4);
      Application.ProcessMessages;
      TmBuscar.Enabled := True;
      Exit;
   end;

   Show;


   try
      try
         for i := 0 to obj.AsArray.Length - 1 do
         begin
            try
               Sleep(100);
               objXML := SO(obj.AsArray.S[i]);
               nomeXML := objXML.AsObject.S['nome'];
               Log('XML: ' + nomeXML);

               if not DownloadXML(nomeXML) then
                  Continue;

               Arquivo := TStringList.Create;
               Arquivo.LoadFromFile(diretorioXmlBaixado + nomeXML);
               pasta := '';
               if Pos('canc', nomeXML) > 0 then
               begin
                  retorno := CancelarNota(Arquivo, nomeXML);
                  pasta := 'canceladas'
               end;

               if Pos('mani', nomeXML) > 0 then
               begin
                  retorno := Manifesto(Arquivo, nomeXML);
                  pasta := 'eventos'
               end;

               if Pos('inut', nomeXML) > 0 then
               begin
                  retorno := Inutilizar(Arquivo, nomeXML);
                  pasta := 'inutilizadas';
               end;

               if Pos('-cc-', nomeXML) > 0 then
               begin
                  retorno := CartaCorrecao(Arquivo, nomeXML);
                  pasta := 'cartacorrecao';
               end;

               if pasta = '' then
               begin
                  pasta := 'assinadas';
                  varNF := StrToInt(Copy(nomeXML, 26, 9));
                  Log('Nota: ' + IntToStr(varNF));
                  if not AssinaXML(diretorioXmlBaixado + nomeXML, nomeXML, varNF) then
                     Continue;

                  Log('atualizar nota assinada: ' + postString + ' >> ' + diretorioXmlAssinado + nomeXML);

               end;

               Sleep(50);

               retorno := PostEnviarXML(nomeXML, pasta);

               if not retorno then
                  Continue;

               PostExcluirArquivo(nomeXML);

               if pasta = 'assinadas' then
               begin
                  LbStatus.Caption := 'XML Assinado';
                  LbStatus.Refresh;
                  Log('Arquivo XML assinado da Nota número: ' + IntToStr(varNF)
                     + ' enviado corretamente. Sua nota pode ser transmitida.');
               end;


            except
               on e:Exception do
                  Log('Erro ao ler as notas: ' + e.message);
            end;
         end
      except
         on E: Exception do
         begin
            Log('1 ' + E.message);
         end;
      end;
   finally
      TrocaIcone(4);
      Application.ProcessMessages;
      TmBuscar.Enabled := True;
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

function TFmPrincipal.manifesto(arq: TStrings; xml: string): Boolean;
var
   mensagem, S: string;
   ArquivoTexto: TextFile;
   retorno: Boolean;
   ret: Integer;
   slXmlAssinado: TStringList;
begin
   try

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
      if not modoTeste then
         retorno := ACBrNFe1.EnviarEvento(codigoAmbiente);

      slXmlAssinado := TStringList.Create;
      try
         ret := ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat;

         if (ret = 135) or (ret = 136) then
         begin


            PostAtualizaManifesto(arq[1], arq[2]);

            slXmlAssinado.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
              Items[0].RetInfEvento.xml));


            if FileExists(diretorioXmlAssinado + xml) then
            begin
               Log('Arquivo assinado já existe. Excluindo.');
               TFile.Delete(diretorioXmlAssinado + xml);
            end;

            Log('Salvando xml');
            Log(diretorioXmlAssinado + xml);
            slXmlAssinado.SaveToFile(diretorioXmlAssinado + xml);
         end;

      finally
         slXmlAssinado.Free;
      end;

      mensagem := (IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat) + ' - ' +
                   ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo);
      Log('Mensagem manifesto: ' + mensagem);
      MostrarNotificacao('Manifesto de destinatario de NF', mensagem);
   except
      on E: Exception do
         Log('erro: ' + E.message);
   end;
end;

procedure TFmPrincipal.MostrarNotificacao(titulo, mensagem: String);
begin
   TrayIcon1.BalloonTitle := titulo;
   TrayIcon1.ShowBalloonHint;
   TrayIcon1.BalloonHint := mensagem;
end;

function TFmPrincipal.CancelarNota(arq: TStrings; xml: string): Boolean;
var
   mensagem, S: string;
   ArquivoTexto: TextFile; { handle do arquivo texto }
   retorno: Boolean;
   slXmlAssinado: TStringList;
begin
   try
      ACBrNFe1.NotasFiscais.Clear;
      ACBrNFe1.EventoNFe.Evento.Clear;
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

      if not modoTeste then
         retorno := ACBrNFe1.EnviarEvento(codigoAmbiente);

      if ACBrNFe1.WebServices.EnvEvento.cStat <> 128 then
      begin
         Log('Status: ' + IntToStr(ACBrNFe1.WebServices.EnvEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.xMotivo);

            Exit;
      end
      else
      begin
         if (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat <> 135) and
            (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat <> 573) then
         begin
            Log('Status: ' + IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo);

            Exit;
         end;
      end;

      slXmlAssinado := TStringList.Create;
      try
         if FileExists(diretorioXmlAssinado + xml) then
         begin
            Log('Arquivo assinado já existe. Excluindo.');
            TFile.Delete(diretorioXmlAssinado + xml);
         end;

         PostCancelar(arq[1], arq[3]);
         slXmlAssinado.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
              Items[0].RetInfEvento.xml));

         slXmlAssinado.SaveToFile(diretorioXmlAssinado + xml);
         TFile.Delete(diretorioXmlBaixado + xml);
      finally
         slXmlAssinado.Free;
      end;


      mensagem := IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
         .RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.
         EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo;
      Log('Mensagem cancelar: ' + mensagem);
      MostrarNotificacao('Cancelamento de NF', mensagem);

   except
      on E: Exception do
         Log('erro: ' + E.message);
   end;
end;

function TFmPrincipal.Inutilizar(arq: TStrings; xml: string): Boolean;
var
   S: string;
   slXmlAssinado: TStringList;
begin
   ACBrNFe1.NotasFiscais.Clear;

   if codigoAmbiente = 1 then
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taProducao
   else
      ACBrNFe1.Configuracoes.WebServices.Ambiente := taHomologacao;
   ConfigurarAcbr;
   try
      Log('Inutilizando Notas');

      if not modoTeste then
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

   slXmlAssinado := TStringList.Create;

   try
      slXmlAssinado.Add(UTF8Encode(ACBrNFe1.WebServices.Inutilizacao.XML_ProcInutNFe));
      if FileExists(diretorioXmlAssinado + xml) then
      begin
         Log('Arquivo assinado já existe. Excluindo.');
         TFile.Delete(diretorioXmlAssinado + xml);
      end;
      atualizaInutilizadas(arq[1], arq[2], arq[3], arq[6]);
      Log('Salvando xml.');
      Log(diretorioXmlAssinado + xml);
      slXmlAssinado.SaveToFile(diretorioXmlAssinado + xml);
      TFile.Delete(diretorioXmlBaixado + xml);
   finally
      slXmlAssinado.Free;
   end;
end;

function TFmPrincipal.CartaCorrecao(arq: TStrings; xml: string): Boolean;
var
   mensagem, S: string;
   slXmlAssinado: TStringList;
begin

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
   if not modoTeste then
      ACBrNFe1.EnviarEvento(1);

   if (ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.cStat = 135) then
      PostAtualizarCarta(arq[1]);

   try
      slXmlAssinado := TStringList.Create;
      slXmlAssinado.Add(UTF8Encode(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.xml));

      if FileExists(diretorioXmlAssinado + xml) then
      begin
         Log('Arquivo assinado já existe. Excluindo.');
         TFile.Delete(diretorioXmlAssinado + xml);
      end;
      Log('Salvando xml: ' + diretorioXmlAssinado + xml);

      slXmlAssinado.SaveToFile(diretorioXmlAssinado + xml);
   finally
      slXmlAssinado.Free;
   end;

   mensagem := IntToStr(ACBrNFe1.WebServices.EnvEvento.EventoRetorno.retEvento.
   Items[0].RetInfEvento.cStat) + ' - ' + ACBrNFe1.WebServices.EnvEvento.
   EventoRetorno.retEvento.Items[0].RetInfEvento.xMotivo;
   Log('Mensagem Carta de Correção: ' + mensagem);
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
   ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := 0;
   ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet := False;
   ACBrNFe1.Configuracoes.WebServices.Tentativas := 10;
   ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet := 5000;
   ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas := 3000;
   ACBrNFe1.Configuracoes.WebServices.TimeOut := (30 * 3000);
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

function TFmPrincipal.DownloadXML(nomeXML: String): Boolean;
var
   MyClass: TMyClass;
begin
   MyClass := TMyClass.Create;
   try
      Result := True;
      try
         MyClass.Download(BASEURL + caminhoXmlNaoAssinado + nomeXML,
             diretorioXmlBaixado + nomeXML);
      except
         on e:Exception do
         begin
            Log('Erro ao baixar arquivo: ' + e.message);
            Result := False;
         end;
      end;

      if not FileExists(diretorioXmlBaixado + nomeXML) then
      begin
         Log('O arquivo ' + nomeXML + ' não foi baixado');
         Result := False;
      end;

   finally
      MyClass.Destroy;
   end;
end;

procedure TFmPrincipal.ExibirStatusModoTeste;
begin
   if modoTeste then
   begin
      Label11.Caption := 'Modo teste ativado';
      BtModoTeste.Kind := bkAbort;
      BtModoTeste.Caption := 'Desativar';
      BtModoTeste.Tag := 1;
   end
   else
   begin
      Label11.Caption := 'Modo teste desativado';
      BtModoTeste.Kind := bkYes;
      BtModoTeste.Caption := 'Ativar';
      BtModoTeste.Tag := 0;
      modoTeste := False;
   end;
   Application.ProcessMessages;
end;

function TFmPrincipal.PostEnviarXML(nomeXML, pasta: String): Boolean;
var
   S: String;
begin

   try
      S := Post(URL_API, 'CONTROLE=010889&FUNCAO=receberArquivo' +
         '&diretorio_upload=' + caminhoXmlAssinado + pasta + '/',
         'arquivo='+diretorioXmlAssinado + nomeXML);
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
   end;

end;

function TFmPrincipal.PostExcluirArquivo(nomeXML: String): Boolean;
var
   postString, S: String;
begin
   try
      postString := 'CONTROLE=010889&FUNCAO=excluirArquivo' +
                    '&diretorio='+caminhoXmlNaoAssinado+
                    '&arquivo='+nomeXML;

      S := Post(URL_API, postString, '');
      Result := TratarRetornoPost(S);
   except
      on E: Exception do
      begin
         Log('erro: ' + E.message);
         Result := False;
      end;
   end;

end;

function TFmPrincipal.PostListarArquivos: String;
var
   postString: String;
begin
   try
      postString := 'CONTROLE=010889&FUNCAO=listarArquivos' +
               '&PATH=' + caminhoXMLNaoAssinado;

      Result := Post(URL_API, postString, '');
   except
      on e:Exception do
      begin
         Log('Erro ao listar arquivos: ' + e.message);
         Result := 'Erro ao listar arquivos: ' + e.message;
      end;
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
      PnConf.Top := 0;
      PnConf.Left := 0;
      MmLog.Visible := False;
      PnConf.Visible := True;
      Exit;
   end;

   ACBrNFe1 := TACBrNFe.Create(Self);

   if not LeArquivoConfiguracao then
      Exit;

   if not Buscadados then
      Exit;

   caminhoXMLNaoAssinado := StringReplace(CAMINHO_XML_NAO_ASSINADO,
      '$emp', codigoEmpresa, [rfReplaceAll, rfIgnoreCase]);

   caminhoXMLNaoAssinado := StringReplace(caminhoXMLNaoAssinado,
      '$amb', ambiente, [rfReplaceAll, rfIgnoreCase]);

   caminhoXMLAssinado := StringReplace(CAMINHO_XML_ASSINADO,
      '$emp', codigoEmpresa, [rfReplaceAll, rfIgnoreCase]);

   caminhoXMLAssinado := StringReplace(caminhoXMLAssinado,
      '$amb', ambiente, [rfReplaceAll, rfIgnoreCase]);

   StatusBar1.Panels[0].Text := VERSAO;

   TmBuscar.Enabled := True;

end;

procedure TFmPrincipal.FormDestroy(Sender: TObject);
begin
   try
      ThAssina.Terminate;
   except
   end;
end;

procedure TFmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   comum: TComum;
begin
   if Key = VK_ESCAPE then
      if PnModoTeste.Visible then
         PnModoTeste.Visible := False;


   if Key = VK_F7 then
   begin
      TmBuscar.Enabled := False;
      TbPararTimer.Caption := 'Iniciar timer';
      comum := TComum.Create;
      try
         senha := InputBox('Acesso Restrito', 'Informe a senha diária', '0');

         if senha = comum.gerarSenhaDemonstracao(DayOf(Date), MonthOf(Date), YearOf(Date)) then
         begin
            PnModoTeste.Visible := True;
            BtModoTeste.SetFocus;

            ExibirStatusModoTeste;
            TmVoltarBuscar.Enabled := True;
         end;
      finally

         comum.Destroy;
      end;
   end;
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
   StatusBar1.Panels[0].Text := VERSAO;
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
         ArqIni.WriteBool('CONFIGURACAO', 'MODO_TESTE', modoTeste);
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

         modoTeste := ArqIni.ReadBool('CONFIGURACAO', 'MODO_TESTE', false);


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
   TmBuscar.Enabled := False;
   PnConf.Top := 0;
   PnConf.Left := 0;
   PnConf.Visible := True;
   if PnAviso.Visible then
      PnAviso.Visible := False;
end;

procedure TFmPrincipal.TbPararTimerClick(Sender: TObject);
begin
   TmBuscar.Enabled := not TmBuscar.Enabled;
   Application.ProcessMessages;

   if TmBuscar.Enabled then
   begin
      TbPararTimer.Caption := 'Parar timer';
      pararThread := True;
   end
   else
   begin
      TbPararTimer.Caption := 'Iniciar timer';
      pararThread := False;
   end;
   TbPararTimer.Refresh;
   Application.ProcessMessages;
end;

procedure TFmPrincipal.TmBuscarTimer(Sender: TObject);
begin
  // só procura por notas se o sistema não estiver em atualização.
  // if not varEmAtu then
   if pararThread  then
   begin
      Log('a thread deve parar');
      Exit;
   end;
   try
      ThAssina := TThread.CreateAnonymousThread(
         procedure
         begin
            BuscaAssinaNota;
         end);
      ThAssina.FreeOnTerminate := True;
      ThAssina.start();
   except
      on e:Exception do
         Log('Erro');
   end;
end;

procedure TFmPrincipal.TmVoltarBuscarTimer(Sender: TObject);
begin
   TmVoltarBuscar.Enabled := False;
   TmBuscar.Enabled := True;
   TbPararTimer.Caption := 'Parar Timer';
   Application.ProcessMessages;
end;

function TFmPrincipal.TratarRetornoPost(S: String): Boolean;
var
   obj: ISuperObject;
   status, erro: String;
begin
   if Length(S) = 0 then
   begin
      Result := False;
      Exit;
   end;
   try
      obj := SO(S);

      status := obj.AsObject.S['status'];
      if status = 'sucesso' then
      begin
         Result := True;
         Exit;
      end;

      erro := obj.AsObject.S['status'];
      Log('Tratar retorno post ('+S+'): ' + erro);
      Result := False;
   except
      on e:Exception do
      begin
         Log('Erro ao tratar retorno post ('+S+'): ' + e.message);
         Result := False;
      end;

   end;
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
   S, postString, cliente: string;
   api: TApi;
   obj, obj2, obj3: ISuperObject;
   i: Integer;
begin
   Result := False;


      try
         postString := 'CONTROLE=010889';
         postString := postString + '&FUNCAO=BuscaCliente';
         postString := postString + '&COD_EMPRESA=' + codigoEmpresa;

         S := Post(URL_API, postString, '');
         if not TratarRetornoPost(S) then
            Exit;

         obj := SO(S);

         cliente := obj.AsObject.S['cliente'];

         obj2 := SO(cliente);

         for i := 0 to obj2.AsArray.Length - 1 do
         begin
            obj3 := SO(obj2.AsArray.S[i]);
            CNPJemp := obj3.AsObject.S['cnpj'];
            codigoAmbiente := obj3.AsObject.I['ambiente'];
            if obj3.AsObject.S['razao'] = '' then
            begin
               ShowMessage('Razão Social não encontrada. Não é possível continuar');
               Exit;
            end;
            LbEmp.Caption := obj3.AsObject.S['razao'];
         end;
         if codigoAmbiente = 2 then
            ambiente := 'homologacao'
         else
            ambiente := 'producao';

         LbHomologacao.Visible := codigoAmbiente = 2;

         Result := True;


      except
         on E: Exception do
         begin
            Log('Erro ao buscar dados da empresa. Nâo é possível continuar');
            ShowMessage('Erro ao buscar dados da empresa. Nâo é possível continuar');
            Exit;
         end;
      end;

end;

function TFmPrincipal.BuscarNotas: ISuperObject;
var
   obj, obj2, objXML: ISuperObject;
   S, arquivos: String;
begin
   TrocaIcone(1);
   try
      LbStatus.Caption := 'Procurando notas para assinar...';
      LbStatus.Refresh;

      S := PostListarArquivos;

      if not TratarRetornoPost(S) then
         Exit;

      obj := SO(S);

      arquivos := obj.AsObject.S['arquivos'];

      obj2 := SO(arquivos);

      if obj2.AsArray.Length > 0 then
      begin
         Log(IntToStr(obj2.AsArray.Length) + ' nota(s) encontrada(s)');
         LbStatus.Caption := IntToStr(obj2.AsArray.Length) + ' nota(s) encontrada(s)';
         LbStatus.Refresh;
      end
      else
      begin
         LbStatus.Caption := 'Nenhuma nota encontrada. Última busca: ' +
                FormatDateTime('dd/mm/yyyy hh:mm:ss', Now);
         LbStatus.Refresh;
         TrocaIcone(4);
      end;
   finally
      Result := obj2;
   end;
end;

function TFmPrincipal.Post(url, postString, postFiles: string): string;
var
   api: TApi;
begin
   api := TApi.Create('AFFINCONF');
   try
      try
         api.post(url, postString, postFiles);
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
         S := Post('VerificaVersao.php', postString, '');
         S := Trim(S);
         S := StringReplace(S, 'null', '""', [rfReplaceAll]);
         if Copy(S, 1, 4) = 'Erro' then
         begin
            Log('Erro ao verificar atualizações: ' + S);
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
            Log('erro: ' + E.message);
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

