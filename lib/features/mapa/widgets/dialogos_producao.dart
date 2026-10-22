import 'package:flutter/material.dart';

import '../../../core/utils/coordenadas_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../producao/domain/models/producao_registro.dart';
import 'dados_oceanicos_ponto.dart';
import 'dialogo_info_mapa.dart';

/// Um agrupamento de registros de produção próximos entre si (~100m),
/// somados por espécie — usado pela camada de calor de produção no mapa.
///
/// Guarda também os [registros] individuais do grupo: o total por espécie é
/// só um resumo no topo do diálogo, mas cada captura tem sua própria
/// coordenada exata (podem estar a até ~100m umas das outras dentro do
/// mesmo grupo) e precisa ser consultável isoladamente.
class ClusterProducao {
  final double lat;
  final double lon;
  double totalKg;
  final Map<String, double> porEspecie;
  final List<ProducaoRegistro> registros;

  ClusterProducao({
    required this.lat,
    required this.lon,
    required this.totalKg,
    required this.porEspecie,
    required this.registros,
  });
}

/// Detalhe de uma captura: espécie, coordenada exata, data, classificação e
/// peso.
void mostrarDetalheRegistroProducao(
    BuildContext context, ProducaoRegistro registro) {
  final l10n = AppLocalizations.of(context);
  mostrarDialogoInfoMapa(
    context,
    icone: Icons.set_meal,
    titulo: registro.especie,
    conteudo: [
      Text(
        formatarCoordenadasDMSCompacta(registro.latitude!, registro.longitude!),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      const Divider(height: 20),
      LinhaInfoPonto(
        icon: Icons.event_outlined,
        label: l10n.mapaLabelData,
        valor: formatarDataHoraPonto(registro.dataHora),
      ),
      if (registro.classificacao != null &&
          registro.quantidadeUnidades != null) ...[
        const SizedBox(height: 8),
        LinhaInfoPonto(
          icon: Icons.straighten_outlined,
          label: l10n.mapaLabelClassificacaoCurto,
          valor:
              '${registro.classificacao!.label} kg · ${registro.quantidadeUnidades} un.',
        ),
      ],
      const SizedBox(height: 8),
      LinhaInfoPonto(
        icon: Icons.scale_outlined,
        label: l10n.mapaLabelPeso,
        valor: '${registro.quantidadeKg.toStringAsFixed(1)} kg',
      ),
    ],
  );
}

/// Resumo de um grupo de capturas: total por espécie e a lista das capturas
/// individuais (tocar numa abre o detalhe dela).
void mostrarDetalheGrupoProducao(BuildContext context, ClusterProducao cluster) {
  // Um grupo com uma única captura não precisa de tela intermediária —
  // vai direto pro detalhe (espécie + coordenada exata daquela captura).
  if (cluster.registros.length == 1) {
    mostrarDetalheRegistroProducao(context, cluster.registros.first);
    return;
  }

  final l10n = AppLocalizations.of(context);
  final especies = cluster.porEspecie.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final registrosOrdenados = cluster.registros.toList()
    ..sort((a, b) => b.dataHora.compareTo(a.dataHora));

  mostrarDialogoInfoMapa(
    context,
    icone: Icons.local_fire_department,
    titulo: l10n.mapaProducaoTotal(cluster.totalKg.toStringAsFixed(1)),
    conteudo: [
      Text(
        formatarCoordenadasDMSCompacta(cluster.lat, cluster.lon),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      const Divider(height: 20),
      ...especies.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key),
              Text('${e.value.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      const Divider(height: 20),
      Text(
        l10n.mapaProducaoCapturasIndividuais,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      ...registrosOrdenados.map(
        (registro) => InkWell(
          onTap: () {
            Navigator.pop(context);
            mostrarDetalheRegistroProducao(context, registro);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.set_meal, size: 18, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(registro.especie),
                      Text(
                        formatarCoordenadasDMSCompacta(
                          registro.latitude!,
                          registro.longitude!,
                        ),
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text('${registro.quantidadeKg.toStringAsFixed(1)} kg'),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
