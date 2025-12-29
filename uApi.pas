unit uApi;

interface

uses
   Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, AlWinHttpClient, AlWinHttpWrapper, HttpApp,
   ALMultiPartFormDataParser, AlFcnFile, AlFcnMisc, AlFcnMime, ALFcnString, ALStringList, AlHttpCommon, OleCtrls, ComObj, Vcl.ExtCtrls, Vcl.ComCtrls,
   Vcl.StdCtrls, DateUtils, superObject, RestClient, RestUtils, RestJsonUtils, RestException, HttpConnection, uTipos;

const
{$IFDEF DEBUG}
    BASEURL = 'http://localhost/affinconfgithub/';
// BASEURL_AFFINCONF = 'https://farol6592.c33.integrator.host/';
{$ELSE}
  // BASEURL_AFFINCONF = 'http://localhost/affinconfgithub/';
   BASEURL = 'https://farol6592.c33.integrator.host/';
{$ENDIF}



type
   TApi = class
   private
      farquivo, fdiretorioDownload, fStatusStr, fStatusDownload, fResponseBody, fResponseHeader, fStatusCode, fUrl, fUsuario, fSenha, fversao,
         fDiretorioAplicacao: string;
      fToken: TToken;
      fUsarBaseUrl: Boolean;
      fWinHttpClient: TALWinHttpClient;
      fDownloadSpeedStartTime: TDateTime;
      fDownloadSpeedBytesRead: Integer;
      fDownloadSpeedBytesNotRead: Integer;
      fMustInitWinHTTP: Boolean;
      RClient: TRestClient;
      fobjDataLogin: ISuperObject;
      procedure RestConnectionLost(AException: Exception; var ARetryMode: THTTPRetryMode);
      procedure RestError(ARestClient: TRestClient; AResource: restclient.TResource; AMethod: TRequestMethod; AHTTPError: EHTTPError; var ARetryMode:
         THTTPRetryMode);
      function AnsiStrTo8bitUnicodeString(s: AnsiString): string;
      procedure initWinHTTP;
      procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
      function PostFile: string;
      procedure setToken(const Value: TToken);
      procedure CreateWinHttpWrapper;
      procedure OnHttpClientStatusChange(Sender: TObject; InternetStatus: DWORD; StatusInformation: Pointer; StatusInformationLength: DWORD);
      procedure OnHttpDownloadProgress(Sender: TObject; Read: Integer; Total: Integer);
      procedure OnHttpUploadProgress(Sender: TObject; Sent: Integer; Total: Integer);
      function BuscarToken: TToken;
      procedure SalvarToken;

   public
      responseCode: Integer;
      responseError: string;
      localhost: Boolean;
      function Login: Boolean;
      function PostRest(url, json: string): string;
      function PutRest(url, json: string): string;
      function GetRest(url: string): string;
      function Post(url, postString: string; postFiles: string = ''): string;
      function Put(url, postString: string; postFiles: string = ''): string;
      function Get(url: string): string;
      function ValidarRetornoApi(response: String): Boolean;
      function DownloadArquivo(filename: string): string;
      constructor Create(api: string = 'pontoagil');
      destructor Destroy; override;
      property arquivo: string read farquivo write farquivo;
      property diretorioDownload: string read fdiretorioDownload write fdiretorioDownload;
      property diretorioAplicacao: string read fDiretorioAplicacao write fDiretorioAplicacao;
      property token: TToken read fToken write setToken;
      property statusStr: string read fStatusStr write fStatusStr;
      property responseBody: string read fResponseBody write fResponseBody;
      property responseHeader: string read fResponseHeader write fResponseHeader;
      property statusCode: string read fStatusCode write fStatusCode;
      property usarBaseUrl: Boolean read fUsarBaseUrl write fUsarBaseUrl;
      property usuario: string read fUsuario write fUsuario;
      property senha: string read fSenha write fSenha;
      property objDataLogin: ISuperObject read fobjDataLogin write fobjDataLogin;

   end;

implementation

{ TApi }

function TApi.AnsiStrTo8bitUnicodeString(s: AnsiString): string;
var
   i: Integer;
begin
   SetLength(Result, Length(s));
   for i := 1 to Length(s) do
      Result[i] := Char(s[i]);
end;

function TApi.BuscarToken: TToken;
var
   myFile: TextFile;
   i, minutos: Integer;
   text: string;
