import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/limiares_alerta.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_hive_test_');
    Hive.init(tempDir.path);
    Config.resetForTesting();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('carregar() sem nada salvo devolve os limiares padrão', () async {
    final limiares = await LimiaresAlerta.carregar();

    expect(limiares.ventoAtivo, LimiaresAlerta.padrao.ventoAtivo);
    expect(limiares.ventoLimiarKmh, LimiaresAlerta.padrao.ventoLimiarKmh);
    expect(limiares.ondaAtivo, LimiaresAlerta.padrao.ondaAtivo);
    expect(limiares.ondaLimiarM, LimiaresAlerta.padrao.ondaLimiarM);
    expect(limiares.correnteAtivo, LimiaresAlerta.padrao.correnteAtivo);
    expect(
        limiares.correnteLimiarNos, LimiaresAlerta.padrao.correnteLimiarNos);
    // Temperatura é o único que começa desligado.
    expect(limiares.temperaturaAtivo, isFalse);
    expect(
        limiares.temperaturaLimiarC, LimiaresAlerta.padrao.temperaturaLimiarC);
  });

  test('salvar() e depois carregar() devolve os mesmos valores', () async {
    final alterado = LimiaresAlerta.padrao.copyWith(
      ventoAtivo: false,
      ventoLimiarKmh: 60,
      ondaLimiarM: 4.5,
      correnteAtivo: false,
      temperaturaAtivo: true,
      temperaturaLimiarC: 18,
    );
    await alterado.salvar();

    final recarregado = await LimiaresAlerta.carregar();

    expect(recarregado.ventoAtivo, isFalse);
    expect(recarregado.ventoLimiarKmh, 60);
    expect(recarregado.ondaLimiarM, 4.5);
    expect(recarregado.correnteAtivo, isFalse);
    expect(recarregado.temperaturaAtivo, isTrue);
    expect(recarregado.temperaturaLimiarC, 18);
    // Campo não alterado continua com o padrão.
    expect(recarregado.correnteLimiarNos, LimiaresAlerta.padrao.correnteLimiarNos);
  });

  test('copyWith não altera os campos que não foram passados', () {
    final original = LimiaresAlerta.padrao;
    final copia = original.copyWith(ventoLimiarKmh: 70);

    expect(copia.ventoLimiarKmh, 70);
    expect(copia.ondaLimiarM, original.ondaLimiarM);
    expect(copia.correnteLimiarNos, original.correnteLimiarNos);
    expect(copia.temperaturaAtivo, original.temperaturaAtivo);
  });
}
