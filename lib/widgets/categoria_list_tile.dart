import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoriaListTile extends StatelessWidget {
  final String nombre;
  final VoidCallback onEditar;
  final VoidCallback onBorrar;

  const CategoriaListTile({
    super.key,
    required this.nombre,
    required this.onEditar,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(nombre, style: const TextStyle(color: Colors.black87)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: onEditar,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.rojo, size: 20),
            onPressed: onBorrar,
          ),
        ],
      ),
    );
  }
}
