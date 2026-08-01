import 'package:flutter/material.dart';
import '../models/actividad_item.dart';
import '../theme/app_colors.dart';
import 'actividad_detalle_sheet.dart';

class ActividadTile extends StatelessWidget {
  final ActividadItem item;

  const ActividadTile({super.key, required this.item});

  IconData get _icono {
    switch (item.tipo) {
      case 'animal_nuevo':
        return Icons.pets;
      case 'nota':
        return Icons.edit_note;
      case 'foto':
        return Icons.photo_camera;
      default:
        return Icons.circle;
    }
  }

  String get _texto {
    switch (item.tipo) {
      case 'animal_nuevo':
        return 'Se agrego a ${item.animalNombre}';
      case 'nota':
        return 'Nueva nota en ${item.animalNombre}${item.detalle != null && item.detalle!.isNotEmpty ? ": ${item.detalle}" : ""}';
      case 'foto':
        return 'Nueva foto de ${item.animalNombre}';
      default:
        return item.animalNombre;
    }
  }

  String get _fechaTexto {
    final ahora = DateTime.now();
    final diff = ahora.difference(item.fecha);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} dias';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.verde.withOpacity(0.1),
        child: Icon(_icono, color: AppColors.verde, size: 20),
      ),
      title: Text(_texto, style: const TextStyle(fontSize: 13)),
      subtitle: Text(_fechaTexto, style: const TextStyle(fontSize: 11)),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ActividadDetalleSheet(item: item),
          ),
        );
      },
    );
  }
}
