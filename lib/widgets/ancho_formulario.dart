import 'package:flutter/material.dart';

class AnchoFormulario extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AnchoFormulario({super.key, required this.child, this.maxWidth = 480});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
