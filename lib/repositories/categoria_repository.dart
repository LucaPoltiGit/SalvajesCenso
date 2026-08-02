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
    final creado = await _pb.collection(coleccion).create(body: {
      'nombre': nombre,
      'creado_por': _pb.authStore.model?.id,
    });
    return ItemSimple.fromRecord(creado);
  }

  Future<ItemSimple> editar(String id, String nombre) async {
    final editado = await _pb.collection(coleccion).update(id, body: {'nombre': nombre});
    return ItemSimple.fromRecord(editado);
  }

  Future<void> borrar(String id) async {
    await _pb.collection(coleccion).delete(id);
  }

  /// Cuenta cuantos registros de otra coleccion usan esta categoria, para
  /// bloquear el borrado si esta en uso. especies/estados los usa
  /// 'animales'; tipos_nota lo usa 'notas_historial'.
  Future<int> contarUso(String categoriaId) async {
    String coleccionQueUsa;
    String campoQueUsa;

    switch (coleccion) {
      case 'especies':
        coleccionQueUsa = 'animales';
        campoQueUsa = 'especie';
        break;
      case 'estados':
        coleccionQueUsa = 'animales';
        campoQueUsa = 'estado';
        break;
      case 'tipos_nota':
        coleccionQueUsa = 'notas_historial';
        campoQueUsa = 'tipo';
        break;
      default:
        return 0;
    }

    final resultado = await _pb.collection(coleccionQueUsa).getList(
          page: 1,
          perPage: 1,
          filter: "$campoQueUsa = '$categoriaId'",
        );
    return resultado.totalItems;
  }
}
