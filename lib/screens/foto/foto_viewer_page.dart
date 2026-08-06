import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/foto.dart';
import '../../repositories/foto_repository.dart';
import '../../services/auth_helper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';

class FotoViewerPage extends StatelessWidget {
  final Foto foto;
  const FotoViewerPage({super.key, required this.foto});

  Future<void> _descargarFoto(BuildContext context) async {
    try {
      final respuesta = await http.get(Uri.parse(foto.url));
      final rutaGuardada = await FilePicker.saveFile(
        dialogTitle: 'Guardar foto',
        fileName: 'foto_${foto.id}.jpg',
        bytes: respuesta.bodyBytes,
      );
      if (context.mounted && rutaGuardada != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto guardada')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  Future<void> _compartirFoto(BuildContext context) async {
    try {
      final respuesta = await http.get(Uri.parse(foto.url));
      final dir = await getTemporaryDirectory();
      final archivo = File('${dir.path}/foto_${foto.id}.jpg');
      await archivo.writeAsBytes(respuesta.bodyBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(archivo.path)]),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.borrarFoto),
        content: const Text(AppStrings.confirmarBorrarFoto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Borrar',
              style: TextStyle(color: AppColors.rojo),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await FotoRepository().borrar(foto.id);
        if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.descargar),
            onPressed: () => _descargarFoto(context),
          ),
          IconButton(
            icon: const Icon(AppIcons.compartir),
            onPressed: () => _compartirFoto(context),
          ),
          if (AuthHelper.puedeBorrarFotos)
            IconButton(
              icon: const Icon(AppIcons.eliminar),
              onPressed: () => _confirmarBorrado(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(child: Image.network(foto.url, fit: BoxFit.contain)),
          ),
          if (foto.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                foto.descripcion,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