begin
   Result.token := '';
   try
      if not FileExists(fDiretorioAplicacao + 'tokenpontoagil.txt') then
      begin
         Login;
         if responseCode = 401 then
            Exit
         else
            SalvarToken;
      end;

      AssignFile(myFile, fDiretorioAplicacao + 'tokenpontoagil.txt');
      Reset(myFile);

      i := 0;

      while not Eof(myFile) do
      begin
         Readln(myFile, text);
         case i of
            0:
               fToken.token := text;
            1:
               fToken.dtCriado := StrToDateTimeDef(text, 0);
         end;

         Inc(i);
      end;

      CloseFile(myFile);

      minutos := MinutesBetween(fToken.dtCriado, Now);
      if minutos > 60 then
      begin
         Login;
         if responseCode = 401 then
            Exit
         else
            SalvarToken;
      end;

      Result := fToken;
   except
   end;
end;

constructor TApi.Create(api: string);
begin
   usarBaseUrl := True;
   fversao := api;
   FUrl := BASEURL;

   CreateWinHttpWrapper;
   initWinHTTP;

   RClient := TRestClient.Create(nil);
   RClient.ConnectionType := hctWinHttp;
   RClient.EnabledCompression := True;
   RClient.Tag := 0;
   RClient.VerifyCert := True;
   RClient.OnError := RestError;
   RClient.OnConnectionLost := RestConnectionLost;

   localHost := false;
   if Pos('localhost', BASEURL) > 0 then
      localHost := true;
end;

procedure TApi.CreateWinHttpWrapper;
var
   url, Flags, TargetFrameName, PostData, Headers: OleVariant;
begin
   fMustInitWinHTTP := True;
   fWinHttpClient := TALWinHttpClient.Create;
   with fWinHttpClient do
   begin
      AccessType := wHttpAt_NO_PROXY;
      InternetOptions := [];
      OnStatusChange := OnHttpClientStatusChange;
      OnDownloadProgress := OnHttpDownloadProgress;
      OnUploadProgress := OnHttpUploadProgress;
      ConnectTimeout := 10000;
      ReceiveTimeout := 60000;
      SendTimeout := 60000;
   end;
end;

destructor TApi.Destroy;
begin

   inherited;
end;

function TApi.DownloadArquivo(filename: string): string;
var
   fileDownload: TFileStream;
begin
   try
      fileDownload := TFileStream.Create(fdiretorioDownload + filename, fmCreate);
      /// /idHTTP.Get(BASEURL + 'assinar/' + filename, fileDownload);
      Result := 'ok';
   except
      on e: Exception do
         Result := e.message;
   end;
end;

function TApi.Get(url: string): string;
var
   AHTTPResponseHeader: TALHTTPResponseHeader;
   AHTTPResponseStream: TALStringStream;
begin
   AHTTPResponseHeader := TALHTTPResponseHeader.Create;
   AHTTPResponseStream := TALStringStream.Create('');
   try
      try

         fWinHttpClient.ReceiveTimeout := 600000;

         if fUsarBaseUrl then
            fWinHttpClient.Get(AnsiString(fUrl + url), AHTTPResponseStream, AHTTPResponseHeader)
         else
            fWinHttpClient.Get(AnsiString(url), AHTTPResponseStream, AHTTPResponseHeader);

         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
         fStatusCode := AHTTPResponseHeader.StatusCode;
      except
         on E:Exception do
         begin
            fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
            fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
            fStatusCode := AHTTPResponseHeader.StatusCode;
         end;
      end;
   finally
      AHTTPResponseHeader.Free;
      AHTTPResponseStream.Free;
   end;
end;

function TApi.GetRest(url: string): string;
var
   fimRequisicao: Boolean;
   qtdRequisicoes: Integer;
begin
   fimRequisicao := False;
   qtdRequisicoes := 0;

   while not fimRequisicao do
   begin
      try
         BuscarToken;
         Result := RClient.Resource(BASEURL + url)
            .Header('Authorization', 'Bearer ' + fToken.token)
            .Accept(RestUtils.MediaType_Json)
            .ContentType(RestUtils.MediaType_Json)
            .Get();

         responseCode := RClient.ResponseCode;
         fimRequisicao := True;
      except
         on e: Exception do
         begin
            Result := 'Erro: ' + e.message;
            Inc(qtdRequisicoes);

            if Copy(e.message, 1, 12) = 'Unauthorized' then
               Login
            else if (RClient.ResponseCode = 401) then
               Login;

            if qtdRequisicoes = 3 then
               fimRequisicao := True;
         end;
      end;
   end;
