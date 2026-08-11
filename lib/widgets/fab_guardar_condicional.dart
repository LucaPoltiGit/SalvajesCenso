import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FabGuardarCondicional extends StatelessWidget {
  final bool visible;
  final bool cargando;
  final String texto;
  final VoidCallback onPressed;

  const FabGuardarCondicional({
    super.key,
    required this.visible,
    required this.cargando,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      onPressed: cargando ? null : onPressed,
      backgroundColor: AppColors.verde,
      foregroundColor: Colors.white,
      icon: cargando
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.check),
      label: Text(texto),
    );
  }
}
