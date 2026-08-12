import 'package:flutter/material.dart';

class DefinicionTema {
  final String id;
  final String nombre;
  final Color verde;
  final Color madera;
  final Color fondo;
  final Color textoPrincipal;
  final Color swatchSuperior;
  final Color swatchInferior;
  final Brightness brillo;

  const DefinicionTema({
    required this.id,
    required this.nombre,
    required this.verde,
    required this.madera,
    required this.fondo,
    required this.textoPrincipal,
    required this.swatchSuperior,
    required this.swatchInferior,
    this.brillo = Brightness.light,
  });
}

const List<DefinicionTema> temasDisponibles = [
  DefinicionTema(
    id: 'verde',
    nombre: 'Verde',
    verde: Color(0xFF33502F),
    madera: Color(0xFF8A6A4B),
    fondo: Color(0xFFFBF9F4),
    textoPrincipal: Color(0xFF212121),
    swatchSuperior: Color(0xFF33502F),
    swatchInferior: Color(0xFF8A6A4B),
  ),
  DefinicionTema(
    id: 'blancoYNegro',
    nombre: 'Blanco y negro',
    verde: Color(0xFF212121),
    madera: Color(0xFF757575),
    fondo: Color(0xFFF5F5F5),
    textoPrincipal: Color(0xFF212121),
    swatchSuperior: Color(0xFF212121),
    swatchInferior: Color(0xFFF5F5F5),
  ),
  DefinicionTema(
    id: 'oscuro',
    nombre: 'Oscuro',
    verde: Color(0xFF6FBF73),
    madera: Color(0xFFBCAAA4),
    fondo: Color(0xFF121212),
    textoPrincipal: Color(0xFFECECEC),
    swatchSuperior: Color(0xFF121212),
    swatchInferior: Color(0xFF6FBF73),
    brillo: Brightness.dark,
  ),
];

// Para agregar un tema nuevo en el futuro (ej modo oscuro), solo hay que
// sumar una entrada nueva a esta lista - no hace falta tocar ThemeService
// ni el selector de Ajustes, ambos se adaptan solos a la cantidad de temas.
