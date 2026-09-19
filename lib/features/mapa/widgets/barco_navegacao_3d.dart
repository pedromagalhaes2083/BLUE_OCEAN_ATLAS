import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

/// Modelo 3D do barco usado no Modo Navegação (ver `MapaWidget`) — fica
/// fixo no centro-inferior da tela, sem girar sozinho: quem gira é o
/// próprio mapa (course-up, mesma convenção do modo de navegação do
/// Waze/Google Maps), então o barco sempre aponta "pra cima" da tela, na
/// direção do rumo atual.
///
/// `IgnorePointer` garante que nenhum gesto (pan/zoom do mapa por baixo)
/// seja interceptado por essa camada — é só um enfeite visual sobreposto.
class BarcoNavegacao3d extends StatelessWidget {
  const BarcoNavegacao3d({super.key});

  static const _tamanho = 120.0;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: _tamanho,
        height: _tamanho,
        child: Flutter3DViewer(
          src: 'assets/icons/fishing-boat.glb',
          enableTouch: false,
          progressBarColor: Colors.transparent,
          onError: (erro) =>
              debugPrint('BarcoNavegacao3d: erro ao carregar o modelo ($erro)'),
        ),
      ),
    );
  }
}
