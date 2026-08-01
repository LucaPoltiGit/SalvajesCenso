import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import 'item_simple.dart';

/// Repositorio generico para las colecciones de categoria que comparten la
/// misma forma (id + nombre): especies, estados y tipos_nota.
class CategoriaRepository {
  final String coleccion;
  CategoriaRepository(this.coleccion);

  final PocketBase _pb = PocketbaseService.instance.pb;

  Future<List<ItemSimple>> listar() async {
    final resultado = await _pb.collection(coleccion).getFullList(sort: 'nombre');
    return resultado.map(ItemSimple.fromRecord).toList();
  }

  Future<ItemSimple> crear(String nombre) async {
    final creado = await _pb.collection(coleccion).create(body: {'nombre': nombre});
    return ItemSimple.fromRecord(creado);
  }

  Future<ItemSimple> editar(String id, String nombre) async {
    final editado = await _pb.collection(coleccion).update(id, body: {'nombre': nombre});
    return ItemSimple.fromRecord(editado);
  }

  Future<void> borrar(String id) async {
    await _pb.collection(coleccion).delete(id);
  }
}
