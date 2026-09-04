import 'package:flutter/material.dart';

/// Modais "Entenda a sizígia" / "Entenda a quadratura" — ilustração
/// simples (posições relativas de Sol, Terra e Lua) + o texto explicativo
/// literal do pedido original. Conteúdo educativo fixo, não depende de
/// nenhum dado.
void mostrarExplicacaoSizigia(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => _DialogExplicacao(
      titulo: 'Entenda a sizígia',
      cor: Colors.orange.shade800,
      ilustracao: const _IlustracaoAlinhada(),
      texto: 'Na Lua Nova e na Lua Cheia, as forças gravitacionais do Sol e '
          'da Lua se combinam, aumentando a amplitude das marés.',
    ),
  );
}

void mostrarExplicacaoQuadratura(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => _DialogExplicacao(
      titulo: 'Entenda a quadratura',
      cor: Colors.blueGrey.shade700,
      ilustracao: const _IlustracaoPerpendicular(),
      texto: 'Nos quartos crescente e minguante, Sol e Lua exercem suas '
          'forças gravitacionais em direções aproximadamente perpendiculares, '
          'resultando em menor amplitude das marés.',
    ),
  );
}

class _DialogExplicacao extends StatelessWidget {
  final String titulo;
  final Color cor;
  final Widget ilustracao;
  final String texto;

  const _DialogExplicacao({
    required this.titulo,
    required this.cor,
    required this.ilustracao,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(Icons.info_outline, color: cor, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(titulo, style: TextStyle(color: cor, fontSize: 17))),
      ]),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ilustracao,
            const SizedBox(height: 16),
            Text(texto, style: const TextStyle(fontSize: 13.5, height: 1.5)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendi'),
        ),
      ],
    );
  }
}

/// Sol — Terra — Lua alinhados numa linha reta (sizígia).
class _IlustracaoAlinhada extends StatelessWidget {
  const _IlustracaoAlinhada();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _corpo('Sol', Colors.amber.shade700, 28),
          _linha(),
          _corpo('Terra', Colors.blue.shade700, 22),
          _linha(),
          _corpo('Lua', Colors.grey.shade500, 16),
        ],
      ),
    );
  }
}

/// Sol — Terra numa linha, Lua deslocada 90° (quadratura).
class _IlustracaoPerpendicular extends StatelessWidget {
  const _IlustracaoPerpendicular();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _corpo('Sol', Colors.amber.shade700, 28),
              _linha(),
              _corpo('Terra', Colors.blue.shade700, 22),
            ],
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width * 0.28,
            child: Column(
              children: [
                _corpo('Lua', Colors.grey.shade500, 16),
                Container(width: 1.5, height: 26, color: Colors.grey.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _corpo(String rotulo, Color cor, double tamanho) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(shape: BoxShape.circle, color: cor),
      ),
      const SizedBox(height: 4),
      Text(rotulo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    ],
  );
}

Widget _linha() => Container(width: 28, height: 1.5, color: Colors.grey.withValues(alpha: 0.5));
