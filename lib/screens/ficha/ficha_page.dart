import 'package:flutter/material.dart';
import '../../models/animal.dart';

class FichaPage extends StatelessWidget {
  final Animal animal;
  const FichaPage({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(animal.nombre)),
      body: Center(child: Text('Ficha completa de ${animal.nombre} - proximamente')),
    );
  }
}