end;

procedure TApi.initWinHTTP;
var
   slHeader: TStrings;
begin
   if not fMustInitWinHTTP then
      Exit;

   fMustInitWinHTTP := False;

   slHeader := TStringList.Create;
   slHeader.Add('Accept: text/html, */*');
   slHeader.Add('User-Agent: Mozilla/3.0 (compatible; TALWinHttpClient)');
  // if fUrl = BASEURL then
   slHeader.Add('ContentType: utf-8,  application/json');

   with fWinHttpClient do
   begin
      UserName := AnsiString('');
      Password := AnsiString('');
      ConnectTimeout := 10000;
      SendTimeout := 0;
      ReceiveTimeout := 0;
      ProtocolVersion := HTTPpv_1_1;
      UploadBufferSize := 32768;
      ProxyParams.ProxyServer := '';
      ProxyParams.ProxyPort := 80;
      ProxyParams.ProxyUserName := '';
      ProxyParams.ProxyPassword := '';
      ProxyParams.ProxyBypass := '';
      AccessType := wHttpAt_NO_PROXY;
      InternetOptions := [];
      RequestHeader.RawHeaderText := AnsiString(slHeader.Text);
   end;

   if fToken.token <> '' then
      fWinHttpClient.RequestHeader.Authorization := 'Bearer ' + fToken.token;

   slHeader.Free;
end;

function TApi.Login: Boolean;
var
   AHTTPResponseHeader: TALHTTPResponseHeader;
   AHTTPResponseStream: TALStringStream;
   ARawPostDatastream: TALStringStream;
   AMultiPartFormDataFile: TALMultiPartFormDataContent;
   AMultiPartFormDataFiles: TALMultiPartFormDataContents;
   aTmpPostDataString: TALStrings;
   i: Integer;
   fs: TFileStream;
   postString: TStrings;
   url, data: string;
   obj: ISuperObject;
begin
   responseCode := 0;
   responseError := '';
   AHTTPResponseHeader := TALHTTPResponseHeader.Create;
   AHTTPResponseStream := TALStringStream.Create('');
   AMultiPartFormDataFiles := TALMultiPartFormDataContents.Create(True);
   aTmpPostDataString := TALStringList.Create;

   postString := TStringList.Create;
   if ((fUsuario <> '') and (fSenha <> '')) then
   begin
      postString.Add('email=' + fUsuario);
      postString.Add('password=' + fSenha);
   end
   else
   begin
      postString.Add('email=administracao@prosisinformatica.com.br');
      postString.Add('password=010889');
   end;

   try
      try

         aTmpPostDataString.Assign(postString);

         url := BASEURL + 'auth/session';

         fWinHttpClient.PostURLEncoded(
            AnsiString(url),
            aTmpPostDataString,
            AHTTPResponseStream,
            AHTTPResponseHeader,
            True
            );

         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);

         obj := SO(responseBody);
         data := obj.AsObject.s['data'];
         fobjDataLogin := SO(data);
         fToken.token := fobjDataLogin.AsObject.s['token'];
         fToken.dtCriado := Now;

         fWinHttpClient.RequestHeader.Authorization := 'Bearer ' + fToken.token;

         Result := True;
      except
         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
         if Pos('401 Unauthorized', fResponseHeader) > 0 then
         begin
            responseCode := 401;
            responseError := 'Autenticação inválida';
         end;
         Result := False;
      end;
   finally
      AHTTPResponseHeader.Free;
      AHTTPResponseStream.Free;
      AMultiPartFormDataFiles.Free;
      aTmpPostDataString.Free;
   end;

end;

procedure TApi.OnHttpClientStatusChange(Sender: TObject; InternetStatus: DWORD; StatusInformation: Pointer; StatusInformationLength: DWORD);
var
   statusStr: AnsiString;
