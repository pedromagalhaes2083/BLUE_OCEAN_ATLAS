import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/planos/grupo_permissao.dart';
import 'package:atlas/core/planos/matriz_entitlements.dart';
import 'package:atlas/core/planos/plano_atlas.dart';
import 'package:atlas/core/planos/recurso_atlas.dart';

void main() {
  group('matrizEntitlements', () {
    // Estado atual (2026-09-25): tudo liberado pra todos os planos (ver
    // comentário em matriz_entitlements.dart) — a definição fina de quem
    // libera o quê ainda não foi fechada (ver
    // docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md §3). Este teste é a
    // "fonte da verdade executável": quando a matriz for apertada de
    // verdade, os `expect` abaixo devem virar a tabela real do plano
    // comercial (transcrita do documento, não do código) — se alguém
    // mudar a matriz sem atualizar este teste, ele quebra.
    for (final plano in PlanoAtlas.values) {
      test('$plano libera todos os grupos amplos hoje', () {
        expect(matrizGrupos[plano], equals(GrupoPermissao.values.toSet()));
      });

      test('$plano libera todos os recursos específicos hoje', () {
        expect(matrizRecursos[plano], equals(RecursoAtlas.values.toSet()));
      });
    }

    test('todo RecursoAtlas aponta pra um GrupoPermissao válido', () {
      for (final recurso in RecursoAtlas.values) {
        expect(GrupoPermissao.values, contains(recurso.grupo));
      }
    });

    test('planoMinimoPara acha o plano mais barato que libera um recurso',
        () {
      // Hoje todos liberam tudo — o mais barato é sempre Start.
      for (final recurso in RecursoAtlas.values) {
        expect(planoMinimoPara(recurso), PlanoAtlas.start);
      }
    });
  });
}
