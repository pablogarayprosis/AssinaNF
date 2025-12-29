unit uTipos;

interface

type
   TToken = record
      token: string;
      dtCriado: TDateTime;
   end;

type
   TUsuario = record
      usuario: string;
      senha: string;
      token: string;
      id: Integer;
      categoriaId: Integer;
      clienteId: Integer;
      json: WideString;
   end;

type
   TCliente = record
      id: Integer;
   end;

type
   TRep = record
      id: Integer;
      marca: Integer;
      nome: string;
      descricao: string;
      ip: string;
      porta: Integer;
      nsr: Integer;
      usuario: string;
      senha: string;
      nomeEmpresa: string;
      idEmpresa: Integer;
      portaria671: string;
      dataInicial: string;
      nfr: string;
      ipNoArquivoLeitura: string;
      identificacaoFuncionario: string;
      diretorioRegistros: String;
      diretorioArquivosImportados: String;
   end;

type
   TVtReps = array of TRep;

type
   TEmpresa = record
      id: Integer;
      nome: string;
      codigo: Integer;
      razaoSocial: string;
      nomeFantasia: string;
      cnpj: string;
      bloqueioPontoHorario: string;
      bloqueioPontoTolerancia: string;
   end;

type TvtEmpresas = array of TEmpresa;

type
   TAjuste = record
      id: Integer;
      codigo: Integer;
      matricula: Integer;
      data: TDate;
      dataFim: TDate;
      hora: String;
      situacao: String;
      justificativa: String;
      origem: String;
      justificativaRejeicao: String;
      tipo: String;
      idRep: Integer;
      ocorrencia: Integer;
      criadoEm: TDateTime;
      alteradoEm: TDateTime;
      importadoEm: TDateTime;
      excluidoEm: TDateTime;
      toString: String;
   end;

type TvtAjustes = array of TAjuste;

type
   TRegistro = record
      matriculaFuncionario: Integer;
      nomeFuncionario: string;
      pisFuncionario: string;
      cpfFuncionario: string;
      nsr: integer;
      tipo: string;
      data: TDate;
      dataws: string;
      hora: string;
      pis: string;
      retorno: string;
      id: integer;
      idRep: integer;
      origem: string;
      justificativa: string;
      aprovado: string;
      justificativaRejeicao: String;
      latitude: string;
      longitude: string;
      distancia: string;
      device: string;
      excluido: Boolean;
      excluidoEm: TDateTime;
      importado: Boolean;
      importadoEm: TDateTime;
      criadoEm: TDateTime;
      jaExiste: Boolean;
      matricula: integer;
      idFilial: integer;
      controle: string; //somente para rwtech 1510 DuoCard Bio :(
      linhaAfd: string;
      erro: string;
      toString: String;
   end;

type
   TVtRegistros = array of TRegistro;

type
   TAfastamento = record
      matricula: Integer;
      matriculaFuncionario: Integer;
      nomeFuncionario: string;
      pisFuncionario: string;
      cpfFuncionario: string;
      tipo: string;
      ocorrencia: Integer;
      dataInicio: TDate;
      dataFim: TDate;
      id: Integer;
      justificativa: string;
      justificativaRejeicao: String;
      excluidoEm: TDateTime;
      excluido: Boolean;
      origem: string;
      origemExclusao: string;
      device: string;
      deletedAt: string;
      idRep: Integer;
      idEmpresa: Integer;
      idFilial: Integer;
      importado: Boolean;
      criadoEm: TDateTime;
      aprovado: String;
      toString: String;
   end;

type
   TvtAfastamentos = array of TAfastamento;

type
   TAbono = record
      matriculaFuncionario: Integer;
      nomeFuncionario: string;
      pisFuncionario: string;
      cpfFuncionario: string;
      idRep: Integer;
      id: Integer;
      matricula: Integer;
      data: TDate;
      horas: TTime;
      justificativa: string;
      justificativaRejeicao: String;
      excluidoEm: TDateTime;
      excluido: Boolean;
      origem: string;
      origemExclusao: string;
      device: string;
      importado: Boolean;
      tipoAbono: Integer;
      idFilial: Integer;
      aprovado: String;
      criadoEm: TDateTime;
      toString: String;
   end;

type
   TvtAbonos = array of TAbono;

type
   TStatusDia = record
      id: integer;
      idRep: integer;
      idFilial: integer;
      idEmp: integer;
      dia: TDate;
      afastadoTurno1: string;
      afastadoTurno2: string;
      afastadoTurno3: string;
      abonoFerias: string;
      naoComputaHorasExtras: string;
      horasSobreaviso: TTIme;
      matricula: Integer;
      nomeFuncionario: string;
      deletedAt: TDateTime;
      importado: Boolean;
      toString: String;
   end;

type
   TvtStatusDia = array of TStatusDia;

type
   TCompensacaoFeriado = record
      id: Integer;
      idRep: Integer;
      idEmpresa: Integer;
      dataFeriado: TDate;
      dataCompensacao: TDate;
      matricula: integer;
      idUsuario: Integer;
      justificativa: string;
      origemExclusao: string;
      excluidoEm: TDateTime;
      importadoEm: TDateTime;
      toString: String;
   end;

type
   TLocal = record
      id, marca, filial, tipoConexao, porta, idEmpresa: Integer;
      ip, usuario, senha, nfr, descricao, situacao, usaCriptografia,
      nomeFantasia, razaoSocial, nomeLocal, cnpj: string;
      dataCadastro, dataAlteracao, dataInativacao: TDateTime;
   end;

type
   TvtLocais = array of TLocal;

