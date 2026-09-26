import '../domain/models/leitura_termoclina.dart';
import '../domain/models/perfil_temperatura_ponto.dart';
import 'fonte_termoclina.dart';

/// **MOCK totalmente sintético** — nem a SST vem de uma API aqui (ver
/// [FonteTermoclinaEstimada] pra SST real, que é a fonte padrão hoje).
/// Usado em testes e como referência de formato. Gera um perfil vertical
/// de temperatura plausível (águas tropicais, mistura superficial + queda
/// acentuada entre ~30–50m, típica de termoclina sazonal) com uma
/// variação pequena e determinística a partir da coordenada — mesmo ponto
/// sempre devolve o mesmo resultado, mas pontos diferentes não ficam
/// todos idênticos.
///
/// `fonte: 'mock'` em toda leitura devolvida — a UI (`TermoclinaScreen`)
/// usa isso (via `LeituraTermoclina.perfilEstimado`) pra deixar claro ao
/// usuário que o perfil/profundidade ainda são estimados.
class FonteTermoclinaMock implements FonteTermoclina {
  @override
  Future<LeituraTermoclina> buscar({
    required double latitude,
    required double longitude,
    DateTime? data,
  }) async {
    // Simula a latência de uma chamada de rede de verdade — a tela já
    // precisa lidar com loading mesmo hoje, sem API real.
    await Future.delayed(const Duration(milliseconds: 600));

    // Semente determinística a partir da coordenada — mesmo ponto, mesmo
    // resultado; pontos diferentes variam um pouco a SST/profundidade,
    // só pra não parecer um valor fixo hardcoded.
    final semente = (latitude * 1000 + longitude * 1000).abs();
    final variacaoSst = (semente % 10) / 10 * 1.2 - 0.6; // ±0.6 °C
    final variacaoProfundidade = (semente % 17).toInt() - 8; // ±8 m

    final sstBase = 28.6 + variacaoSst;
    final perfil = <PerfilTemperaturaPonto>[
      PerfilTemperaturaPonto(profundidadeM: 0, temperaturaC: sstBase),
      PerfilTemperaturaPonto(profundidadeM: 10, temperaturaC: sstBase - 0.2),
      PerfilTemperaturaPonto(profundidadeM: 20, temperaturaC: sstBase - 0.5),
      PerfilTemperaturaPonto(profundidadeM: 30, temperaturaC: sstBase - 1.1),
      PerfilTemperaturaPonto(profundidadeM: 40, temperaturaC: sstBase - 2.5),
      PerfilTemperaturaPonto(profundidadeM: 50, temperaturaC: sstBase - 3.8),
      PerfilTemperaturaPonto(profundidadeM: 60, temperaturaC: sstBase - 4.3),
    ];

    final profundidadeTermoclina =
        (48 + variacaoProfundidade).clamp(25, 65).toDouble();
    final confianca = (0.82 - (variacaoProfundidade.abs() / 100))
        .clamp(0.5, 0.95);

    return LeituraTermoclina(
      latitude: latitude,
      longitude: longitude,
      instante: data ?? DateTime.now(),
      sst: double.parse(sstBase.toStringAsFixed(1)),
      profundidadeTermoclina: profundidadeTermoclina,
      confianca: double.parse(confianca.toStringAsFixed(2)),
      perfil: perfil,
      fonte: 'mock',
    );
  }
}
