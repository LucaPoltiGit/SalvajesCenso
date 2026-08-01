import 'package:pocketbase/pocketbase.dart';

/// Representa un registro simple de id + nombre, la forma comun de las
/// colecciones de categoria (especies, estados, tipos_nota, sectores).
class ItemSimple {
  final String id;
  final String nombre;

  const ItemSimple({required this.id, required this.nombre});

  factory ItemSimple.fromRecord(RecordModel record) {
    return ItemSimple(id: record.id, nombre: record.data['nombre'] ?? '');
  }
}
