import 'package:flutter/material.dart';

class GaleriaPage extends StatelessWidget {
  const GaleriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria de fotos')),
      body: const Center(child: Text('Galeria - proximamente')),
    );
  }
}
