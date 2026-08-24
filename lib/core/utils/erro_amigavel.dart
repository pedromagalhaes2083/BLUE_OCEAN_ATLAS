import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Pública (não `_`) pra telas que já guardam só a mensagem formatada
/// poderem comparar e trocar o ícone (wifi_off em vez de erro genérico)
/// sem precisar guardar um bool extra de estado.
const mensagemSemConexao =
    'Sem conexão com a internet. Verifique sua rede e tente novamente.';

/// Se [erro] é uma falha de conectividade (sem rede, DNS não resolveu,
/// timeout) — nesses casos, a mensagem crua da exceção (ex:
/// "SocketException: Failed host lookup...") não ajuda o usuário; um aviso
/// de "sem conexão" é mais claro e é o mesmo em qualquer tela.
/// [ApiService]/os repositórios de metereologia não interceptam essas
/// exceções — elas chegam cruas no `catch` de quem chamou, daí a checagem
/// aqui em vez de depender de um tipo de exceção customizado.
bool ehErroDeConexao(Object erro) {
  if (erro is SocketException ||
      erro is TimeoutException ||
      erro is http.ClientException) {
    return true;
  }
  final texto = erro.toString().toLowerCase();
  return texto.contains('socketexception') ||
      texto.contains('timeoutexception') ||
      texto.contains('failed host lookup') ||
      texto.contains('connection refused') ||
      texto.contains('connection reset') ||
      texto.contains('network is unreachable') ||
      texto.contains('clientexception');
}

/// Mensagem pronta pra exibir ao usuário quando uma busca numa API falha —
/// "Sem conexão..." se for problema de rede, senão [prefixo] + o erro
/// original (mesmo formato que as telas já usavam antes).
String mensagemErroAmigavel(Object erro, {String? prefixo}) {
  if (ehErroDeConexao(erro)) return mensagemSemConexao;
  return prefixo != null ? '$prefixo: $erro' : '$erro';
}
