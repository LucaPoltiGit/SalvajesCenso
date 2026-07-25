import 'package:pocketbase/pocketbase.dart';

class NotaHistorial {
  final String id;
  final DateTime fecha;
  final String contenido;
  final String tipoNombre;

  NotaHistorial({
    required this.id,
    required this.fecha,
    required this.contenido,
    required this.tipoNombre,
  });

  factory NotaHistorial.fromRecord(RecordModel record) {
    final tipoExpand = record.expand['tipo'];
    final tipoNombre = (tipoExpand != null && tipoExpand.isNotEmpty)
        ? (tipoExpand.first.data['nombre'] ?? 'general')
        : 'general';

    DateTime fecha;
    try {
      final fechaStr = record.data['fecha'] ?? record.created;
      fecha = DateTime.parse(fechaStr);
    } catch (_) {
      fecha = DateTime.now();
    }

    return NotaHistorial(
      id: record.id,
      fecha: fecha,
      contenido: record.data['contenido'] ?? '',
      tipoNombre: tipoNombre,
    );
  }
}
