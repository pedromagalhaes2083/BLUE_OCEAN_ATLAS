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
/// A câmera desliza suavemente até o novo rumo (em vez de saltar direto pra
/// lá) via [AnimationController] — ver [_iniciarTransicaoPara].
///
/// `IgnorePointer` garante que nenhum gesto (pan/zoom do mapa por baixo)
/// seja interceptado por essa camada — é só um enfeite visual sobreposto.
class BarcoNavegacao3d extends StatefulWidget {
  final double rumo;
  final double tamanho;

  /// Se true, ignora mudanças de [rumo] — não reorbita a câmera enquanto
  /// o usuário está arrastando/dando pinça no mapa por baixo (ver
  /// `MapaWidget._usuarioMovendoMapa`). Isso libera o frame pro gesto de
  /// pan/zoom em vez de competir com ele, e evita um "estranhamento"
  /// visual do barco girando sozinho enquanto o dedo está na tela. Assim
  /// que volta a false, retoma pro rumo mais recente de uma vez.
  final bool pausado;

  const BarcoNavegacao3d({
    super.key,
    required this.rumo,
    this.tamanho = 120,
    this.pausado = false,
  });

  @override
  State<BarcoNavegacao3d> createState() => _BarcoNavegacao3dState();
}

class _BarcoNavegacao3dState extends State<BarcoNavegacao3d>
    with SingleTickerProviderStateMixin {
  // Mesmos phi/radius do orbit padrão do model-viewer ("0deg 75deg 105%")
  // — só o ângulo azimutal (theta = rumo) muda; um ângulo de elevação e
  // uma distância fixos mantêm o enquadramento sempre parecido, só girando
  // ao redor do barco.
  static const double _phiGraus = 75;
  static const double _raioPercentual = 105;

  // O modelo exportado tem a proa alinhada com o eixo da câmera em theta=0,
  // não com o "norte" (theta=-90 no referencial do model-viewer) — por isso
  // subtrai-se 90° (giro pra esquerda) do rumo aqui pra proa ficar sempre
  // apontada pro norte quando o rumo é 0, mantendo a orbita consistente
  // com a bússola real.
  static const double _offsetProaGraus = -90;

  // Duração do "deslizar" da câmera até o novo rumo a cada atualização —
  // é isso que evita o salto brusco/tremido de mandar o valor bruto (já
  // suavizado, mas ainda discreto) direto pro WebView (ver
  // MapaWidget._suavizarRumo pro filtro do rumo em si).
  static const Duration _duracaoTransicao = Duration(milliseconds: 220);

  // Cada chamada de setCameraOrbit é uma ida à ponte JS do WebView — a
  // interpolação em si roda a cada frame (Ticker), mas só reenvia pro
  // model-viewer nessa cadência, senão a suavidade vira gasto à toa.
  static const Duration _intervaloEnvio = Duration(milliseconds: 50);

  final Flutter3DController _controller = Flutter3DController();
  late final AnimationController _animController;
  bool _modeloCarregado = false;

  double _rumoOrigem = 0;
  double _rumoDestino = 0;
  double _rumoExibido = 0;
  DateTime? _ultimoEnvio;

  @override
  void initState() {
    super.initState();
    _rumoOrigem = widget.rumo;
    _rumoDestino = widget.rumo;
    _rumoExibido = widget.rumo;
    _animController = AnimationController(
      vsync: this,
      duration: _duracaoTransicao,
    )..addListener(_aoAvancarTransicao);
  }

  @override
  void didUpdateWidget(covariant BarcoNavegacao3d oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ignora rumo novo enquanto pausado — quando destravar, o rumo mais
    // recente (widget.rumo) provavelmente já vai diferir de _rumoDestino
    // (o último aplicado antes de pausar), disparando a transição pra lá
    // de uma vez só, sem precisar reproduzir cada mudança perdida no meio.
    if (_modeloCarregado && !widget.pausado && widget.rumo != _rumoDestino) {
      _iniciarTransicaoPara(widget.rumo);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Diferença angular COM sinal, pelo caminho mais curto (-180..180) —
  /// evita que o "deslizar" dê a volta longa quando cruza 0°/360°.
  double _menorCaminho(double de, double para) {
    var diferenca = (para - de) % 360;
    if (diferenca > 180) diferenca -= 360;
    if (diferenca < -180) diferenca += 360;
    return diferenca;
  }

  void _iniciarTransicaoPara(double novoRumo) {
    final delta = _menorCaminho(_rumoExibido, novoRumo);
    _rumoOrigem = _rumoExibido;
    _rumoDestino = _rumoExibido + delta;
    _animController
      ..stop()
      ..reset()
      ..forward();
  }

  void _aoAvancarTransicao() {
    final t = Curves.easeOut.transform(_animController.value);
    _rumoExibido = _rumoOrigem + (_rumoDestino - _rumoOrigem) * t;
    _enviarOrbitaComThrottle();
  }

  void _enviarOrbitaComThrottle() {
    final agora = DateTime.now();
    if (_ultimoEnvio != null && agora.difference(_ultimoEnvio!) < _intervaloEnvio) {
      return;
    }
    _ultimoEnvio = agora;
    final normalizado = ((_rumoExibido % 360) + 360) % 360;
    _controller.setCameraOrbit(
        normalizado + _offsetProaGraus, _phiGraus, _raioPercentual);
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
            _ultimoEnvio = DateTime.now();
            _controller.setCameraOrbit(
                _rumoExibido + _offsetProaGraus, _phiGraus, _raioPercentual);
          },
          onError: (erro) =>
              debugPrint('BarcoNavegacao3d: erro ao carregar o modelo ($erro)'),
        ),
      ),
    );
  }
}
