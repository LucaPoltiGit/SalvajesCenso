import 'package:pocketbase/pocketbase.dart';

class ActividadItem {
  final String tipo; // 'animal_nuevo', 'nota', 'foto'
  final String animalNombre;
  final String? detalle;
  final DateTime fecha;

  ActividadItem({
    required this.tipo,
    required this.animalNombre,
    this.detalle,
    required this.fecha,
  });

  factory ActividadItem.animalNuevo(RecordModel r) {
    return ActividadItem(
      tipo: 'animal_nuevo',
      animalNombre: r.data['nombre'] ?? '(sin nombre)',
      fecha: DateTime.parse(r.created),
    );
  }

  factory ActividadItem.nota(RecordModel r) {
    final animalExpand = r.expand['animal'];
    final nombre = (animalExpand != null && animalExpand.isNotEmpty)
        ? (animalExpand.first.data['nombre'] ?? 'Animal')
        : 'Animal';
    final contenido = r.data['contenido'] ?? '';
    final resumen = contenido.length > 60 ? '${contenido.substring(0, 60)}...' : contenido;
    return ActividadItem(
      tipo: 'nota',
      animalNombre: nombre,
      detalle: resumen,
      fecha: DateTime.parse(r.created),
    );
  }

  factory ActividadItem.foto(RecordModel r) {
    final animalExpand = r.expand['animal'];
    final nombre = (animalExpand != null && animalExpand.isNotEmpty)
        ? (animalExpand.first.data['nombre'] ?? 'Animal')
        : 'Animal';
    return ActividadItem(
      tipo: 'foto',
      animalNombre: nombre,
      fecha: DateTime.parse(r.created),
    );
  }
}
