import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class Foto {
  final String id;
  final String animalId;
  final String? notaId;
  final String descripcion;
  final DateTime fecha;
  final String url;
  final bool esPerfil;

  Foto({
    required this.id,
    required this.animalId,
    this.notaId,
    required this.descripcion,
    required this.fecha,
    required this.url,
    this.esPerfil = false,
  });

  factory Foto.fromRecord(RecordModel record) {
    final filename = record.data['imagen'] ?? '';
    final baseUrl = PocketbaseService.instance.pb.baseUrl;
    final url = '$baseUrl/api/files/${record.collectionId}/${record.id}/$filename';

    DateTime fecha;
    try {
      fecha = DateTime.parse(record.data['fecha'] ?? record.created);
    } catch (_) {
      fecha = DateTime.now();
    }

    final notaRaw = record.data['nota'];
    final notaId = (notaRaw == null || notaRaw.toString().isEmpty) ? null : notaRaw.toString();

    return Foto(
      id: record.id,
      animalId: record.data['animal'] ?? '',
      notaId: notaId,
      descripcion: record.data['descripcion'] ?? '',
      fecha: fecha,
      url: url,
      esPerfil: record.data['es_perfil'] ?? false,
    );
  }
}
