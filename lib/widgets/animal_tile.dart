import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme/app_colors.dart';

class AnimalTile extends StatelessWidget {
  final Animal animal;
  final String? fotoUrl;
  const AnimalTile({super.key, required this.animal, this.fotoUrl});

  Color get _colorEstado {
    switch (animal.estadoNombre) {
      case 'enfermo':
        return AppColors.rojo;
      case 'cuidado_especial':
        return AppColors.amarillo;
      case 'fallecido':
        return Colors.grey;
      default:
        return AppColors.verde;
    }
  }

  String get _labelEstado {
    switch (animal.estadoNombre) {
      case 'bien':
        return 'Activo';
      case 'enfermo':
        return 'Enfermo';
      case 'cuidado_especial':
        return 'Cuidado especial';
      case 'fallecido':
        return 'Fallecido';
      default:
        return animal.estadoNombre;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.madera.withOpacity(0.15),
        backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
        child: fotoUrl == null
            ? Text(
                animal.nombre.isNotEmpty ? animal.nombre[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.madera, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(animal.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (animal.alerta == 'rojo' || animal.alerta == 'amarillo') ...[
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: animal.alerta == 'rojo' ? AppColors.rojo : AppColors.amarillo,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text('${animal.especieNombre} · ${animal.sectorNombre}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _colorEstado.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _labelEstado,
          style: TextStyle(color: _colorEstado, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}