begin
   case InternetStatus of
      WINHTTP_CALLBACK_STATUS_CLOSING_CONNECTION:
         statusStr := 'Closing the connection to the server';
      WINHTTP_CALLBACK_STATUS_CONNECTED_TO_SERVER:
         statusStr := 'Successfully connected to the server';
      WINHTTP_CALLBACK_STATUS_CONNECTING_TO_SERVER:
         statusStr := 'Connecting to the server';
      WINHTTP_CALLBACK_STATUS_CONNECTION_CLOSED:
         statusStr := 'Successfully closed the connection to the server';
      WINHTTP_CALLBACK_STATUS_DATA_AVAILABLE:
         statusStr := 'Data is available to be retrieved with WinHttpReadData';
      WINHTTP_CALLBACK_STATUS_HANDLE_CREATED:
         statusStr := 'An HINTERNET handle has been created';
      WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING:
         statusStr := 'This handle value has been terminated';
      WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE:
         statusStr := 'The response header has been received and is available with WinHttpQueryHeaders';
      WINHTTP_CALLBACK_STATUS_INTERMEDIATE_RESPONSE:
         statusStr := 'Received an intermediate (100 level) status code message from the server';
      WINHTTP_CALLBACK_STATUS_NAME_RESOLVED:
         statusStr := 'Successfully found the IP address of the server';
      WINHTTP_CALLBACK_STATUS_READ_COMPLETE:
         statusStr := 'Data was successfully read from the server';
      WINHTTP_CALLBACK_STATUS_RECEIVING_RESPONSE:
         statusStr := 'Waiting for the server to respond to a request';
      WINHTTP_CALLBACK_STATUS_REDIRECT:
         statusStr := 'An HTTP request is about to automatically redirect the request';
      WINHTTP_CALLBACK_STATUS_REQUEST_ERROR:
         statusStr := 'An error occurred while sending an HTTP request';
      WINHTTP_CALLBACK_STATUS_REQUEST_SENT:
         statusStr := 'Successfully sent the information request to the server';
      WINHTTP_CALLBACK_STATUS_RESOLVING_NAME:
         statusStr := 'Looking up the IP address of a server name';
      WINHTTP_CALLBACK_STATUS_RESPONSE_RECEIVED:
         statusStr := 'Successfully received a response from the server';
      WINHTTP_CALLBACK_STATUS_SECURE_FAILURE:
         statusStr :=
            'One or more errors were encountered while retrieving a Secure Sockets Layer (SSL) certificate from the server';
      WINHTTP_CALLBACK_STATUS_SENDING_REQUEST:
         statusStr := 'Sending the information request to the server';
      WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE:
         statusStr := 'The request completed successfully';
      WINHTTP_CALLBACK_STATUS_WRITE_COMPLETE:
         statusStr := 'Data was successfully written to the server';
   else
      statusStr := 'Unknown status: ' + ALIntToStr(InternetStatus);
   end;

   fStatusStr := statusStr;
end;

procedure TApi.OnHttpDownloadProgress(Sender: TObject; Read, Total: Integer);
var
   In1, In2: Integer;
begin
   if fStatusDownload = '' then
   begin
      fDownloadSpeedStartTime := Now;
      fDownloadSpeedBytesNotRead := Read;
   end;
   fDownloadSpeedBytesRead := Read;

   fStatusDownload := 'Read ' + IntToStr(Read) + ' bytes of ' + IntToStr(Total) + ' bytes';

   In1 := fDownloadSpeedBytesRead - fDownloadSpeedBytesNotRead;
   In2 := MilliSecondsBetween(Now, fDownloadSpeedStartTime);
   if (In1 > 0) and (In2 > 0) then
      fStatusDownload := 'Download speed: ' + IntToStr(Round((In1 / 1000) / (In2 / 1000))) + 'kbps';

   // application.ProcessMessages;
end;

procedure TApi.OnHttpUploadProgress(Sender: TObject; Sent, Total: Integer);
begin
   fStatusStr := 'Send ' + IntToStr(Sent) + ' bytes of ' + IntToStr(Total) + ' bytes';
   // application.ProcessMessages;
end;

function TApi.Post(url, postString, postFiles: string): string;
var
   AHTTPResponseHeader: TALHTTPResponseHeader;
   AHTTPResponseStream: TALStringStream;
   ARawPostDatastream: TALStringStream;
   AMultiPartFormDataFile: TALMultiPartFormDataContent;
   AMultiPartFormDataFiles: TALMultiPartFormDataContents;
   aTmpPostDataString: TALStrings;
   i: Integer;
   fs: TFileStream;
   OutPutList, OutPutFileList: TStringList;
   uri, res: string;
