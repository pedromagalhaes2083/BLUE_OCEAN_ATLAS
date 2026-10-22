import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';

/// Moldura comum dos diálogos de informação do mapa (produção, ponto de
/// recomendação): ícone + título, conteúdo rolável e "Fechar" seguido de
/// [acoesExtras]. Mantém o mesmo visual entre eles sem repetir o
/// `AlertDialog` em cada um.
void mostrarDialogoInfoMapa(
  BuildContext context, {
  required IconData icone,
  required String titulo,
  required List<Widget> conteudo,
  List<Widget> Function(BuildContext dialogo)? acoesExtras,
}) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (dialogo) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icone, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: conteudo,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogo),
          child: Text(l10n.fechar),
        ),
        ...?acoesExtras?.call(dialogo),
      ],
    ),
  );
}

/// `dd/MM/aaaa  HH:mm` — formato de data/hora dos detalhes de ponto no mapa.
String formatarDataHoraPonto(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$d/$mo/${dt.year}  $h:$mi';
}
