import 'package:flutter/material.dart';

class SeccionHeader extends StatelessWidget {
  final String titulo;
  final Widget? accion;

  const SeccionHeader({super.key, required this.titulo, this.accion});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        if (accion != null) accion!,
      ],
    );
  }
}
