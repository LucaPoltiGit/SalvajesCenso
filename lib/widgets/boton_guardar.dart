import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BotonGuardar extends StatelessWidget {
  final bool cargando;
  final String texto;
  final VoidCallback? onPressed;

  const BotonGuardar({
    super.key,
    required this.cargando,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(texto),
      ),
    );
  }
}
