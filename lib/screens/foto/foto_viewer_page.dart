import 'package:flutter/material.dart';
import '../../models/foto.dart';
import '../../repositories/foto_repository.dart';
import '../../services/auth_helper.dart';
import '../../theme/app_colors.dart';

class FotoViewerPage extends StatelessWidget {
  final Foto foto;
  const FotoViewerPage({super.key, required this.foto});

  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar foto'),
        content: const Text('Segura que queres borrar esta foto? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.rojo)),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al borrar: $e')));
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
          if (AuthHelper.puedeBorrarFotos)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmarBorrado(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: Image.network(foto.url, fit: BoxFit.contain))),
          if (foto.descripcion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(foto.descripcion, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
