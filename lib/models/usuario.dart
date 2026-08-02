import 'package:pocketbase/pocketbase.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool bloqueado;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.bloqueado,
  });

  factory Usuario.fromRecord(RecordModel record) {
    return Usuario(
      id: record.id,
      nombre: record.data['name'] ?? '',
      email: record.data['email'] ?? '',
      rol: record.data['rol'] ?? 'visita',
      bloqueado: record.data['bloqueado'] == true,
    );
  }
}
