import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:atlas/core/utils/erro_amigavel.dart';

void main() {
  group('ehErroDeConexao', () {
    test('reconhece SocketException', () {
      expect(ehErroDeConexao(const SocketException('Failed host lookup')),
          isTrue);
    });

    test('reconhece TimeoutException', () {
      expect(ehErroDeConexao(TimeoutException('timeout')), isTrue);
    });

    test('reconhece http.ClientException', () {
      expect(ehErroDeConexao(http.ClientException('falhou')), isTrue);
    });

    test('reconhece pelo texto quando embrulhado em outra exceção', () {
      expect(
        ehErroDeConexao(
            Exception('SocketException: Failed host lookup: api.com')),
        isTrue,
      );
    });

    test('não reconhece erro de validação/negócio comum', () {
      expect(ehErroDeConexao(Exception('Latitude inválida')), isFalse);
      expect(ehErroDeConexao(Exception('A requisição falhou: 500')), isFalse);
    });
  });

  group('mensagemErroAmigavel', () {
    test('erro de conexão vira a mensagem padrão, ignorando o prefixo', () {
      final msg = mensagemErroAmigavel(
        const SocketException('Failed host lookup'),
        prefixo: 'Erro ao buscar previsão',
      );
      expect(msg, mensagemSemConexao);
    });

    test('erro comum usa prefixo + mensagem original', () {
      final msg = mensagemErroAmigavel(
        Exception('formato inválido'),
        prefixo: 'Erro ao buscar previsão',
      );
      expect(msg, 'Erro ao buscar previsão: Exception: formato inválido');
    });

    test('sem prefixo, erro comum aparece cru', () {
      final msg = mensagemErroAmigavel(Exception('formato inválido'));
      expect(msg, 'Exception: formato inválido');
    });
  });
}
