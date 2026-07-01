import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../core/storage/api_storage_service.dart';

class ApiTesterScreen extends StatefulWidget {
  const ApiTesterScreen({super.key});

  @override
  State<ApiTesterScreen> createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController(text: 'https://');
  final _bodyController = TextEditingController(
    text: '{\n  "latitude": {latitude},\n  "longitude": {longitude}\n}',
  );

  late final TabController _tabController;
  final _storage = ApiStorageService();

  String _method = 'GET';
  Position? _position;
  bool _loadingGps = true;
  bool _loadingRequest = false;
  _ApiResponse? _response;
  String? _requestError;

  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGps();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> _loadGps() async {
    setState(() => _loadingGps = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _loadingGps = false);
        return;
      }
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) setState(() => _position = last);

      final fresh = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20));
      if (mounted) setState(() => _position = fresh);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Interpolação ───────────────────────────────────────────────────────────

  String _interpolate(String template) {
    final lat = _position?.latitude.toStringAsFixed(6) ?? '0';
    final lon = _position?.longitude.toStringAsFixed(6) ?? '0';
    return template
        .replaceAll('{latitude}', lat)
        .replaceAll('{longitude}', lon);
  }

  // ── Requisição ─────────────────────────────────────────────────────────────

  Future<void> _sendRequest() async {
    final rawUrl = _urlController.text.trim();
    if (rawUrl.isEmpty) return;

    setState(() {
      _loadingRequest = true;
      _response = null;
      _requestError = null;
    });

    try {
      final url = Uri.parse(_interpolate(rawUrl));
      const headers = {'Content-Type': 'application/json'};
      final bodyStr = _interpolate(_bodyController.text);
      final sw = Stopwatch()..start();

      http.Response res;
      switch (_method) {
        case 'POST':
          res = await http.post(url, headers: headers, body: bodyStr);
        case 'PUT':
          res = await http.put(url, headers: headers, body: bodyStr);
        case 'PATCH':
          res = await http.patch(url, headers: headers, body: bodyStr);
        case 'DELETE':
          res = await http.delete(url, headers: headers);
        default:
          res = await http.get(url, headers: headers);
      }
      sw.stop();

      String pretty = res.body;
      try {
        pretty = const JsonEncoder.withIndent('  ')
            .convert(jsonDecode(res.body));
      } catch (_) {}

      final apiResponse = _ApiResponse(
        statusCode: res.statusCode,
        elapsed: sw.elapsed,
        body: pretty,
      );

      // Salva no Hive
      _storage.save(ApiEntry(
        url: _interpolate(rawUrl),
        method: _method,
        statusCode: res.statusCode,
        elapsedMs: sw.elapsed.inMilliseconds,
        responseBody: pretty,
        latitude: _position?.latitude,
        longitude: _position?.longitude,
        savedAt: DateTime.now(),
      ));

      setState(() => _response = apiResponse);
    } catch (e) {
      setState(() => _requestError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingRequest = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de API'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.send), text: 'Testar'),
            Tab(
              icon: const Icon(Icons.history),
              text: 'Histórico (${_storage.count})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTesterTab(),
          _buildHistoricoTab(),
        ],
      ),
    );
  }

  // ── Aba Testar ─────────────────────────────────────────────────────────────

  Widget _buildTesterTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGpsCard(),
        const SizedBox(height: 16),
        _buildRequestCard(),
        const SizedBox(height: 16),
        if (_response != null) _buildResponseCard(_response!),
        if (_requestError != null) _buildErrorCard(_requestError!),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildGpsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.gps_fixed, color: Color(0xFF1B3A5C)),
            const SizedBox(width: 12),
            Expanded(
              child: _loadingGps && _position == null
                  ? const Text('Obtendo posição...',
                      style: TextStyle(color: Colors.grey))
                  : _position == null
                      ? const Text('Posição indisponível',
                          style: TextStyle(color: Colors.red))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lat: ${_position!.latitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13),
                            ),
                            Text(
                              'Lon: ${_position!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Use {latitude} e {longitude} na URL ou body',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
            ),
            if (_loadingGps)
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Atualizar GPS',
                onPressed: _loadGps,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard() {
    final hasBody =
        _method == 'POST' || _method == 'PUT' || _method == 'PATCH';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _method,
                    items: _methods
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _methodColor(m))),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://api.exemplo.com/rota',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 13),
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
            if (hasBody) ...[
              const SizedBox(height: 12),
              Text('Body (JSON)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              TextField(
                controller: _bodyController,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                style:
                    const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _loadingRequest ? null : _sendRequest,
                icon: _loadingRequest
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_loadingRequest ? 'Enviando...' : 'Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(_ApiResponse r) {
    final isOk = r.statusCode >= 200 && r.statusCode < 300;
    final color = isOk ? Colors.green[700]! : Colors.red[700]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text('${r.statusCode}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15)),
                ),
                const SizedBox(width: 12),
                Text('${r.elapsed.inMilliseconds} ms',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 13)),
                const Spacer(),
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text('Salvo',
                    style: TextStyle(
                        color: Colors.green[700], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                r.body.isEmpty ? '(sem conteúdo)' : r.body,
                style: const TextStyle(
                  color: Color(0xFFD4D4D4),
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(error,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Aba Histórico ──────────────────────────────────────────────────────────

  Widget _buildHistoricoTab() {
    final entries = _storage.getAll();

    if (entries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma resposta salva ainda.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('${entries.length} registros',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  _storage.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Limpar tudo'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildEntryCard(entries[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(ApiEntry entry, int index) {
    final isOk = entry.statusCode >= 200 && entry.statusCode < 300;
    final color = isOk ? Colors.green[700]! : Colors.red[700]!;
    final d = entry.savedAt;
    final timestamp =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            '${entry.statusCode}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13),
          ),
        ),
        title: Text(
          entry.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Row(
          children: [
            Text(
              entry.method,
              style: TextStyle(
                  color: _methodColor(entry.method),
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            ),
            const SizedBox(width: 8),
            Text('${entry.elapsedMs} ms',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 11)),
            const SizedBox(width: 8),
            Text(timestamp,
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        children: [
          if (entry.latitude != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.latitude!.toStringAsFixed(6)}, '
                    '${entry.longitude!.toStringAsFixed(6)}',
                    style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              entry.responseBody.isEmpty
                  ? '(sem conteúdo)'
                  : entry.responseBody,
              style: const TextStyle(
                color: Color(0xFFD4D4D4),
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _methodColor(String method) => switch (method) {
        'GET' => Colors.green[700]!,
        'POST' => Colors.blue[700]!,
        'PUT' => Colors.orange[700]!,
        'PATCH' => Colors.purple[700]!,
        'DELETE' => Colors.red[700]!,
        _ => Colors.grey,
      };
}

class _ApiResponse {
  final int statusCode;
  final Duration elapsed;
  final String body;

  const _ApiResponse({
    required this.statusCode,
    required this.elapsed,
    required this.body,
  });
}
