import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'pocketbase_service.dart';

class FotoService {
  static Uint8List comprimir(Uint8List bytesOriginales) {
    final imagen = img.decodeImage(bytesOriginales);
    if (imagen == null) return bytesOriginales;
    final ancho = imagen.width > 1200 ? 1200 : imagen.width;
    final redimensionada = img.copyResize(imagen, width: ancho);
    return Uint8List.fromList(img.encodeJpg(redimensionada, quality: 80));
  }

  static Future<void> subirFoto({
    required String animalId,
    String? notaId,
    required Uint8List bytes,
    String descripcion = '',
  }) async {
    final pb = PocketbaseService.instance.pb;
    final comprimida = comprimir(bytes);
    await pb.collection('fotos').create(
      body: {
        'animal': animalId,
        if (notaId != null) 'nota': notaId,
        'descripcion': descripcion,
        'fecha': DateTime.now().toIso8601String(),
        'subida_por': pb.authStore.model?.id,
      },
      files: [
        http.MultipartFile.fromBytes(
          'imagen',
          comprimida,
          filename: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ],
    );
  }
}
