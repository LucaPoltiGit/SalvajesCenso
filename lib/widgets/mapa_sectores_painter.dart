import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../data/mapa_sectores_data.dart';

class MapaSectoresPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final escala = _calcularEscala(size);
    final offset = _calcularOffset(size, escala);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(escala);

    for (final region in regionesMapa) {
      final path = region.obtenerPath();
      final paint = Paint()..color = region.colorFondo;
      canvas.drawPath(path, paint);

      if (region.mostrarLabel) {
        final bounds = path.getBounds();
        final centro = region.posicionLabel ?? bounds.center;

        final textPainter = TextPainter(
          text: TextSpan(
            text: region.nombre,
            style: TextStyle(
              color: region.colorTexto,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        if (region.textoVertical) {
          textPainter.layout();
          canvas.save();
          canvas.translate(centro.dx, centro.dy);
          canvas.rotate(-math.pi / 2);
          textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
          canvas.restore();
        } else {
          textPainter.layout(maxWidth: bounds.width - 4);
          textPainter.paint(
            canvas,
            Offset(centro.dx - textPainter.width / 2, centro.dy - textPainter.height / 2),
          );
        }
      }
    }

    canvas.restore();
  }

  double _calcularEscala(Size size) {
    final escalaX = size.width / disenoAncho;
    final escalaY = size.height / disenoAlto;
    return escalaX < escalaY ? escalaX : escalaY;
  }

  Offset _calcularOffset(Size size, double escala) {
    final anchoEscalado = disenoAncho * escala;
    final altoEscalado = disenoAlto * escala;
    return Offset((size.width - anchoEscalado) / 2, (size.height - altoEscalado) / 2);
  }

  String? detectarToque(Offset posicionLocal, Size size) {
    final escala = _calcularEscala(size);
    final offset = _calcularOffset(size, escala);
    final puntoDiseno = Offset(
      (posicionLocal.dx - offset.dx) / escala,
      (posicionLocal.dy - offset.dy) / escala,
    );

    for (final region in regionesMapa.reversed) {
      if (!region.tappable) continue;
      if (region.obtenerPath().contains(puntoDiseno)) {
        return region.nombre;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
