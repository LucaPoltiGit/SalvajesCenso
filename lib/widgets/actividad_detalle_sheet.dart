import 'package:flutter/material.dart';
import '../models/actividad_item.dart';
import '../repositories/animal_repository.dart';
import '../screens/ficha/ficha_page.dart';
import '../theme/app_colors.dart';
import '../utils/formatear_fecha.dart';

class ActividadDetalleSheet extends StatelessWidget {
  final ActividadItem item;
  const ActividadDetalleSheet({super.key, required this.item});

  String get _accionTexto {
    switch (item.tipo) {
      case 'animal_nuevo':
        return 'Se agrego a ${item.animalNombre}';
      case 'nota':
        return 'Nueva nota en ${item.animalNombre}';
      case 'foto':
        return 'Nueva foto de ${item.animalNombre}';
      default:
        return item.animalNombre;
    }
  }

  Future<void> _irAVer(BuildContext context) async {
    Navigator.pop(context);
    try {
      final animal = await AnimalRepository().obtenerPorId(item.animalId);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FichaPage(animal: animal)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el perfil: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_accionTexto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (item.detalle != null && item.detalle!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.detalle!, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.madera),
              const SizedBox(width: 6),
              Text(formatearFecha(item.fecha), style: const TextStyle(fontSize: 12, color: AppColors.madera)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.madera),
              const SizedBox(width: 6),
              Text(item.quien ?? 'Sin identificar', style: const TextStyle(fontSize: 12, color: AppColors.madera)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
              onPressed: () => _irAVer(context),
              child: const Text('Ir al perfil'),
            ),
          ),
        ],
      ),
    );
  }
}
