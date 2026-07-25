import 'package:pocketbase/pocketbase.dart';

class Animal {
  final String id;
  final String nombre;
  final String especieNombre;
  final String estadoNombre;
  final String alerta;
  final String sectorNombre;

  Animal({
    required this.id,
    required this.nombre,
    required this.especieNombre,
    required this.estadoNombre,
    required this.alerta,
    required this.sectorNombre,
  });

  factory Animal.fromRecord(RecordModel record) {
    final sectorExpand = record.expand['sector'];
    final sectorNombre = (sectorExpand != null && sectorExpand.isNotEmpty)
        ? (sectorExpand.first.data['nombre'] ?? 'Sin sector')
        : 'Sin sector';

    final especieExpand = record.expand['especie'];
    final especieNombre = (especieExpand != null && especieExpand.isNotEmpty)
        ? (especieExpand.first.data['nombre'] ?? 'Sin especie')
        : 'Sin especie';

    final estadoExpand = record.expand['estado'];
    final estadoNombre = (estadoExpand != null && estadoExpand.isNotEmpty)
        ? (estadoExpand.first.data['nombre'] ?? 'bien')
        : 'bien';

    return Animal(
      id: record.id,
      nombre: record.data['nombre'] ?? '(sin nombre)',
      especieNombre: especieNombre,
      estadoNombre: estadoNombre,
      alerta: record.data['alerta'] ?? '',
      sectorNombre: sectorNombre,
    );
  }
}