begin
   initWinHTTP;
   AHTTPResponseHeader := TALHTTPResponseHeader.Create;
   AHTTPResponseStream := TALStringStream.Create('');
   AMultiPartFormDataFiles := TALMultiPartFormDataContents.Create(True);
   aTmpPostDataString := TALStringList.Create;

   OutPutList := TStringList.Create;
   OutPutFileList := TStringList.Create;

   Split('&', postString, OutPutList);
   Split('&', postFiles, OutPutFileList);

   for i := 0 to OutPutFileList.Count - 1 do
   begin
      if OutPutFileList.Strings[i] <> '' then
      begin
         AMultiPartFormDataFile := TALMultiPartFormDataContent.Create;
         TMemoryStream(AMultiPartFormDataFile.DataStream).LoadFromFile(OutPutFileList.ValueFromIndex[i]);
         AMultiPartFormDataFile.ContentDisposition := 'form-data; name="' + AnsiString(OutPutFileList.Names
            [i]) + '"; filename="' + AnsiString(OutPutFileList.ValueFromIndex[i]) + '"';
         AMultiPartFormDataFile.ContentType := ALGetDefaultMIMEContentTypeFromExt(ALExtractFileExt(AnsiString
            (OutPutFileList.ValueFromIndex[i])));
         AMultiPartFormDataFiles.Add(AMultiPartFormDataFile);
      end;
   end;

   if fUsarBaseUrl then
      uri := fUrl + url
   else
      uri := url;

   try
      try
         aTmpPostDataString.Assign(OutPutList);

         // envia arquivos
         if AMultiPartFormDataFiles.Count > 0 then
         begin
            fWinHttpClient.PostMultiPartFormData(AnsiString(uri),
               aTmpPostDataString,
               AMultiPartFormDataFiles,
               AHTTPResponseStream,
               AHTTPResponseHeader);
         end
         else
         begin

         // post
            if Copy(postString, 1, 1) = '{' then
            begin
               OutPutList.Text := postString;
               aTmpPostDataString.Assign(OutPutList);

               fWinHttpClient.PostURLEncoded(AnsiString(uri),
                  aTmpPostDataString,
                  AHTTPResponseStream,
                  AHTTPResponseHeader,
                  False)
            end
            else
               fWinHttpClient.PostURLEncoded(AnsiString(uri),
                  aTmpPostDataString,
                  AHTTPResponseStream,
                  AHTTPResponseHeader,
                  False);
         end;

         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
         fStatusCode := AHTTPResponseHeader.StatusCode;
      except
         on e: Exception do
         begin

            fResponseBody := 'Erro: ' + AnsiStrTo8bitUnicodeString(e.message) + '|' +
               AHTTPResponseHeader.date + '|' + AHTTPResponseHeader.Warning + '|' +
               AHTTPResponseHeader.ReasonPhrase;
            fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
            fStatusCode := AHTTPResponseHeader.StatusCode;
         end;
      end;
   finally
      AHTTPResponseHeader.Free;
      AHTTPResponseStream.Free;
      AMultiPartFormDataFiles.Free;
      aTmpPostDataString.Free;
   end;
end;

function TApi.PostFile: string;
var
   AMultiPartFormDataFile: TALMultiPartFormDataContent;
   AMultiPartFormDataFiles: TALMultiPartFormDataContents;
   AHTTPResponseHeader: TALHTTPResponseHeader;
   AHTTPResponseStream: TALStringStream;
   aTmpPostDataString: TALStrings;
   fs: TFileStream;
   code: Integer;
   nomeArquivoAssinado: string;
