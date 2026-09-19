import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

/// Modelo 3D do barco usado como marcador de posição no mapa — assume o
/// papel do ícone/seta de localização de antes.
///
/// Dois jeitos de usar, conforme a precisão que o contexto exige (ver
/// `MapaWidget`):
/// - **Marcador normal** (`Marker` do flutter_map, preso a uma coordenada
///   do mundo): usado fora do Modo Navegação, quando o mapa não está
///   recentralizando sozinho — o barco precisa se mover/pan junto com o
///   mapa pra continuar apontando o lugar certo.
/// - **Sobreposição fixa na tela** (Modo Navegação): como o mapa já
///   recentraliza a cada atualização de GPS (ver
///   `MapaWidget._alternarModoNavegacao`), manter o barco parado no
///   centro da tela continua preciso — é o mapa que se move por baixo
///   dele, não o contrário.
///
/// Em ambos os casos, o [rumo] (graus, da bússola) não move o barco — só
/// orbita a câmera ao redor dele (`setCameraOrbit`), dando a sensação de
/// "circular" o modelo conforme o aparelho gira, sem o ícone em si girar.
///
/// `IgnorePointer` garante que nenhum gesto (pan/zoom do mapa por baixo)
/// seja interceptado por essa camada — é só um enfeite visual sobreposto.
class BarcoNavegacao3d extends StatefulWidget {
  final double rumo;
  final double tamanho;

  const BarcoNavegacao3d({super.key, required this.rumo, this.tamanho = 120});

  @override
  State<BarcoNavegacao3d> createState() => _BarcoNavegacao3dState();
}

class _BarcoNavegacao3dState extends State<BarcoNavegacao3d> {
  // Mesmos phi/radius do orbit padrão do model-viewer ("0deg 75deg 105%")
  // — só o ângulo azimutal (theta = rumo) muda; um ângulo de elevação e
  // uma distância fixos mantêm o enquadramento sempre parecido, só girando
  // ao redor do barco.
  static const double _phiGraus = 75;
  static const double _raioPercentual = 105;

  final Flutter3DController _controller = Flutter3DController();
  bool _modeloCarregado = false;

  @override
  void didUpdateWidget(covariant BarcoNavegacao3d oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_modeloCarregado && oldWidget.rumo != widget.rumo) {
      _atualizarOrbita();
    }
  }

  void _atualizarOrbita() {
    _controller.setCameraOrbit(widget.rumo, _phiGraus, _raioPercentual);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: widget.tamanho,
        height: widget.tamanho,
        child: Flutter3DViewer(
          src: 'assets/icons/fishing-boat.glb',
          controller: _controller,
          enableTouch: false,
          progressBarColor: Colors.transparent,
          onLoad: (_) {
            _modeloCarregado = true;
            _atualizarOrbita();
          },
          onError: (erro) =>
              debugPrint('BarcoNavegacao3d: erro ao carregar o modelo ($erro)'),
        ),
      ),
    );
  }
}
