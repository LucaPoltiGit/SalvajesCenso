import 'package:flutter/material.dart';

enum TipoForma { rectangulo, poligono }

class RegionMapa {
  final String nombre;
  final TipoForma tipo;
  final Rect? rect;
  final Path Function()? construirPath;
  final Color colorFondo;
  final Color colorTexto;
  final bool tappable;
  final bool mostrarLabel;
  final bool textoVertical;
  final Offset? posicionLabel;

  RegionMapa({
    required this.nombre,
    required this.tipo,
    this.rect,
    this.construirPath,
    required this.colorFondo,
    required this.colorTexto,
    this.tappable = true,
    this.mostrarLabel = true,
    this.textoVertical = false,
    this.posicionLabel,
  });

  Path obtenerPath() {
    if (tipo == TipoForma.poligono && construirPath != null) {
      return construirPath!();
    }
    return Path()..addRRect(RRect.fromRectAndRadius(rect!, const Radius.circular(6)));
  }
}

const double disenoAncho = 250;
const double disenoAlto = 561;

Path _pathCabras() {
  final p = Path();
  p.moveTo(75.5, 345.5);
  p.lineTo(75.5, 374.5);
  p.lineTo(133.5, 374.5);
  p.lineTo(133.5, 544.5);
  p.lineTo(68.5, 544.5);
  p.lineTo(68.5, 424);
  p.lineTo(35.5, 424);
  p.lineTo(35.5, 345.5);
  p.close();
  return p;
}

Path _pathShaneYAldebaran() {
  final p = Path();
  p.moveTo(198.5, 0.5);
  p.lineTo(198.5, 284.5);
  p.lineTo(187, 284.5);
  p.lineTo(187, 252.5);
  p.lineTo(168, 252.5);
  p.lineTo(168, 284.5);
  p.lineTo(159.5, 284.5);
  p.lineTo(159.5, 252.5);
  p.lineTo(105.5, 252.5);
  p.lineTo(105.5, 284.5);
  p.lineTo(74.5, 284.5);
  p.lineTo(74.5, 212);
  p.lineTo(81.9961, 212);
  p.lineTo(82, 211.504);
  p.lineTo(83.4961, 0.5);
  p.close();
  return p;
}

Path _pathChanchos() {
  final p = Path();
  p.addRect(const Rect.fromLTWH(199.5, 0.5, 49, 284));
  p.addRect(const Rect.fromLTWH(141.5, 253.5, 17, 31));
  p.addRect(const Rect.fromLTWH(168.5, 253.5, 17, 31));
  return p;
}

final List<RegionMapa> regionesMapa = [
  RegionMapa(
    nombre: 'Falu',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(134.5, 459.5, 114, 85),
    colorFondo: const Color(0xFFF0997B),
    colorTexto: const Color(0xFF4A1B0C),
  ),
  RegionMapa(
    nombre: 'Barry',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(134.5, 292.5, 114, 166),
    colorFondo: const Color(0xFF97C459),
    colorTexto: const Color(0xFF173404),
  ),
  RegionMapa(
    nombre: 'Cabras',
    tipo: TipoForma.poligono,
    construirPath: _pathCabras,
    colorFondo: const Color(0xFFB5D4F4),
    colorTexto: const Color(0xFF042C53),
    posicionLabel: const Offset(102, 470),
  ),
  RegionMapa(
    nombre: 'Ovejas',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(35.5, 285.5, 98, 59),
    colorFondo: const Color(0xFFF4C0D1),
    colorTexto: const Color(0xFF4B1528),
  ),
  RegionMapa(
    nombre: 'Cleo',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(116.5, 345.5, 17, 29),
    colorFondo: const Color(0xFFCECBF6),
    colorTexto: const Color(0xFF26215C),
    mostrarLabel: false,
  ),
  RegionMapa(
    nombre: 'Shane y Aldebaran',
    tipo: TipoForma.poligono,
    construirPath: _pathShaneYAldebaran,
    colorFondo: const Color(0xFFEF9F27),
    colorTexto: const Color(0xFF412402),
  ),
  RegionMapa(
    nombre: 'Guardia',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 285.5, 35, 138),
    colorFondo: const Color(0xFF5DCAA5),
    colorTexto: const Color(0xFF04342C),
    textoVertical: true,
  ),
  RegionMapa(
    nombre: 'Geriatrico',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 424.5, 68, 44),
    colorFondo: const Color(0xFFFAC775),
    colorTexto: const Color(0xFF412402),
  ),
  RegionMapa(
    nombre: 'Balrog',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 469.5, 68, 91),
    colorFondo: const Color(0xFFF7C1C1),
    colorTexto: const Color(0xFF501313),
  ),
  RegionMapa(
    nombre: 'Laguna',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 74.5, 81.5, 137),
    colorFondo: const Color(0xFF85B7EB),
    colorTexto: const Color(0xFF042C53),
  ),
  RegionMapa(
    nombre: 'Apolo y Florita',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 0.5, 81.5, 74),
    colorFondo: const Color(0xFFC0DD97),
    colorTexto: const Color(0xFF173404),
  ),
  RegionMapa(
    nombre: 'Chanchos',
    tipo: TipoForma.poligono,
    construirPath: _pathChanchos,
    colorFondo: const Color(0xFFAFA9EC),
    colorTexto: const Color(0xFF26215C),
    textoVertical: true,
    posicionLabel: const Offset(224, 142.5),
  ),
  RegionMapa(
    nombre: 'Galpon',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(105.5, 253.5, 35, 31),
    colorFondo: const Color(0xFFD3D1C7),
    colorTexto: const Color(0xFF2C2C2A),
    tappable: false,
    mostrarLabel: false,
  ),
  RegionMapa(
    nombre: 'Granja',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(0.5, 212.5, 74, 72),
    colorFondo: const Color(0xFFD3D1C7),
    colorTexto: const Color(0xFF2C2C2A),
    tappable: false,
  ),
  RegionMapa(
    nombre: 'Casa voluntario',
    tipo: TipoForma.rectangulo,
    rect: const Rect.fromLTWH(76.5, 345.5, 39, 29),
    colorFondo: const Color(0xFFD3D1C7),
    colorTexto: const Color(0xFF2C2C2A),
    tappable: false,
    mostrarLabel: false,
  ),
];
