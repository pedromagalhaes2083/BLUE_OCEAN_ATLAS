import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../l10n/gen/app_localizations.dart';

/// Uma camada do mapa preenchida por consultas em pontos escolhidos pelo
/// mestre no retículo (temperatura, clorofila, índice de produtividade,
/// Inteligência Oceânica). Todas funcionam igual — ligar/desligar, abrir o
/// retículo, consultar, acumular vários pontos, tocar num ponto pra ver o
/// detalhe ou removê-lo — e só diferem no que buscam e em como desenham.
///
/// Esta classe guarda os pontos e diz *o que* cada camada faz; o
/// `MapaWidget` orquestra *quando* (estado de tela, retículo, setState).
/// Pra mudar uma camada, mexe-se só no arquivo dela (`camada_*.dart`).
abstract class CamadaConsultaPonto<T> {
  /// Pontos já consultados, na ordem em que foram adicionados.
  List<T> pontos = [];

  /// Se a camada está sendo desenhada no mapa (os pontos continuam
  /// guardados quando ela é desligada — religar os mostra de novo).
  bool visivel = false;

  /// Identificador estável (ex.: tag do botão "+").
  String get id;

  String titulo(AppLocalizations l10n);
  String tooltipAdicionar(AppLocalizations l10n);

  /// Prefixo da mensagem de erro quando a consulta falha.
  String prefixoErro(AppLocalizations l10n);

  /// Busca o dado no [ponto] escolhido. Lança quando não deu (o mapa mostra
  /// o erro com [prefixoErro]).
  Future<List<T>> consultar(LatLng ponto, AppLocalizations l10n);

  /// Camadas do flutter_map pros [pontos] atuais. [aoTocar] abre o detalhe.
  List<Widget> camadas(void Function(T item) aoTocar);

  /// Diálogo de detalhe de um ponto; [aoRemover] tira o ponto do mapa.
  void mostrarDetalhe(BuildContext context, T item,
      {required VoidCallback aoRemover});

  /// O que mostrar logo depois de uma consulta bem-sucedida — por padrão,
  /// o detalhe do ponto novo.
  void aposConsultar(
      BuildContext context, List<T> novos, void Function(T item) abrirDetalhe) {
    if (novos.isNotEmpty) abrirDetalhe(novos.first);
  }

  bool get temPontos => pontos.isNotEmpty;

  void adicionar(List<T> novos) {
    pontos = [...pontos, ...novos];
    visivel = true;
  }

  void remover(T item) {
    pontos = pontos.where((p) => p != item).toList();
  }
}

/// Marcador redondo com ícone, padrão das camadas de consulta por ponto
/// (clorofila, índice, Inteligência).
Marker marcadorCircular({
  required LatLng ponto,
  required Color cor,
  required IconData icone,
  required VoidCallback aoTocar,
}) {
  return Marker(
    point: ponto,
    width: 32,
    height: 32,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cor,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icone, color: Colors.white, size: 16),
      ),
    ),
  );
}

/// Bolinha colorida + texto em negrito — o "resumo" no topo do detalhe de
/// um ponto (nível de produtividade, score...).
Widget resumoComCor(Color cor, String texto) {
  return Row(
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(texto,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    ],
  );
}

/// Diálogo de detalhe de um ponto consultado: título, conteúdo e as ações
/// "Remover" (tira o ponto do mapa) e "Fechar", com [acoesExtras] entre as
/// duas.
void mostrarDialogoDetalhePonto(
  BuildContext context, {
  required String titulo,
  required List<Widget> conteudo,
  required VoidCallback aoRemover,
  List<Widget> Function(BuildContext dialogo)? acoesExtras,
}) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: Text(titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: conteudo,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogo);
            aoRemover();
          },
          child: Text(l10n.remover, style: const TextStyle(color: Colors.red)),
        ),
        ...?acoesExtras?.call(dialogo),
        TextButton(
          onPressed: () => Navigator.pop(dialogo),
          child: Text(l10n.fechar),
        ),
      ],
    ),
  );
}
