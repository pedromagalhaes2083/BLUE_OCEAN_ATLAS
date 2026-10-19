import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/services/camadas_oceanicas_cache.dart';
import '../../../core/services/street_map_cache_service.dart';

/// Máximo de tiles permitido por download — acima disso pedimos pra dar
/// mais zoom antes. Protege o armazenamento do aparelho e evita sobrecarregar
/// o servidor de tiles gratuito do OpenStreetMap com downloads em massa.
const _maxTilesPorDownload = 3000;

/// Diálogo de "baixar região para uso offline": mostra quantos tiles a área
/// visível do mapa vai precisar (do zoom atual até 3 níveis a mais) e baixa
/// com barra de progresso. Sempre baixa o mapa de ruas
/// ([StreetMapCacheService]); opcionalmente (checkbox, ligado por padrão)
/// baixa junto as camadas do OpenSeaMap — profundidade (GEBCO), isóbatas e
/// marcas náuticas (ver `camadas_oceanicas_cache.dart`) — mesmo cache em
/// disco que a tela de Navegação de Rota já usa, então o que for baixado
/// aqui já serve lá offline, e vice-versa.
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

  bool _incluirCamadasOceanicas = true;

  int _feitos = 0;
  bool _baixando = false;
  bool _concluido = false;
  String? _erro;

  /// Quantas vezes a lista de tiles é baixada nessa região: 1 (ruas) + 3
  /// (profundidade/isóbatas/marcas) quando a opção está marcada — todas
  /// usam o mesmo bbox/zoom, então o mesmo [_tiles] vale pras quatro,
  /// só muda o cache/URL de destino.
  int get _camadas => 1 + (_incluirCamadasOceanicas ? 3 : 0);
  int get _totalTiles => _tiles.length * _camadas;

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
      _feitos = 0;
    });
    try {
      final caches = [
        _service,
        if (_incluirCamadasOceanicas) ...[
          cacheProfundidadeOceanica,
          cacheContornosOceanicos,
          cacheSeamarkOceanico,
        ],
      ];

      for (final cache in caches) {
        await for (final progresso in cache.baixarRegiao(
          swLat: widget.bounds.south,
          swLon: widget.bounds.west,
          neLat: widget.bounds.north,
          neLon: widget.bounds.east,
          zoomMin: _zoomMin,
          zoomMax: _zoomMax,
          cancelToken: _cancelToken,
        )) {
          if (!mounted) return;
          if (_cancelToken.cancelado) return;
          setState(() {
            // `feitos` de cada camada é relativo a ela mesma (0.._tiles.length)
            // — soma ao que as camadas anteriores já completaram pra dar um
            // progresso combinado contínuo em vez de reiniciar a cada camada.
            _feitos = (caches.indexOf(cache) * _tiles.length) + progresso.feitos;
          });
        }
        if (_cancelToken.cancelado) {
          if (!mounted) return;
          setState(() => _baixando = false);
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _baixando = false;
        _concluido = true;
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
    final tamanhoEstimadoMb = (_totalTiles * 20) / 1024;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Baixar mapa para uso offline'),
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
            Text('Baixando $_feitos de $_totalTiles tiles...'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
                value: _totalTiles == 0 ? 0 : _feitos / _totalTiles),
          ] else ...[
            Text(
              'Baixa a área visível do mapa (zoom $_zoomMin a $_zoomMax) '
              'para poder navegar sem internet depois.',
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              value: _incluirCamadasOceanicas,
              onChanged: (v) =>
                  setState(() => _incluirCamadasOceanicas = v ?? true),
              title: const Text(
                'Incluir camadas do OpenSeaMap',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Profundidade, isóbatas e marcas náuticas — mesmas usadas na '
                'Navegação de Rota.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_totalTiles tiles · ~${tamanhoEstimadoMb.toStringAsFixed(1)} MB',
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
