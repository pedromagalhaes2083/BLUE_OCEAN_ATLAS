import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/presentation/meus_pontos_screen.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/recurso_protegido.dart';
import '../../widgets/termoclina/grafico_perfil_termico.dart';
import '../data/termoclina_repository.dart';
import '../domain/models/leitura_termoclina.dart';

/// Tela "Termoclina" — profundidade estimada da termoclina na região onde
/// a embarcação está navegando/pescando, com o perfil vertical de
/// temperatura que embasa essa estimativa.
///
/// Mesmo padrão de ponto fixo opcional de [MareEPescaAtumScreen]/
/// [CondicoesPontoScreen]: com [latitude]/[longitude] informados (vindo de
/// um ponto marcado ou de uma recomendação no mapa, ver
/// `MapaWidget._mostrarInfoPontoMarcado`), consulta direto essa
/// coordenada, sem GPS; sem eles (entrada pelo menu), usa a posição atual
/// da embarcação como sempre.
///
/// **SST vem real** hoje (ver `TermoclinaRepository` →
/// `FonteTermoclinaEstimada`, mesma API Open-Meteo Marine já usada em
/// outras telas) — mas o perfil vertical e a profundidade da termoclina
/// em si continuam **estimados**, já que nenhuma fonte com perfil
/// vertical medido (Copernicus Marine ou outra) está conectada ainda. Ver
/// `fonte_termoclina.dart` pra onde plugar isso depois, sem precisar
/// tocar nesta tela.
class TermoclinaScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? nomePonto;

  const TermoclinaScreen({super.key, this.latitude, this.longitude, this.nomePonto});

  bool get _pontoFixo => latitude != null && longitude != null;

  @override
  State<TermoclinaScreen> createState() => _TermoclinaScreenState();
}

class _TermoclinaScreenState extends State<TermoclinaScreen> {
  final _repository = TermoclinaRepository();

  double? _lat;
  double? _lon;

