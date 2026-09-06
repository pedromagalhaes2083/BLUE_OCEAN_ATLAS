import 'package:flutter/material.dart';

/// Painel "Camadas do mapa" — lista de camadas com checkbox, aberto como
/// bottom sheet (ver `MapaWidgetState._abrirPainelCamadas`).
///
/// Mantém uma cópia local de cada valor só pra atualizar o check
/// imediatamente (o bottom sheet é uma subárvore própria, não reconstruída
/// sozinha quando o estado do mapa por trás dele muda) — quem manda de
/// verdade continua sendo o `MapaWidgetState`, através dos callbacks
/// `on...Changed`, que é o que liga/desliga a camada de verdade no mapa.
///
/// Camadas ainda não implementadas (só "Produtividade Blue Ocean" —
/// depende de um índice próprio que ainda não existe, ver
/// `MapaWidgetState`) aparecem desabilitadas com "Em breve" — a spec pede
/// explicitamente pra nunca inventar dado, e uma camada marcada como
/// disponível sem fonte de dado real seria exatamente isso. Profundidade e
/// Curvas de profundidade são dado batimétrico real (GEBCO, via o próprio
/// GeoServer do projeto de profundidade do OpenSeaMap).
class CamadasPainel extends StatefulWidget {
  final bool mapaDeRuas;
  final ValueChanged<bool> onMapaDeRuasChanged;

  final bool informacoesNauticas;
  final ValueChanged<bool> onInformacoesNauticasChanged;

  final bool profundidade;
  final ValueChanged<bool> onProfundidadeChanged;

  final bool curvasProfundidade;
  final ValueChanged<bool> onCurvasProfundidadeChanged;

  final bool temperatura;
  final ValueChanged<bool> onTemperaturaChanged;

  final bool clorofila;
  final ValueChanged<bool> onClorofilaChanged;

  final bool pontosDePesca;
  final ValueChanged<bool> onPontosDePescaChanged;

  const CamadasPainel({
    super.key,
    required this.mapaDeRuas,
    required this.onMapaDeRuasChanged,
    required this.informacoesNauticas,
    required this.onInformacoesNauticasChanged,
    required this.profundidade,
    required this.onProfundidadeChanged,
    required this.curvasProfundidade,
    required this.onCurvasProfundidadeChanged,
    required this.temperatura,
    required this.onTemperaturaChanged,
    required this.clorofila,
    required this.onClorofilaChanged,
    required this.pontosDePesca,
    required this.onPontosDePescaChanged,
  });

  @override
  State<CamadasPainel> createState() => _CamadasPainelState();
}

class _CamadasPainelState extends State<CamadasPainel> {
  late bool _mapaDeRuas = widget.mapaDeRuas;
  late bool _informacoesNauticas = widget.informacoesNauticas;
  late bool _profundidade = widget.profundidade;
  late bool _curvasProfundidade = widget.curvasProfundidade;
  late bool _temperatura = widget.temperatura;
  late bool _clorofila = widget.clorofila;
  late bool _pontosDePesca = widget.pontosDePesca;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        // Sem isso, com todas as camadas + "Em breve" listadas, o painel
        // passava da altura da tela e a lista de baixo (Produtividade,
        // atribuições) ficava cortada sem rolar — visto no dispositivo
        // ("BOTTOM OVERFLOWED BY 118 PIXELS").
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'CAMADAS DO MAPA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                value: _mapaDeRuas,
                onChanged: (v) => setState(() {
                  _mapaDeRuas = v ?? false;
                  widget.onMapaDeRuasChanged(_mapaDeRuas);
                }),
                title: const Text('Mapa de Ruas (OpenStreetMap)'),
                subtitle:
                    const Text('Desligada: mostra a carta náutica carregada'),
                dense: true,
              ),
              CheckboxListTile(
                value: _informacoesNauticas,
                onChanged: !_mapaDeRuas
                    ? null
                    : (v) => setState(() {
                          _informacoesNauticas = v ?? false;
                          widget.onInformacoesNauticasChanged(
                              _informacoesNauticas);
                        }),
                title: const Text('Informações náuticas (OpenSeaMap)'),
                subtitle: const Text(
                    'Boias, marcas, faróis e portos — só sobre o Mapa de Ruas'),
                dense: true,
              ),
              CheckboxListTile(
                value: _profundidade,
                onChanged: !_mapaDeRuas
                    ? null
                    : (v) => setState(() {
                          _profundidade = v ?? false;
                          widget.onProfundidadeChanged(_profundidade);
                        }),
                title: const Text('Profundidade'),
                subtitle: const Text(
                    'Sombreamento batimétrico (GEBCO) · OpenSeaMap — só sobre o Mapa de Ruas'),
                dense: true,
              ),
              CheckboxListTile(
                value: _curvasProfundidade,
                onChanged: !_mapaDeRuas
                    ? null
                    : (v) => setState(() {
                          _curvasProfundidade = v ?? false;
                          widget.onCurvasProfundidadeChanged(_curvasProfundidade);
                        }),
                title: const Text('Curvas de profundidade'),
                subtitle: const Text(
                    'Isóbatas · OpenSeaMap — só sobre o Mapa de Ruas'),
                dense: true,
              ),
              CheckboxListTile(
                value: _temperatura,
                onChanged: (v) => setState(() {
                  _temperatura = v ?? false;
                  widget.onTemperaturaChanged(_temperatura);
                }),
                title: const Text('Temperatura da superfície do mar'),
                dense: true,
              ),
              CheckboxListTile(
                value: _clorofila,
                onChanged: (v) => setState(() {
                  _clorofila = v ?? false;
                  widget.onClorofilaChanged(_clorofila);
                }),
                title: const Text('Clorofila-a'),
                subtitle: const Text(
                    'Indicador de produtividade · Copernicus Marine'),
                dense: true,
              ),
              CheckboxListTile(
                value: _pontosDePesca,
                onChanged: (v) => setState(() {
                  _pontosDePesca = v ?? false;
                  widget.onPontosDePescaChanged(_pontosDePesca);
                }),
                title: const Text('Pontos de pesca (calor de produção)'),
                dense: true,
              ),
              const Divider(),
              const _CamadaEmBreve('Produtividade Blue Ocean'),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '© OpenStreetMap contributors · © OpenSeaMap contributors · '
                'Profundidade: GEBCO / OpenSeaMap depth project',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CamadaEmBreve extends StatelessWidget {
  final String titulo;

  const _CamadaEmBreve(this.titulo);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: false,
      onChanged: null,
      title: Text(titulo,
          style: TextStyle(color: Theme.of(context).disabledColor)),
      subtitle: const Text('Em breve'),
      dense: true,
    );
  }
}
