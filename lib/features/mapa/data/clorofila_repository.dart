import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/models/leitura_clorofila.dart';

/// Única classe que conhece a URL/parâmetros do NOAA CoastWatch ERDDAP pra
/// clorofila-a — API pública, sem autenticação, não passa pelo backend
/// Blue Ocean (mesmo padrão de [WaveForecastRepository] pra Open-Meteo).
///
/// Decisão de 2026-09: o pedido original era usar o Copernicus Marine
/// Toolbox, mas ele não tem uma API REST simples de "lat/lon → valor" —
/// o acesso oficial exige credencial (usuário/senha, não uma "chave") e um
/// processo de subset de NetCDF bem mais pesado, adequado a rodar num
/// backend dedicado, não a uma consulta pontual simples. O ERDDAP do NOAA
/// CoastWatch expõe o mesmo tipo de dado (cor do oceano/clorofila-a) como
/// uma API REST pública de verdade — confirmado com curl real, inclusive
/// no ponto de teste combinado (-2.10600, -38.89306), ver histórico.
class ClorofilaRepository {
  static const _baseUrl =
      'https://coastwatch.noaa.gov/erddap/griddap/noaacwNPPN20S3ASCIDINEOF2kmDaily.csv';

  /// Busca a clorofila-a mais recente disponível num ponto específico —
  /// usa `(last)` no eixo de tempo em vez de uma data fixa, porque o
  /// produto tem alguns dias de atraso em relação a "hoje" (a satélite
  /// observa, mas o processamento/composição diária leva um tempo) — pedir
  /// uma data futura demais faz o ERDDAP devolver 404 ("Start is greater
  /// than the axis maximum"), confirmado durante o desenvolvimento.
  Future<LeituraClorofilaPonto> buscarPonto({
    required double latitude,
    required double longitude,
  }) async {
    // Uri.replace(query:) recodificaria os %5B/%5D já prontos (virariam
    // %255B) — monta a URL crua e usa Uri.parse direto nela, mesma string
    // testada com curl real durante o desenvolvimento.
    final uri = Uri.parse(
      '$_baseUrl?chlor_a%5B(last)%5D%5B(0.0):1:(0.0)%5D'
      '%5B($latitude):1:($latitude)%5D%5B($longitude):1:($longitude)%5D',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar clorofila-a: ${response.statusCode}');
    }
    return parseRespostaCsv(response.body);
  }

  /// Parsing separado do fetch só pra dar pra testar sem rede — resposta
  /// CSV do ERDDAP: linha 0 = nomes das colunas, linha 1 = unidades, linha
  /// 2 = dado. Colunas: time, altitude, latitude, longitude, chlor_a.
  static LeituraClorofilaPonto parseRespostaCsv(String corpo) {
    final linhas = const LineSplitter().convert(corpo);
    if (linhas.length < 3) {
      throw FormatException('Resposta inesperada do ERDDAP (clorofila): $corpo');
    }
    final campos = linhas[2].split(',');
    if (campos.length < 5) {
      throw FormatException('Linha de dado incompleta do ERDDAP: ${linhas[2]}');
    }

    final valorBruto = campos[4].trim();
    // "NaN" é o próprio ERDDAP dizendo "sem dado válido pra esse pixel" —
    // nunca convertido pra 0 nem qualquer outro número (ver doc do campo
    // em LeituraClorofilaPonto).
    final valor =
        valorBruto.toUpperCase() == 'NAN' ? null : double.tryParse(valorBruto);

    return LeituraClorofilaPonto(
      latitude: double.parse(campos[2]),
      longitude: double.parse(campos[3]),
      valorMgM3: valor,
      data: DateTime.parse(campos[0]),
    );
  }
}
