import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/campania_ayuda.dart';
import '../services/pocketbase_service.dart';

class AyudaRepository {
  static Future<List<CampaniaAyuda>> listarActivas() async {
    final pb = PocketbaseService.instance.pb;
    final resultado = await pb.collection('ayuda').getFullList(
          filter: 'estado = true',
          sort: '-created',
        );
    return resultado.map(CampaniaAyuda.fromRecord).toList();
  }

  static Future<List<CampaniaAyuda>> listarTodas() async {
    final pb = PocketbaseService.instance.pb;
    final resultado = await pb.collection('ayuda').getFullList(sort: '-created');
    return resultado.map(CampaniaAyuda.fromRecord).toList();
  }

  static Future<void> crear({
    required String titulo,
    required String problema,
    double? montoNecesario,
    required String aliasDonacion,
    Uint8List? imagenBytes,
  }) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('ayuda').create(
      body: {
        'titulo': titulo,
        'problema': problema,
        if (montoNecesario != null) 'monto_necesario': montoNecesario,
        'monto_recaudado': 0,
        'alias_donacion': aliasDonacion,
        'estado': true,
      },
      files: imagenBytes != null
          ? [http.MultipartFile.fromBytes('imagen', imagenBytes, filename: 'ayuda_${DateTime.now().millisecondsSinceEpoch}.jpg')]
          : [],
    );
  }

  static Future<void> editar({
    required String id,
    required String titulo,
    required String problema,
    double? montoNecesario,
    required double montoRecaudado,
    required String aliasDonacion,
    required bool estado,
    Uint8List? imagenBytesNueva,
  }) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('ayuda').update(
      id,
      body: {
        'titulo': titulo,
        'problema': problema,
        if (montoNecesario != null) 'monto_necesario': montoNecesario,
        'monto_recaudado': montoRecaudado,
        'alias_donacion': aliasDonacion,
        'estado': estado,
      },
      files: imagenBytesNueva != null
          ? [http.MultipartFile.fromBytes('imagen', imagenBytesNueva, filename: 'ayuda_${DateTime.now().millisecondsSinceEpoch}.jpg')]
          : [],
    );
  }

  static Future<void> borrar(String id) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('ayuda').delete(id);
  }

  /// Descarga la imagen de una campania a un archivo temporal y abre el
  /// selector nativo para compartirla, evitando que la logica de red y
  /// filesystem viva directamente en el widget de la tarjeta.
  static Future<void> descargarYCompartirImagen(String imagenUrl, String tituloCampania) async {
    final respuesta = await http.get(Uri.parse(imagenUrl));
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$tituloCampania.jpg');
    await archivo.writeAsBytes(respuesta.bodyBytes);
    await SharePlus.instance.share(ShareParams(files: [XFile(archivo.path)], text: tituloCampania));
  }
}
