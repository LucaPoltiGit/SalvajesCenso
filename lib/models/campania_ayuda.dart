import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class CampaniaAyuda {
  final String id;
  final String titulo;
  final String problema;
  final double? montoNecesario;
  final double montoRecaudado;
  final String aliasDonacion;
  final bool estado;
  final String? imagenUrl;
  final String? imagenFilename;

  CampaniaAyuda({
    required this.id,
    required this.titulo,
    required this.problema,
    this.montoNecesario,
    required this.montoRecaudado,
    required this.aliasDonacion,
    required this.estado,
    this.imagenUrl,
    this.imagenFilename,
  });

  double? get progreso {
    if (montoNecesario == null || montoNecesario == 0) return null;
    final p = montoRecaudado / montoNecesario!;
    return p > 1 ? 1 : p;
  }

  factory CampaniaAyuda.fromRecord(RecordModel record) {
    final filename = record.data['imagen'] as String?;
    String? url;
    if (filename != null && filename.isNotEmpty) {
      final baseUrl = PocketbaseService.instance.pb.baseUrl;
      url = '$baseUrl/api/files/${record.collectionId}/${record.id}/$filename';
    }

    return CampaniaAyuda(
      id: record.id,
      titulo: record.data['titulo'] ?? '',
      problema: record.data['problema'] ?? '',
      montoNecesario: (record.data['monto_necesario'] as num?)?.toDouble(),
      montoRecaudado: (record.data['monto_recaudado'] as num?)?.toDouble() ?? 0,
      aliasDonacion: record.data['alias_donacion'] ?? '',
      estado: record.data['estado'] == true,
      imagenUrl: url,
      imagenFilename: filename,
    );
  }
}
