import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SeleccionarFotoButton extends StatelessWidget {
  final String texto;
  final void Function(List<int> bytes) onFotoSeleccionada;
  final bool cargando;

  const SeleccionarFotoButton({
    super.key,
    required this.texto,
    required this.onFotoSeleccionada,
    this.cargando = false,
  });

  Future<void> _seleccionar() async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);
    if (resultado == null || resultado.files.isEmpty) return;
    final archivo = resultado.files.first;
    List<int> bytes;
    if (archivo.bytes != null) {
      bytes = archivo.bytes!;
    } else if (archivo.path != null) {
      bytes = await File(archivo.path!).readAsBytes();
    } else {
      return;
    }
    onFotoSeleccionada(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: cargando ? null : _seleccionar,
      icon: cargando
          ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.madera),
      label: Text(texto, style: TextStyle(color: AppColors.madera)),
      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.madera)),
    );
  }
}
