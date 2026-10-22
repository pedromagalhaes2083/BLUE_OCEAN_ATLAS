import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/coordenadas_format.dart';

/// Seletor de posição pelo centro do mapa — retículo fixo no meio da tela e
/// cartão embaixo com a instrução, a coordenada mirada, [campos] opcionais e
/// os botões [acaoSecundaria]/[acaoPrincipal] lado a lado. É o mesmo painel
/// de "Marcar um ponto", das consultas por ponto e de "Planejar rota": a
/// posição usada é sempre a apontada pelo retículo, nunca onde o dedo tocou.
///
/// Vai direto no `Stack` do mapa; só o retículo e o cartão recebem toque —
/// o resto da tela continua arrastando o mapa.
class PainelReticulo extends StatelessWidget {
  /// Centro do mapa; só o texto da coordenada escuta — o painel não
  /// reconstrói inteiro durante o arrasto.
  final ValueListenable<LatLng> centro;
  final String instrucao;
  final Color corReticulo;
  final List<Widget> campos;
  final Widget acaoSecundaria;
  final Widget acaoPrincipal;
  final CrossAxisAlignment alinhamento;

  const PainelReticulo({
    super.key,
    required this.centro,
    required this.instrucao,
    required this.acaoSecundaria,
    required this.acaoPrincipal,
    this.corReticulo = Colors.red,
    this.campos = const [],
    this.alinhamento = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          IgnorePointer(
            child: Center(
              child: Icon(
                Icons.add,
                size: 44,
                color: corReticulo,
                shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: alinhamento,
                  children: [
                    Text(
                      instrucao,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<LatLng>(
                      valueListenable: centro,
                      builder: (context, c, _) => Text(
                        formatarCoordenadasDMSCompacta(c.latitude, c.longitude),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    for (final campo in campos) ...[
                      const SizedBox(height: 12),
                      campo,
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: acaoSecundaria),
                        const SizedBox(width: 12),
                        Expanded(child: acaoPrincipal),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de confirmação do painel — mostra um spinner no lugar do ícone e
/// fica desabilitado enquanto [ocupado].
Widget botaoConfirmarReticulo({
  required String rotulo,
  required VoidCallback? onPressed,
  bool ocupado = false,
}) {
  return ElevatedButton.icon(
    onPressed: ocupado ? null : onPressed,
    icon: ocupado
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.check),
    label: Text(rotulo),
  );
}