type
   TFuncionario = record
      nome: string;
      nomeExibicao: string;
      pis: string;
      cpf: string;
      matricula: integer;
      teclado: string; //KBD
      id: integer;
      turno: string;
      tabelaHorario: integer;
      filial: integer;
      idEmpresa: integer;
      idLocal: integer;
      CNTLS: string;
      KBD: string;
      biometria: string;
      senha: string;
      supervisor: string;
      horarioSemanal: string;
      idUsuario: integer;
      permiteTeclado: String;
      idBiometria: Integer;
      bloqueioRegistro: String;
      dtRescisao: TDate;
      excluidoEm: TDateTime;
      toString: String;
   end;

type
   TvtFuncionarios = array of TFuncionario;

type
   TNovoFuncionario = record
      nome: string;
      pis: string;
      cpf: string;
      matricula: integer;
      cartao: string;
      id: integer;
      idRep: Integer;
   end;

type
   TVtNovoFuncionario = array of TNovoFuncionario;

type
  TTabelaHorarios = record
    id: Integer;
    entradaAnterior: string[5];
    saidaAnterior: string[5];
    entradaDepois: string[5];
    saidaDepois: string[5];
    domingoEnt1: string[5];
    domingoSai1: string[5];
    domingoEnt2: string[5];
    domingoSai2: string[5];
    domingoEnt3: string[5];
    domingoSai3: string[5];
    segundaEnt1: string[5];
    segundaSai1: string[5];
    segundaEnt2: string[5];
    segundaSai2: string[5];
    segundaEnt3: string[5];
    segundaSai3: string[5];
    tercaEnt1: string[5];
    tercaSai1: string[5];
    tercaEnt2: string[5];
    tercaSai2: string[5];
    tercaEnt3: string[5];
    tercaSai3: string[5];
    quartaEnt1: string[5];
    quartaSai1: string[5];
    quartaEnt2: string[5];
    quartaSai2: string[5];
    quartaEnt3: string[5];
    quartaSai3: string[5];
    quintaEnt1: string[5];
    quintaSai1: string[5];
    quintaEnt2: string[5];
    quintaSai2: string[5];
    quintaEnt3: string[5];
    quintaSai3: string[5];
    sextaEnt1: string[5];
    sextaSai1: string[5];
    sextaEnt2: string[5];
    sextaSai2: string[5];
    sextaEnt3: string[5];
    sextaSai3: string[5];
    sabadoEnt1: string[5];
    sabadoSai1: string[5];
    sabadoEnt2: string[5];
    sabadoSai2: string[5];
    sabadoEnt3: string[5];
    sabadoSai3: string[5];
    tolDia: string[5];
    descricao: string[40];
    domingoTra: string[5];
    domingoTot: string[5];
    segundaTot: string[5];
    tercaTot: string[5];
    quartaTot: string[5];
    quintaTot: string[5];
    sextaTot: string[5];
    sabadoTot: string[5];
    tolTur: string[5];
    dsr: Integer;
    codigoTabela: Integer;
  end;


type
   TvtTabelaHorarios = array of TTabelaHorarios;

type
   TRetornoComandoSQL = record
      status: Integer;
      mensagem: string;
   end;

type
   TFuncionarioEncontrado = record
      matricula: Integer;
      nome: string;
      pis: string;
   end;

type
   TCidade = record
      codigoIbge: integer;
      uf: string;
      nome: string;
   end;

type
   TLogImportacao = record
      id: Integer;
      iniciadoEm: TDateTime;
      finalizadoEm: TDateTime;
   end;

type
   TLogImportacaoRep = record
      idImportacao: Integer;
      idRep: Integer;
      codEmpresaRep: Integer;
      qtdRegistrosLidos: Integer;
      qtdRegistrosImportados: Integer;
      qtdAfastamentosLidos: Integer;
      qtdAfastamentosImportados: Integer;
      qtdAbonosLidos: Integer;
      qtdAbonosImportados: Integer;
      qtdStatusDiaLidos: Integer;
      qtdStatusDiaImportados: Integer;
      qtdCompensacoesFeriadoLidos: Integer;
      qtdCompensacoesFeriadoImportados: Integer;
      criadoEm: TDateTime;
   end;

type
   TBloqueiosHorarios = record
      horario: string;
      toleranciaAntes: string;
      toleranciaDepois: string;
      numeroEntradaSaida: integer;
      entradaSaida: string;
   end;

type
   TParametros = record
      idRep,
      idFilial,
      idEmpresa,
      versao,
      tentativas: Integer;
      ip,
      nsr,
      nomeLocal,
      nomeEmpresa,
      somSucesso,
      somErro,
      permiteRegistrarPorMatricula,
      permiteCadastrarBiometria,
      controlaTolerancia,
      permiteAlterarTolerancia,
      administrativo,
      agendaAtualizacao,
      nfr,
      leitor,
      todosFuncionarios,
      integracaoSenha,
      sincronizacaoHorario,
      bloqueioRegistro,
      horarioBloqueio,
      primeiroAcesso,
      cnpj,
      usuario,
      senha,
      pontoAgil,
      identificacaoFuncionario,
      bloqueioRegistroPelaTabela: string;
      temBloqueioRegistro: string;
      temAtualizacao: Boolean;
   end;

   function BuscarIdEmpresaRep(id: Integer; vtReps: TvtReps): Integer;

implementation

function BuscarIdEmpresaRep(id: Integer; vtReps: TvtReps): Integer;
var
   i: Integer;
begin
   if Length(vtReps) = 1 then
   begin
      Result := vtReps[0].idEmpresa;
      Exit;
   end;

   for i := 0 to Length(vtReps) - 1 do
   begin
      if vtReps[i].id = id then
      begin
         Result := vtReps[i].idEmpresa;
         break;
      end;
   end;
end;

end.

