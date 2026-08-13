import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/services/street_map_cache_service.dart';

/// Máximo de tiles permitido por download — acima disso pedimos pra dar
/// mais zoom antes. Protege o armazenamento do aparelho e evita sobrecarregar
/// o servidor de tiles gratuito do OpenStreetMap com downloads em massa.
const _maxTilesPorDownload = 3000;

/// Diálogo de "baixar região para uso offline": mostra quantos tiles a área
/// visível do mapa vai precisar (do zoom atual até 3 níveis a mais) e baixa
/// com barra de progresso, salvando no [StreetMapCacheService].
class DownloadRegiaoDialog extends StatefulWidget {
  final LatLngBounds bounds;
  final int zoomAtual;

  const DownloadRegiaoDialog({
    super.key,
    required this.bounds,
    required this.zoomAtual,
  });

  @override
  State<DownloadRegiaoDialog> createState() => _DownloadRegiaoDialogState();
}

class _DownloadRegiaoDialogState extends State<DownloadRegiaoDialog> {
  final StreetMapCacheService _service = StreetMapCacheService();
  final CancelToken _cancelToken = CancelToken();

  late final int _zoomMin;
  late final int _zoomMax;
  late final List<(int, int, int)> _tiles;

  ProgressoDownload? _progresso;
  bool _baixando = false;
  bool _concluido = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _zoomMin = widget.zoomAtual.clamp(1, 16);
    _zoomMax = (_zoomMin + 3).clamp(1, 16);
    _tiles = _service.tilesDaRegiao(
      swLat: widget.bounds.south,
      swLon: widget.bounds.west,
      neLat: widget.bounds.north,
      neLon: widget.bounds.east,
      zoomMin: _zoomMin,
      zoomMax: _zoomMax,
    );
  }

  @override
  void dispose() {
    _cancelToken.cancelar();
    super.dispose();
  }

  Future<void> _iniciarDownload() async {
    setState(() {
      _baixando = true;
      _erro = null;
    });
    try {
      await for (final progresso in _service.baixarRegiao(
        swLat: widget.bounds.south,
        swLon: widget.bounds.west,
        neLat: widget.bounds.north,
        neLon: widget.bounds.east,
        zoomMin: _zoomMin,
        zoomMax: _zoomMax,
        cancelToken: _cancelToken,
      )) {
        if (!mounted) return;
        setState(() => _progresso = progresso);
      }
      if (!mounted) return;
      setState(() {
        _baixando = false;
        _concluido = !_cancelToken.cancelado;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _baixando = false;
        _erro = 'Erro ao baixar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final excedeLimite = _tiles.length > _maxTilesPorDownload;
    final tamanhoEstimadoMb = (_tiles.length * 20) / 1024;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Baixar mapa de ruas'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_concluido) ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 40),
            const SizedBox(height: 12),
            const Text('Região baixada — disponível offline.'),
          ] else if (excedeLimite) ...[
            const Text(
              'A área visível é muito grande para baixar de uma vez. '
              'Dê mais zoom no mapa e tente novamente.',
            ),
          ] else if (_baixando) ...[
            Text(
              'Baixando ${_progresso?.feitos ?? 0} de ${_tiles.length} tiles...',
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progresso?.fracao ?? 0),
          ] else ...[
            Text(
              'Baixa a área visível do mapa (zoom $_zoomMin a $_zoomMax) '
              'para poder navegar sem internet depois.',
            ),
            const SizedBox(height: 12),
            Text(
              '${_tiles.length} tiles · ~${tamanhoEstimadoMb.toStringAsFixed(1)} MB',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ],
      ),
      actions: [
        if (_concluido || excedeLimite)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          )
        else ...[
          TextButton(
            onPressed: () {
              _cancelToken.cancelar();
              Navigator.pop(context);
            },
            child: Text(_baixando ? 'Cancelar' : 'Fechar'),
          ),
          if (!_baixando)
            ElevatedButton(
              onPressed: _iniciarDownload,
              child: const Text('Baixar'),
            ),
        ],
      ],
    );
  }
}
