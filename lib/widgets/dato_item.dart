import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DatoItem extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const DatoItem({super.key, required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.madera.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.madera),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.madera)),
                Text(
                  valor.isEmpty ? '-' : valor,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
