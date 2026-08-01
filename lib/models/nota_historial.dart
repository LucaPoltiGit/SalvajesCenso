import 'package:pocketbase/pocketbase.dart';

class NotaHistorial {
  final String id;
  final String animalId;
  final String tipoId;
  final DateTime fecha;
  final String contenido;
  final String tipoNombre;
  final String? animalNombre;

  NotaHistorial({
    required this.id,
    required this.animalId,
    required this.tipoId,
    required this.fecha,
    required this.contenido,
    required this.tipoNombre,
    this.animalNombre,
  });

  factory NotaHistorial.fromRecord(RecordModel record) {
    final tipoExpand = record.expand['tipo'];
    final tipoNombre = (tipoExpand != null && tipoExpand.isNotEmpty)
        ? (tipoExpand.first.data['nombre'] ?? 'general')
        : 'general';

    final animalExpand = record.expand['animal'];
    final animalNombre = (animalExpand != null && animalExpand.isNotEmpty) ? animalExpand.first.data['nombre'] as String? : null;

    DateTime fecha;
    try {
      final fechaStr = record.data['fecha'] ?? record.created;
      fecha = DateTime.parse(fechaStr);
    } catch (_) {
      fecha = DateTime.now();
    }

    return NotaHistorial(
      id: record.id,
      animalId: record.data['animal'] ?? '',
      tipoId: record.data['tipo'] ?? '',
      fecha: fecha,
      contenido: record.data['contenido'] ?? '',
      tipoNombre: tipoNombre,
      animalNombre: animalNombre,
    );
  }
}
