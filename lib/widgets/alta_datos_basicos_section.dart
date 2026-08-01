import 'package:flutter/material.dart';
import '../repositories/item_simple.dart';

class AltaDatosBasicosSection extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final String? Function(String?) validadorNombre;
  final List<ItemSimple> especies;
  final List<ItemSimple> sectores;
  final List<ItemSimple> estados;
  final String? especieId;
  final String? sectorId;
  final String? estadoId;
  final void Function(String?) onEspecieCambiada;
  final void Function(String?) onSectorCambiado;
  final void Function(String?) onEstadoCambiado;

  const AltaDatosBasicosSection({
    super.key,
    required this.nombreCtrl,
    required this.validadorNombre,
    required this.especies,
    required this.sectores,
    required this.estados,
    required this.especieId,
    required this.sectorId,
    required this.estadoId,
    required this.onEspecieCambiada,
    required this.onSectorCambiado,
    required this.onEstadoCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          validator: validadorNombre,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Especie', border: OutlineInputBorder()),
          value: especieId,
          items: especies.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(),
          onChanged: onEspecieCambiada,
          validator: (v) => v == null ? 'Elegi una especie' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Sector', border: OutlineInputBorder()),
          value: sectorId,
          items: sectores.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(),
          onChanged: onSectorCambiado,
          validator: (v) => v == null ? 'Elegi un sector' : null,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
          value: estadoId,
          items: estados.map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre))).toList(),
          onChanged: onEstadoCambiado,
          validator: (v) => v == null ? 'Elegi un estado' : null,
        ),
      ],
    );
  }
}
