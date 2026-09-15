import 'package:flutter/material.dart';
import '../../../core/services/pontos_service.dart';
import '../../../l10n/gen/app_localizations.dart';

class MeteorologiaSheet extends StatelessWidget {
  final PontoMapa ponto;
  final ScrollController? scrollController;

  const MeteorologiaSheet({
    super.key,
    required this.ponto,
    this.scrollController,
  });

  static void show(BuildContext context, PontoMapa ponto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (_, ctrl) =>
            MeteorologiaSheet(ponto: ponto, scrollController: ctrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = ponto.meteorologia;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                if (m != null) ...[
                  _MetSection(
                    title: l10n.meteoSheetVentoTitulo,
                    icon: Icons.air,
                    rows: [
                      _MetRow(l10n.meteoSheetVelocidadeRealTws, _kt(m.twsKts)),
                      _MetRow(l10n.meteoSheetDirecaoRealTwd, _deg(m.twdDeg)),
                      _MetRow(l10n.meteoSheetAnguloRealTwa, _deg(m.twaDeg)),
                      _MetRow(l10n.meteoSheetVelocidadeAparenteAws, _kt(m.awsKts)),
                      _MetRow(l10n.meteoSheetAnguloAparenteAwa, _deg(m.awaDeg)),
                      _MetRow(l10n.meteoSheetRajadas, _kt(m.gustsKts)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetSection(
                    title: l10n.meteoSheetMovimentoTitulo,
                    icon: Icons.speed,
                    rows: [
                      _MetRow(l10n.meteoSheetVelocidadeRealSog, _kt(m.sogKts)),
                      _MetRow(l10n.meteoSheetDirecaoRealCog, _deg(m.cogDeg)),
                      _MetRow(l10n.meteoSheetVelocidadeAparenteStw, _kt(m.stwKts)),
                      _MetRow(l10n.meteoSheetAnguloAparenteCtw, _deg(m.ctwDeg)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetSection(
                    title: l10n.meteoSheetAtmosferaTitulo,
                    icon: Icons.thermostat,
                    rows: [
                      _MetRow(l10n.labelTemperatura, _c(m.airtempC)),
                      _MetRow(l10n.labelPressao, _hpa(m.pressureHpa)),
                      _MetRow(l10n.meteoSheetNuvens, _pct(m.cloudsPct)),
                      _MetRow(l10n.meteoSheetChuva, _mmh(m.rainMmH)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetSection(
                    title: l10n.meteoSheetOndasTitulo,
                    icon: Icons.waves,
                    rows: [
                      _MetRow(l10n.meteoSheetAlturaCombinada, _mt(m.combWavesHeightM)),
                      _MetRow(l10n.meteoSheetVentoAltura, _mt(m.windWavesHeightM)),
                      _MetRow(l10n.meteoSheetVentoDirecao, _deg(m.windWavesDirDeg)),
                      _MetRow(l10n.meteoSheetVentoPeriodo, _s(m.windWavesPeriodS)),
                      _MetRow(l10n.meteoSheetSwellAltura, _mt(m.swellHeightM)),
                      _MetRow(l10n.meteoSheetSwellDirecao, _deg(m.swellDirDeg)),
                      _MetRow(l10n.meteoSheetSwellPeriodo, _s(m.swellPeriodS)),
                    ],
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(child: Text(l10n.meteoSheetSemDados)),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_boat,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ponto.embarcacao ?? l10n.meteoSheetPosicaoFallback,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  ponto.label,
                  style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                ),
                if (ponto.instante != null)
                  Text(
                    _formatInstante(ponto.instante!),
                    style: TextStyle(color: onSurfaceVariant, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatInstante(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final mo = dt.month.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$d/$mo/${dt.year}  $h:$mi';
    } catch (_) {
      return iso;
    }
  }

  static String _kt(double? v) =>
      v != null ? '${v.toStringAsFixed(1)} kt' : '—';
  static String _deg(double? v) => v != null ? '${v.toStringAsFixed(0)}°' : '—';
  static String _mt(double? v) => v != null ? '${v.toStringAsFixed(2)} m' : '—';
  static String _c(double? v) => v != null ? '${v.toStringAsFixed(1)} °C' : '—';
  static String _hpa(double? v) =>
      v != null ? '${v.toStringAsFixed(1)} hPa' : '—';
  static String _pct(double? v) => v != null ? '${v.toStringAsFixed(0)}%' : '—';
  static String _mmh(double? v) =>
      v != null ? '${v.toStringAsFixed(1)} mm/h' : '—';
  static String _s(double? v) => v != null ? '${v.toStringAsFixed(1)} s' : '—';
}

class _MetSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_MetRow> rows;

  const _MetSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 14, endIndent: 14),
          ...rows.map((r) => r.build(context)),
        ],
      ),
    );
  }
}

class _MetRow {
  final String label;
  final String value;

  const _MetRow(this.label, this.value);

  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}
