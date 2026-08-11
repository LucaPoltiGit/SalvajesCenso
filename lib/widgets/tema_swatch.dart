import 'package:flutter/material.dart';

class TemaSwatch extends StatelessWidget {
  final Color colorSuperior;
  final Color colorInferior;
  final String nombre;
  final bool seleccionado;
  final VoidCallback onTap;

  const TemaSwatch({
    super.key,
    required this.colorSuperior,
    required this.colorInferior,
    required this.nombre,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            padding: EdgeInsets.all(seleccionado ? 3 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: seleccionado ? Border.all(color: Colors.black87, width: 2.5) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CustomPaint(
                size: const Size(56, 56),
                painter: _DiagonalPainter(colorSuperior, colorInferior),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(nombre, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DiagonalPainter extends CustomPainter {
  final Color colorSuperior;
  final Color colorInferior;
  _DiagonalPainter(this.colorSuperior, this.colorInferior);

  @override
  void paint(Canvas canvas, Size size) {
    final pathSuperior = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathSuperior, Paint()..color = colorSuperior);

    final pathInferior = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(pathInferior, Paint()..color = colorInferior);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
