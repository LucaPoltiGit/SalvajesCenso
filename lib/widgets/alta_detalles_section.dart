import 'package:flutter/material.dart';
import '../utils/formatear_fecha.dart';

class AltaDetallesSection extends StatelessWidget {
  final TextEditingController edadCtrl;
  final TextEditingController dietaCtrl;
  final TextEditingController descripcionCtrl;
  final TextEditingController historiaCtrl;
  final DateTime? fechaLlegada;
  final VoidCallback onElegirFecha;
  final String? alerta;
  final void Function(String?) onAlertaCambiada;

  const AltaDetallesSection({
    super.key,
    required this.edadCtrl,
    required this.dietaCtrl,
    required this.descripcionCtrl,
    required this.historiaCtrl,
    required this.fechaLlegada,
    required this.onElegirFecha,
    required this.alerta,
    required this.onAlertaCambiada,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: edadCtrl,
          decoration: const InputDecoration(labelText: 'Edad', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: onElegirFecha,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Fecha de llegada', border: OutlineInputBorder()),
            child: Text(
              fechaLlegada == null ? 'Sin especificar' : formatearFecha(fechaLlegada!),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: dietaCtrl,
          decoration: const InputDecoration(labelText: 'Dieta', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descripcionCtrl,
          decoration: const InputDecoration(labelText: 'Descripcion', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: historiaCtrl,
          decoration: const InputDecoration(labelText: 'Historia de llegada', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Alerta (opcional)', border: OutlineInputBorder()),
          value: alerta,
          items: const [
            DropdownMenuItem(value: null, child: Text('Ninguna')),
            DropdownMenuItem(value: 'rojo', child: Text('Rojo')),
            DropdownMenuItem(value: 'amarillo', child: Text('Amarillo')),
          ],
          onChanged: onAlertaCambiada,
        ),
      ],
    );
  }
}
