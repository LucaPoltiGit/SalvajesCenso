import 'package:flutter/material.dart';

/// Dialogo informativo de un solo boton ("Entendido"), sin opcion de
/// continuar. Para avisos donde una accion quedo bloqueada.
Future<void> mostrarAviso(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
      ],
    ),
  );
}
