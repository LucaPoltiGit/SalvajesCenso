import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'buscador_debounced.dart';

class CensoBarraSuperior extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: BuscadorDebounced(
              hint: 'Buscar por nombre',
              onCambio: onBusquedaCambiada,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onToggleVista,
            icon: Icon(vistaGrid ? Icons.view_list : Icons.grid_view),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.verde.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                onPressed: onAbrirFiltros,
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.verde.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (hayFiltrosActivos)
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
