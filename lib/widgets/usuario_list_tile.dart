import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class UsuarioListTile extends StatelessWidget {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool bloqueado;
  final bool esUsuarioActual;
  final void Function(String nuevoRol) onCambiarRol;
  final VoidCallback onToggleBloqueo;
  final VoidCallback onBorrar;

  const UsuarioListTile({
    super.key,
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.bloqueado,
    required this.esUsuarioActual,
    required this.onCambiarRol,
    required this.onToggleBloqueo,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(nombre.isNotEmpty ? nombre : email, style: TextStyle(decoration: bloqueado ? TextDecoration.lineThrough : null)),
      subtitle: Text(email, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: rol,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'estandar', child: Text('Voluntario')),
              DropdownMenuItem(value: 'visita', child: Text('Visita')),
            ],
            onChanged: (v) {
              if (v != null) onCambiarRol(v);
            },
          ),
          IconButton(
            icon: Icon(bloqueado ? Icons.lock : Icons.lock_open, color: bloqueado ? AppColors.rojo : AppColors.verde, size: 20),
            onPressed: onToggleBloqueo,
          ),
          Opacity(
            opacity: esUsuarioActual ? 0.3 : 1,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.rojo, size: 20),
              onPressed: esUsuarioActual ? null : onBorrar,
            ),
          ),
        ],
      ),
    );
  }
}
