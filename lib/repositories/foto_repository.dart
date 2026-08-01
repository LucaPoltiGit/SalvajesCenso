import 'dart:typed_data';
import 'package:pocketbase/pocketbase.dart';
import '../models/foto.dart';
import '../services/auth_helper.dart';
import '../services/foto_service.dart';
import '../services/pocketbase_service.dart';

class FotoRepository {
  final PocketBase _pb = PocketbaseService.instance.pb;

  Future<List<Foto>> listarGeneralesDeAnimal(String animalId) async {
    final resultado = await _pb.collection('fotos').getFullList(
          filter: "animal = '$animalId' && nota = ''",
          sort: '-created',
        );
    return resultado.map(Foto.fromRecord).toList();
  }

  Future<List<Foto>> listarDeNotasDeAnimal(String animalId) async {
    final resultado = await _pb.collection('fotos').getFullList(
          filter: "animal = '$animalId' && nota != ''",
          sort: '-created',
        );
    return resultado.map(Foto.fromRecord).toList();
  }

  /// La foto de perfil de cada animal (si tiene una marcada), usada por
  /// el censo para armar la foto de portada de cada tarjeta.
  Future<List<Foto>> listarGeneralesGlobal() async {
    final resultado = await _pb.collection('fotos').getFullList(
          filter: "nota = '' && es_perfil = true",
          sort: '-created',
        );
    return resultado.map(Foto.fromRecord).toList();
  }

  /// Aplica la regla de permisos ya existente: rol visita solo ve fotos
  /// generales (sin nota asociada).
  Future<List<Foto>> listarParaGaleria({String busqueda = ''}) async {
    final condiciones = <String>[];
    if (AuthHelper.rolActual == 'visita') condiciones.add("nota = ''");
    if (busqueda.isNotEmpty) condiciones.add("animal.nombre ~ '$busqueda'");
    final filtro = condiciones.isEmpty ? null : condiciones.join(' && ');
    final resultado = await _pb.collection('fotos').getFullList(filter: filtro, sort: '-created');
    return resultado.map(Foto.fromRecord).toList();
  }

  /// Solo para alimentar ActividadItem.foto, que necesita la fecha de
  /// creacion cruda del registro (dato que Foto no modela).
  Future<List<RecordModel>> listarRecientesCrudo(int cantidad) async {
    final resultado = await _pb.collection('fotos').getList(
          page: 1,
          perPage: cantidad,
          sort: '-created',
          expand: 'animal',
        );
    return resultado.items;
  }

  Future<void> subir({
    required String animalId,
    String? notaId,
    required List<int> bytes,
    String descripcion = '',
    bool esPerfil = false,
  }) async {
    await FotoService.subirFoto(
      animalId: animalId,
      notaId: notaId,
      bytes: Uint8List.fromList(bytes),
      descripcion: descripcion,
      esPerfil: esPerfil,
    );
  }

  Future<void> borrar(String id) async {
    await _pb.collection('fotos').delete(id);
  }
}
