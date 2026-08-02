import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dialogo de confirmacion estandar antes de borrar algo. Devuelve true
/// solo si el usuario confirmo tocando "Borrar".
Future<bool> confirmarBorrado(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Borrar', style: TextStyle(color: AppColors.rojo)),
        ),
      ],
    ),
  );
  return confirmar == true;
}