begin
   try
      AHTTPResponseHeader := TALHTTPResponseHeader.Create;
      AHTTPResponseStream := TALStringStream.Create('');
      AMultiPartFormDataFiles := TALMultiPartFormDataContents.Create(True);
      AMultiPartFormDataFile := TALMultiPartFormDataContent.Create;
      TMemoryStream(AMultiPartFormDataFile.DataStream).LoadFromFile(farquivo);
      AMultiPartFormDataFile.ContentDisposition := 'form-data; name="' + AnsiString('file') +
         '"; filename="' + AnsiString(farquivo) + '"';
      AMultiPartFormDataFile.ContentType := ALGetDefaultMIMEContentTypeFromExt(ALExtractFileExt(AnsiString
         (farquivo)));
      AMultiPartFormDataFiles.Add(AMultiPartFormDataFile);

      aTmpPostDataString := TALStringList.Create;

      //
      if AMultiPartFormDataFiles.Count > 0 then
      begin
         fWinHttpClient.PostMultiPartFormData(AnsiString('https://sistemapontoagil.com.br/assinatura-digital/assinar'),
            aTmpPostDataString,
            AMultiPartFormDataFiles,
            AHTTPResponseStream,
            AHTTPResponseHeader);
      end;

      try
         if AMultiPartFormDataFiles.Count > 0 then
         begin
            nomeArquivoAssinado := FormatDateTime('afd-assinado-ddmmyy-hhmm', Now);
            fs := TFileStream.Create(fdiretorioDownload + nomeArquivoAssinado + '.p7s', fmCreate or
               fmOpenWrite);
            fs.Write(PChar(AHTTPResponseStream.DataString)^, Length(AHTTPResponseStream.DataString));
         end;

         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);

         Result := 'ok';
      except
         on e: Exception do
            Result := e.message;
      end;
   finally
      AHTTPResponseHeader.Free;
      AHTTPResponseStream.Free;
      AMultiPartFormDataFiles.Free;
      AMultiPartFormDataFile.Free;
      aTmpPostDataString.Free;
   end;
end;

function TApi.PostRest(url, json: string): string;
begin
   if fversao = 'DESKTOP' then
   begin
      try
         Result := RClient.Resource(fUrl + url)
            .Accept(RestUtils.MediaType_Json)
            .ContentType(RestUtils.MediaType_Json)
            .Post(json);

         responseCode := RClient.ResponseCode;
      except
         on e: Exception do
            Result := 'Erro: ' + e.message;
      end;
   end
   else
   begin
      try
         BuscarToken;
         if responseCode = 401 then
         begin
            Result := responseError;
            Exit;
         end;

         responseCode := 0;
         responseError := '';

         Result := RClient.Resource(fUrl + url)
            .Header('Authorization', 'Bearer ' + fToken.token)
            .Accept(RestUtils.MediaType_Json)
            .ContentType(RestUtils.MediaType_Json)
            .Post(json);

         responseCode := RClient.ResponseCode;

      except
         on e: Exception do
         begin
            responseCode := 405;
            responseError := e.message;
            Result := 'Erro: ' + e.message;
         end;
      end;
   end;
end;

function TApi.PutRest(url, json: string): string;
begin
   try
      BuscarToken;
      Result := RClient.Resource(BASEURL + url)
         .Header('Authorization', 'Bearer ' + fToken.token)
         .Accept(RestUtils.MediaType_Json)
         .ContentType(RestUtils.MediaType_Json)
         .Put(json);
   except
      on e: Exception do
         Result := e.message;
   end;
end;

function TApi.Put(url, postString, postFiles: string): string;
var
   AHTTPResponseHeader: TALHTTPResponseHeader;
   AHTTPResponseStream: TALStringStream;
   ARawPostDatastream: TALStringStream;
   AMultiPartFormDataFile: TALMultiPartFormDataContent;
   AMultiPartFormDataFiles: TALMultiPartFormDataContents;
   aTmpPostDataString: TALStrings;
   i: Integer;
   fs: TFileStream;
   OutPutList, OutPutFileList: TStringList;
   uri, res: string;
