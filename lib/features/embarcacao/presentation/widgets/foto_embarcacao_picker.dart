import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/foto_embarcacao_service.dart';

class FotoEmbarcacaoPicker extends StatefulWidget {
  final String? fotoPath;
  final ValueChanged<String?> onChanged;

  const FotoEmbarcacaoPicker({
    super.key,
    required this.fotoPath,
    required this.onChanged,
  });

  @override
  State<FotoEmbarcacaoPicker> createState() => _FotoEmbarcacaoPickerState();
}

class _FotoEmbarcacaoPickerState extends State<FotoEmbarcacaoPicker> {
  bool _carregando = false;

  Future<void> _escolherFoto() async {
    setState(() => _carregando = true);
    try {
      final resultado = await FilePicker.platform.pickFiles(type: FileType.image);
      final origemPath = resultado?.files.single.path;
      if (origemPath == null) return;

      final destino = await FotoEmbarcacaoService.salvar(origemPath);
      widget.onChanged(destino);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar foto: $e')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final temFoto = widget.fotoPath != null && File(widget.fotoPath!).existsSync();

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: _carregando ? null : _escolherFoto,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F7FA),
                border: Border.all(color: Colors.blue.shade100, width: 2),
                image: temFoto
                    ? DecorationImage(
                        image: FileImage(File(widget.fotoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : temFoto
                      ? null
                      : Icon(Icons.add_a_photo,
                          color: Colors.blue.shade900, size: 30),
            ),
          ),
          if (temFoto && !_carregando)
            Positioned(
              right: -4,
              top: -4,
              child: GestureDetector(
                onTap: () => widget.onChanged(null),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
