import 'package:flutter/material.dart';

/// Aviso compacto de "dado veio do cache local" — mesmo visual (cor
/// âmbar + ícone de nuvem cortada) do banner já usado em
/// `CartasScreen`/`RecomendacaoRepository` pra recomendações offline,
/// generalizado pra qualquer tela que consuma
/// `WaveForecastRepository`/`PrevisaoTempoRepository`/`ProfundidadeRepository`
/// (que agora caem pro cache local — ver `DadosPontoCacheService` — em vez
/// de falhar de vez quando não há sinal no mar).
class OfflineDadosBanner extends StatelessWidget {
  final DateTime? em;

  const OfflineDadosBanner({super.key, this.em});

  @override
  Widget build(BuildContext context) {
    final horario = em != null
        ? '${em!.day.toString().padLeft(2, '0')}/${em!.month.toString().padLeft(2, '0')} '
            '${em!.hour.toString().padLeft(2, '0')}:${em!.minute.toString().padLeft(2, '0')}'
        : 'data desconhecida';
    return Card(
      color: Colors.amber.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.amber.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sem conexão — mostrando o último dado sincronizado em $horario',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
