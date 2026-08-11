import 'package:flutter/material.dart';

class DefinicionTema {
  final String id;
  final String nombre;
  final Color verde;
  final Color madera;
  final Color fondo;
  final Color swatchSuperior;
  final Color swatchInferior;

  const DefinicionTema({
    required this.id,
    required this.nombre,
    required this.verde,
    required this.madera,
    required this.fondo,
    required this.swatchSuperior,
    required this.swatchInferior,
  });
}

const List<DefinicionTema> temasDisponibles = [
  DefinicionTema(
    id: 'verde',
    nombre: 'Verde',
    verde: Color(0xFF33502F),
    madera: Color(0xFF8A6A4B),
    fondo: Color(0xFFFBF9F4),
    swatchSuperior: Color(0xFF33502F),
    swatchInferior: Color(0xFF8A6A4B),
  ),
  DefinicionTema(
    id: 'blancoYNegro',
    nombre: 'Blanco y negro',
    verde: Color(0xFF212121),
    madera: Color(0xFF757575),
    fondo: Color(0xFFF5F5F5),
    swatchSuperior: Color(0xFF212121),
    swatchInferior: Color(0xFFF5F5F5),
  ),
];

// Para agregar un tema nuevo en el futuro (ej modo oscuro), solo hay que
// sumar una entrada nueva a esta lista - no hace falta tocar ThemeService
// ni el selector de Ajustes, ambos se adaptan solos a la cantidad de temas.
