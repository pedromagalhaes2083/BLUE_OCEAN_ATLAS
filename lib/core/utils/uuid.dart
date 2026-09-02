import 'dart:math';

/// Gera um UUID v4 (aleatório) — usado quando o backend espera que o
/// cliente gere o `id` antes de criar um registro (ex: `POST
/// base/operacao/portos`, `POST base/operacao/viagens`), em vez de deixar
/// o servidor gerar. Implementação própria (16 bytes de `Random.secure()`
/// + bits de versão/variante RFC 4122) em vez de puxar o pacote `uuid`
/// só pra isso — é um algoritmo pequeno e bem conhecido.
String gerarUuidV4() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));

  bytes[6] = (bytes[6] & 0x0F) | 0x40; // versão 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variante RFC 4122

  String hex(int inicio, int fim) =>
      bytes.sublist(inicio, fim).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
