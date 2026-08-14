import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Tela genérica pra abrir uma página web dentro do próprio app, sem
/// precisar sair pro navegador — usado, por exemplo, pelos Avisos aos
/// Navegantes (site da Marinha do Brasil).
class WebViewScreen extends StatefulWidget {
  final String titulo;
  final String url;

  const WebViewScreen({super.key, required this.titulo, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _carregando = true;
            _erro = null;
          }),
          onPageFinished: (_) => setState(() => _carregando = false),
          onWebResourceError: (erro) => setState(() {
            _carregando = false;
            _erro = erro.description;
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_carregando)
            const Center(child: CircularProgressIndicator()),
          if (_erro != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Não foi possível carregar a página.\n$_erro',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _controller.reload(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
