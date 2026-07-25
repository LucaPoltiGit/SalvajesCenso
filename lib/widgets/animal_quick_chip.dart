import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimalQuickChip extends StatelessWidget {
  final String nombre;
  final VoidCallback onTap;

  const AnimalQuickChip({super.key, required this.nombre, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.madera.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          nombre,
          style: const TextStyle(color: AppColors.madera, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}
