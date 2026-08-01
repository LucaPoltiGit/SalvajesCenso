import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/formatear_fecha.dart';

class ActividadFiltrosBar extends StatelessWidget {
  final List<String> quienes;
  final String? quienSeleccionado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final void Function(String? quien) onQuienSeleccionado;
  final void Function(bool esDesde) onElegirFecha;
  final VoidCallback onLimpiar;

  const ActividadFiltrosBar({
    super.key,
    required this.quienes,
    required this.quienSeleccionado,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.onQuienSeleccionado,
    required this.onElegirFecha,
    required this.onLimpiar,
  });

  bool get _tieneFiltrosActivos => quienSeleccionado != null || fechaDesde != null || fechaHasta != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...quienes.map((q) {
              final seleccionado = quienSeleccionado == q;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(q),
                  selected: seleccionado,
                  onSelected: (v) => onQuienSeleccionado(v ? q : null),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 14),
                label: Text(fechaDesde == null ? 'Desde' : formatearFechaCorta(fechaDesde!)),
                onPressed: () => onElegirFecha(true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 14),
                label: Text(fechaHasta == null ? 'Hasta' : formatearFechaCorta(fechaHasta!)),
                onPressed: () => onElegirFecha(false),
              ),
            ),
            if (_tieneFiltrosActivos)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  avatar: const Icon(Icons.close, size: 14, color: AppColors.rojo),
                  label: const Text('Limpiar', style: TextStyle(color: AppColors.rojo)),
                  onPressed: onLimpiar,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
