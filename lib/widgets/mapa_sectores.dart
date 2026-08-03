import 'package:flutter/material.dart';
import 'mapa_sectores_painter.dart';
import '../data/mapa_sectores_data.dart';

class MapaSectores extends StatefulWidget {
  final void Function(String nombreSector) onSectorTocado;

  const MapaSectores({super.key, required this.onSectorTocado});

  @override
  State<MapaSectores> createState() => _MapaSectoresState();
}

class _MapaSectoresState extends State<MapaSectores> {
  final _painter = MapaSectoresPainter();

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: anchoPantalla < 500 ? anchoPantalla - 32 : 320,
          maxHeight: 500,
        ),
        child: AspectRatio(
          aspectRatio: disenoAncho / disenoAlto,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTapUp: (details) {
                  final nombre = _painter.detectarToque(details.localPosition, size);
                  if (nombre != null) widget.onSectorTocado(nombre);
                },
                child: CustomPaint(painter: _painter, size: size),
              );
            },
          ),
        ),
      ),
    );
  }
}