  LeituraTermoclina? _leitura;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    // Ponto fixo (vindo de "Meus Pontos"/mapa) já busca de cara — não
    // espera nenhum GPS, igual `MareEPescaAtumScreen`/`CondicoesPontoScreen`.
    if (widget._pontoFixo) {
      _lat = widget.latitude;
      _lon = widget.longitude;
      _buscarDados();
    }
  }

  Future<void> _buscarDados() async {
    if (_lat == null || _lon == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final leitura = await _repository.buscar(latitude: _lat!, longitude: _lon!);
      if (!mounted) return;
      setState(() => _leitura = leitura);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e,
          prefixo: AppLocalizations.of(context).termoclinaErroMensagem));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDados();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._pontoFixo
            ? (widget.nomePonto?.isNotEmpty == true
                ? widget.nomePonto!
                : l10n.termoclinaTelaTitulo)
            : l10n.termoclinaTelaTitulo),
        actions: [
          if (widget._pontoFixo)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.viagemAtualizarTooltip,
              onPressed: _carregando ? null : _buscarDados,
            )
          else
            IconButton(
              icon: const Icon(Icons.pin_drop),
              tooltip: l10n.mapaMeusPontosTooltip,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeusPontosScreen()),
              ),
            ),
        ],
      ),
      body: !PlanoService.possui(RecursoAtlas.oceanografiaTermoclina)
          ? CardUpgradePlano.telaCheia(context, RecursoAtlas.oceanografiaTermoclina)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget._pontoFixo)
                  _cardPontoFixo(context)
                else
                  PosicaoAtualWidget(
                    onPosicaoObtida: (posicao) =>
                        _atualizarPosicao(posicao.latitude, posicao.longitude),
                  ),
                const SizedBox(height: 16),
                if (_lat == null || _lon == null)
                  _mensagemCentral(l10n.termoclinaAguardandoPosicao)
                else if (_carregando && _leitura == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_erro != null && _leitura == null)
                  _cardErro(context)
                else if (_leitura == null)
                  _mensagemCentral(l10n.termoclinaSemDadosMensagem)
                else ...[
                  if (_erro != null) ...[
                    _cardErro(context),
                    const SizedBox(height: 12),
                  ],
                  _MapaTermoclina(lat: _lat!, lon: _lon!),
                  const SizedBox(height: 16),
                  _CardProfundidadeTermoclina(leitura: _leitura!),
                  const SizedBox(height: 16),
                  _IndicadoresOceanograficos(leitura: _leitura!),
                  const SizedBox(height: 20),
                  _CardPerfilTemperatura(leitura: _leitura!),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _buscarDados,
                      icon: _carregando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(l10n.termoclinaAtualizarBotao),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _cardPontoFixo(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cor = escuro ? Colors.blue.shade200 : Colors.blue.shade900;
    return Card(
      color: escuro ? Colors.blue.withValues(alpha: 0.18) : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: cor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatarCoordenadasDMSCompacta(widget.latitude!, widget.longitude!),
                style: TextStyle(fontWeight: FontWeight.w600, color: cor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensagemCentral(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        ),
      );

  Widget _cardErro(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    _erro == mensagemSemConexao ? Icons.wifi_off_outlined : Icons.error_outline,
                    color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _carregando ? null : _buscarDados,
                child: Text(AppLocalizations.of(context).dashboardTentarNovamente),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapa (o mesmo `flutter_map` já usado no resto do app — nenhuma lib
/// nova) centrado no ponto consultado, com as curvas de profundidade
/// (isóbatas) do OpenSeaMap por cima do mapa de ruas — mesmo WMS de
/// `MapaWidget` — e uma camada circular translúcida representando a área
/// de estimativa da termoclina. Círculo é só visual pra validar a
/// interface (ver doc de `FonteTermoclinaEstimada`); as isóbatas, essas
/// sim, já são dado batimétrico real.
class _MapaTermoclina extends StatelessWidget {
  final double lat;
  final double lon;
  const _MapaTermoclina({required this.lat, required this.lon});

  @override
  Widget build(BuildContext context) {
    final centro = LatLng(lat, lon);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: centro,
            initialZoom: 10,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.atlas',
            ),
            // Curvas de profundidade (isóbatas) do OpenSeaMap — mesmo WMS já
            // usado em `MapaWidget` (projeto de profundidade dedicado do
            // OpenSeaMap, dado batimétrico real). Sempre habilitada aqui
            // (mapa de prévia, sem painel de camadas) — faz sentido numa
            // tela sobre profundidade da termoclina.
            TileLayer(
              wmsOptions: WMSTileLayerOptions(
                baseUrl: 'https://depth.openseamap.org/geoserver/openseamap/wms?',
                layers: const ['openseamap:contour', 'openseamap:contour2'],
                format: 'image/png',
                version: '1.1.0',
              ),
              userAgentPackageName: 'com.example.atlas',
            ),
            CircleLayer(circles: [
              CircleMarker(
                point: centro,
                radius: 60,
                useRadiusInMeter: true,
                color: Colors.deepOrange.withValues(alpha: 0.18),
                borderColor: Colors.deepOrange.withValues(alpha: 0.6),
                borderStrokeWidth: 1.5,
              ),
            ]),
            MarkerLayer(markers: [
              Marker(
                point: centro,
                width: 28,
                height: 28,
                child: const Icon(Icons.location_on, color: Colors.red, size: 28),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CardProfundidadeTermoclina extends StatelessWidget {
  final LeituraTermoclina leitura;
  const _CardProfundidadeTermoclina({required this.leitura});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hora = '${leitura.instante.hour.toString().padLeft(2, '0')}:'
        '${leitura.instante.minute.toString().padLeft(2, '0')}';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.termoclinaProfundidadeLabel.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              '${leitura.profundidadeTermoclina.toStringAsFixed(0)} m',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Text(
                leitura.profundidadeTermoclinaMedida
                    ? l10n.termoclinaProfundidadeMedida
                    : l10n.termoclinaProfundidadeEstimada,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(l10n.termoclinaAtualizadoAs(hora),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (leitura.profundidadeLocalM != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.termoclinaProfundidadeLocal(
                    leitura.profundidadeLocalM!.toStringAsFixed(0)),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (leitura.profundidadeTermoclinaMedida) ...[
              const SizedBox(height: 12),
              _avisoMedido(context, l10n),
            ] else if (leitura.perfilEstimado) ...[
              const SizedBox(height: 12),
              _avisoMock(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avisoMedido(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 14, color: Colors.green.shade800),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.termoclinaMedidaAviso,
              style: TextStyle(fontSize: 11, color: Colors.green.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avisoMock(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: 14, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.termoclinaMockAviso,
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicadoresOceanograficos extends StatelessWidget {
  final LeituraTermoclina leitura;
  const _IndicadoresOceanograficos({required this.leitura});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temperaturaProfundidade = leitura.temperaturaNaTermoclina;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _indicador(l10n.termoclinaIndicadorSst, '${leitura.sst.toStringAsFixed(1)} °C',
            Icons.thermostat_outlined, Colors.orange),
        _indicador(
          l10n.termoclinaIndicadorTemperaturaProfundidade,
          temperaturaProfundidade != null
              ? '${temperaturaProfundidade.toStringAsFixed(1)} °C'
              : '—',
          Icons.thermostat,
          Colors.blue,
        ),
        _indicador(
          l10n.termoclinaProfundidadeLabel,
          '${leitura.profundidadeTermoclina.toStringAsFixed(0)} m',
          Icons.vertical_align_bottom,
          Colors.deepOrange,
        ),
        _indicador(
          l10n.termoclinaIndicadorConfianca,
          '${(leitura.confianca * 100).round()}%',
          Icons.verified_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _indicador(String label, String valor, IconData icon, Color cor) {
    return SizedBox(
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cor),
              const SizedBox(height: 6),
              Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPerfilTemperatura extends StatelessWidget {
  final LeituraTermoclina leitura;
  const _CardPerfilTemperatura({required this.leitura});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.termoclinaPerfilTitulo,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            GraficoPerfilTermico(
              perfil: leitura.perfil,
              profundidadeTermoclinaM: leitura.profundidadeTermoclina,
              temperaturaNaTermoclinaC: leitura.temperaturaNaTermoclina,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.termoclinaFonteLabel(leitura.fonte),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
