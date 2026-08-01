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
    bool esPerfil = false,
  }) async {
    final pb = PocketbaseService.instance.pb;
    final comprimida = comprimir(bytes);

    if (esPerfil) {
      final actuales = await pb.collection('fotos').getFullList(
            filter: "animal = '$animalId' && es_perfil = true",
          );
      for (final f in actuales) {
        await pb.collection('fotos').update(f.id, body: {'es_perfil': false});
      }
    }

    await pb.collection('fotos').create(
      body: {
        'animal': animalId,
        if (notaId != null) 'nota': notaId,
        'descripcion': descripcion,
        'fecha': DateTime.now().toIso8601String(),
        'subida_por': pb.authStore.model?.id,
        'es_perfil': esPerfil,
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
