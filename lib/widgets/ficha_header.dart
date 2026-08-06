import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../services/auth_helper.dart';
import '../theme/app_colors.dart';
import '../utils/imagen_por_especie.dart';

class FichaHeader extends StatelessWidget {
  final Animal animal;
  final String? fotoUrl;
  final VoidCallback onEditarFoto;

  const FichaHeader({
    super.key,
    required this.animal,
    required this.fotoUrl,
    required this.onEditarFoto,
  });

  Widget _buildAlertaBanner() {
    if (animal.alerta != 'rojo' && animal.alerta != 'amarillo') return const SizedBox.shrink();
    final color = animal.alerta == 'rojo' ? AppColors.rojo : AppColors.amarillo;
    final texto = animal.alerta == 'rojo' ? 'Precaucion: ver detalle en Sobre el animal' : 'Aviso: ver detalle en Sobre el animal';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagenEspecie = fotoUrl == null
        ? imagenPorEspecie(animal.especieNombre)
        : null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.madera.withOpacity(0.15),
                backgroundImage: fotoUrl != null
                    ? NetworkImage(fotoUrl!)
                    : imagenEspecie != null
                    ? AssetImage(imagenEspecie)
                    : null,
                child: fotoUrl == null && imagenEspecie == null
                    ? Text(
                        animal.nombre.isNotEmpty ? animal.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 36, color: AppColors.madera, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              if (AuthHelper.puedeSubirFotos)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditarFoto,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.verde, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(animal.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _buildAlertaBanner(),
        ],
      ),
    );
  }
}