begin
   initWinHTTP;
   AHTTPResponseHeader := TALHTTPResponseHeader.Create;
   AHTTPResponseStream := TALStringStream.Create('');
   AMultiPartFormDataFiles := TALMultiPartFormDataContents.Create(True);
   aTmpPostDataString := TALStringList.Create;

   OutPutList := TStringList.Create;
   OutPutFileList := TStringList.Create;

   Split('&', postString, OutPutList);
   Split('&', postFiles, OutPutFileList);

   for i := 0 to OutPutFileList.Count - 1 do
   begin
      if OutPutFileList.Strings[i] <> '' then
      begin
         AMultiPartFormDataFile := TALMultiPartFormDataContent.Create;
         TMemoryStream(AMultiPartFormDataFile.DataStream).LoadFromFile(OutPutFileList.ValueFromIndex[i]);
         AMultiPartFormDataFile.ContentDisposition := 'form-data; name="' + AnsiString(OutPutFileList.Names
            [i]) + '"; filename="' + AnsiString(OutPutFileList.ValueFromIndex[i]) + '"';
         AMultiPartFormDataFile.ContentType := ALGetDefaultMIMEContentTypeFromExt(ALExtractFileExt(AnsiString
            (OutPutFileList.ValueFromIndex[i])));
         AMultiPartFormDataFiles.Add(AMultiPartFormDataFile);
      end;
   end;

   if fUsarBaseUrl then
      uri := fUrl + url
   else
      uri := url;

   try
      try
         aTmpPostDataString.Assign(OutPutList);

         ARawPostDatastream := TALStringStream.Create(postString);

         // envia arquivos
         if AMultiPartFormDataFiles.Count > 0 then
            fWinHttpClient.PostMultiPartFormData(AnsiString(uri),
               aTmpPostDataString,
               AMultiPartFormDataFiles,
               AHTTPResponseStream,
               AHTTPResponseHeader);

         // post
         if Copy(postString, 1, 1) = '{' then
         begin
            OutPutList.Text := postString;
            aTmpPostDataString.Assign(OutPutList);

            fWinHttpClient.Put(AnsiString(uri),
               ARawPostDatastream,
               AHTTPResponseStream,
               AHTTPResponseHeader)
         end
         else
            fWinHttpClient.Put(AnsiString(uri),
               ARawPostDatastream,
               AHTTPResponseStream,
               AHTTPResponseHeader);

         fResponseBody := AnsiStrTo8bitUnicodeString(AHTTPResponseStream.DataString);
         fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
         fStatusCode := AHTTPResponseHeader.StatusCode;
      except
         on e: Exception do
         begin
            fResponseBody := 'Erro: ' + AnsiStrTo8bitUnicodeString(e.message);
            fResponseHeader := AnsiStrTo8bitUnicodeString(AHTTPResponseHeader.RawHeaderText);
            fStatusCode := AHTTPResponseHeader.StatusCode;
         end;
      end;
   finally
      AHTTPResponseHeader.Free;
      AHTTPResponseStream.Free;
      AMultiPartFormDataFiles.Free;
      aTmpPostDataString.Free;
   end;
end;

procedure TApi.RestConnectionLost(AException: Exception; var ARetryMode: THTTPRetryMode);
begin
   ARetryMode := hrmRetry;
   Sleep(1000);
end;

procedure TApi.RestError(ARestClient: TRestClient; AResource: restclient.TResource; AMethod: TRequestMethod; AHTTPError: EHTTPError; var ARetryMode:
   THTTPRetryMode);
begin
   ARetryMode := hrmIgnore;

   responseError := AHttpError.ErrorMessage;
   if AHTTPError.ErrorCode = 404 then
      ARetryMode := hrmIgnore;

   if AHTTPError.ErrorCode = 401 then
   begin

   end;

end;

procedure TApi.SalvarToken;
var
   myFile: TextFile;
begin
   AssignFile(myFile, 'tokenpontoagil.txt');
   Rewrite(myFile);

   fToken.token := fobjDataLogin.AsObject.S['token'];
   fToken.dtCriado := Now;

   Writeln(myFile, fToken.token);
   Writeln(myFile, DateTimeToStr(Now));

   CloseFile(myFile);
end;

procedure TApi.setToken(const Value: TToken);
begin
   if Value.token <> '' then
   begin
      fToken := Value;
      if fWinHttpClient <> nil then
         fWinHttpClient.RequestHeader.Authorization := 'Bearer ' + Value.token;
   end;
end;

procedure TApi.Split(Delimiter: Char; Str: string; ListOfStrings: TStrings);
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText := Str;
end;

function TApi.ValidarRetornoApi(response: String): Boolean;
begin
   Result := False;

   if Length(Trim(response)) = 0 then
      Exit;

   if Pos('Uma conexão com o servidor não pôde ser estabelecida', response) > 0 then
   begin
      responseError := 'Uma conexão com o servidor não pôde ser estabelecida';
      Exit;
   end;

   if Copy(response, 1, 17) = '||Not Found (404)' then
   begin
      responseError := response;
      Exit;
   end;

   if Copy(response, 1, 41) = '||O tempo limite da operação foi atingido' then
   begin
      responseError := response;
      Exit;
   end;

   Result := True;
end;

end.

