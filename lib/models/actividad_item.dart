import 'package:pocketbase/pocketbase.dart';

class ActividadItem {
  final String id;
  final String tipo;
  final String animalId;
  final String animalNombre;
  final String? detalle;
  final String? quien;
  final DateTime fecha;

  ActividadItem({
    required this.id,
    required this.tipo,
    required this.animalId,
    required this.animalNombre,
    this.detalle,
    this.quien,
    required this.fecha,
  });

  static String? _nombreDeUsuario(RecordModel r, String campoRelacion) {
    final expand = r.expand[campoRelacion];
    if (expand != null && expand.isNotEmpty) {
      final nombre = expand.first.data['name'] as String?;
      if (nombre != null && nombre.trim().isNotEmpty) return nombre;
      return expand.first.data['email'] as String?;
    }
    return null;
  }

  factory ActividadItem.animalNuevo(RecordModel r) {
    return ActividadItem(
      id: r.id,
      tipo: 'animal_nuevo',
      animalId: r.id,
      animalNombre: r.data['nombre'] ?? '(sin nombre)',
      quien: _nombreDeUsuario(r, 'creado_por'),
      fecha: DateTime.parse(r.created),
    );
  }

  factory ActividadItem.nota(RecordModel r) {
    final animalExpand = r.expand['animal'];
    final animalNombre = (animalExpand != null && animalExpand.isNotEmpty)
        ? (animalExpand.first.data['nombre'] ?? 'Animal')
        : 'Animal';
    final contenido = r.data['contenido'] ?? '';
    final resumen = contenido.length > 60 ? '${contenido.substring(0, 60)}...' : contenido;
    return ActividadItem(
      id: r.id,
      tipo: 'nota',
      animalId: r.data['animal'] ?? '',
      animalNombre: animalNombre,
      detalle: resumen,
      quien: _nombreDeUsuario(r, 'autor'),
      fecha: DateTime.parse(r.created),
    );
  }

  factory ActividadItem.foto(RecordModel r) {
    final animalExpand = r.expand['animal'];
    final animalNombre = (animalExpand != null && animalExpand.isNotEmpty)
        ? (animalExpand.first.data['nombre'] ?? 'Animal')
        : 'Animal';
    return ActividadItem(
      id: r.id,
      tipo: 'foto',
      animalId: r.data['animal'] ?? '',
      animalNombre: animalNombre,
      quien: _nombreDeUsuario(r, 'subida_por'),
      fecha: DateTime.parse(r.created),
    );
  }
}
