import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme/app_colors.dart';
import '../utils/imagen_por_especie.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  final String? fotoUrl;

  const AnimalCard({super.key, required this.animal, required this.onTap, this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    final imagenEspecie = fotoUrl == null ? imagenPorEspecie(animal.especieNombre) : null;
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: fotoUrl == null ? AppColors.madera.withOpacity(0.15) : null,
            image: fotoUrl != null
                ? DecorationImage(image: NetworkImage(fotoUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: Stack(
            children: [
              if (fotoUrl == null)
                Positioned(
                  top: 14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: imagenEspecie != null
                          ? Image.asset(imagenEspecie, fit: BoxFit.contain)
                          : Icon(Icons.pets, color: AppColors.madera, size: 40),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        animal.nombre,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        animal.sectorNombre,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (animal.alerta == 'rojo' || animal.alerta == 'amarillo')
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: animal.alerta == 'rojo' ? AppColors.rojo : AppColors.amarillo,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
