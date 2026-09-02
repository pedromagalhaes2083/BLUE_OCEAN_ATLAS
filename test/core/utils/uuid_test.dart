import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/uuid.dart';

void main() {
  group('gerarUuidV4', () {
    final formato = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

    test('tem o formato de UUID v4 (versão e variante corretas)', () {
      for (var i = 0; i < 20; i++) {
        expect(formato.hasMatch(gerarUuidV4()), isTrue);
      }
    });

    test('não repete entre chamadas', () {
      final gerados = List.generate(50, (_) => gerarUuidV4()).toSet();
      expect(gerados.length, 50);
    });
  });
}
