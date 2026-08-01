import 'package:flutter/material.dart';
import '../models/animal.dart';

class FichaTabSobre extends StatelessWidget {
  final Animal animal;
  const FichaTabSobre({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(animal.descripcion.isEmpty ? 'Sin descripcion cargada' : animal.descripcion, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 24),
        const Text('Historia de llegada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(animal.historiaLlegada.isEmpty ? 'Sin historia cargada' : animal.historiaLlegada, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 40),
      ],
    );
  }
}
