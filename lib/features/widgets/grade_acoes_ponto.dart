import 'package:flutter/material.dart';

/// Grade de 2 colunas com ações que abrem outra tela pra uma coordenada
/// (Solicitar Carta, Consultar aqui, Termoclina, Inteligência...) — usada
/// tanto no detalhe de um ponto marcado (`MeusPontosScreen`) quanto no
/// card de uma recomendação (`RecomendacaoCard`), pra as duas lerem como
/// painel de ações rápidas em vez de uma pilha de botões de largura total
/// empilhados um por linha.
class GradeAcoesPonto extends StatelessWidget {
  final List<AcaoPonto> acoes;
  const GradeAcoesPonto({super.key, required this.acoes});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const espacamento = 10.0;
        final largura = (constraints.maxWidth - espacamento) / 2;
        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: [
            for (final acao in acoes) SizedBox(width: largura, child: acao),
          ],
        );
      },
    );
  }
}

class AcaoPonto extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Cor do ícone/texto — só pra ações destrutivas (ex: "Remover", em
  /// vermelho). Sem informar, usa a cor primária do tema, igual a
  /// qualquer outra ação da grade.
  final Color? cor;

  const AcaoPonto({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final corEfetiva = cor ?? colorScheme.primary;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: corEfetiva, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
