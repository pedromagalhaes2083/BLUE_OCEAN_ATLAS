import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerScreen extends StatelessWidget {
  final File pdfFile;
  final String titulo;

  const PdfViewerScreen({
    super.key,
    required this.pdfFile,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: PdfViewer.file(
        pdfFile.path,
        // Parâmetros compatíveis com a versão atual do pdfrx
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: const Text(
          'Use dois dedos para dar zoom • Arraste para mover a carta',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }
}
