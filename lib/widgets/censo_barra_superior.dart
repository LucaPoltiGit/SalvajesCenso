import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CensoBarraSuperior extends StatefulWidget {
  final bool vistaGrid;
  final bool hayFiltrosActivos;
  final void Function(String busqueda) onBusquedaCambiada;
  final VoidCallback onToggleVista;
  final VoidCallback onAbrirFiltros;

  const CensoBarraSuperior({
    super.key,
    required this.vistaGrid,
    required this.hayFiltrosActivos,
    required this.onBusquedaCambiada,
    required this.onToggleVista,
    required this.onAbrirFiltros,
  });

  @override
  State<CensoBarraSuperior> createState() => _CensoBarraSuperiorState();
}

class _CensoBarraSuperiorState extends State<CensoBarraSuperior> {
  final _busquedaController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onBusquedaCambiada(String valor) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onBusquedaCambiada(valor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _onBusquedaCambiada,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: widget.onToggleVista,
            icon: Icon(widget.vistaGrid ? Icons.view_list : Icons.grid_view),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.verde.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                onPressed: widget.onAbrirFiltros,
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.verde.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (widget.hayFiltrosActivos)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.rojo, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
