import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme/app_colors.dart';
import 'animal_quick_chip.dart';

class AccesoRapidoRow extends StatefulWidget {
  final List<Animal> animales;
  final void Function(Animal animal) onTap;

  const AccesoRapidoRow({super.key, required this.animales, required this.onTap});

  @override
  State<AccesoRapidoRow> createState() => _AccesoRapidoRowState();
}

class _AccesoRapidoRowState extends State<AccesoRapidoRow> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scroll(double delta) {
    final destino = (_controller.offset + delta).clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(destino, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animales.isEmpty) {
      return const Text('Sin accesos rapidos todavia', style: TextStyle(fontSize: 13));
    }
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          IconButton(
            iconSize: 18,
            color: AppColors.madera,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _scroll(-160),
          ),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemCount: widget.animales.length,
              itemBuilder: (context, index) {
                final a = widget.animales[index];
                return AnimalQuickChip(nombre: a.nombre, onTap: () => widget.onTap(a));
              },
            ),
          ),
          IconButton(
            iconSize: 18,
            color: AppColors.madera,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _scroll(160),
          ),
        ],
      ),
    );
  }
}
