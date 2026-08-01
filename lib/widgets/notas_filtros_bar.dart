import 'package:flutter/material.dart';
import '../repositories/item_simple.dart';
import '../theme/app_colors.dart';
import '../utils/formatear_fecha.dart';

class NotasFiltrosBar extends StatelessWidget {
  final List<ItemSimple> tipos;
  final String? tipoSeleccionado;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final void Function(String? tipo) onTipoSeleccionado;
  final void Function(bool esDesde) onElegirFecha;
  final VoidCallback onLimpiar;

  const NotasFiltrosBar({
    super.key,
    required this.tipos,
    required this.tipoSeleccionado,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.onTipoSeleccionado,
    required this.onElegirFecha,
    required this.onLimpiar,
  });

  bool get _tieneFiltrosActivos => tipoSeleccionado != null || fechaDesde != null || fechaHasta != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...tipos.map((t) {
              final nombre = t.nombre;
              final seleccionado = tipoSeleccionado == nombre;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(nombre),
                  selected: seleccionado,
                  onSelected: (v) => onTipoSeleccionado(v ? nombre : null),
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
