import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuickAccessCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const QuickAccessCard({super.key, required this.icono, required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.madera.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icono, color: AppColors.madera, size: 26),
              const SizedBox(height: 8),
              Text(titulo, style: TextStyle(color: AppColors.madera, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
