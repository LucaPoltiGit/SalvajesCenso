import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import 'item_simple.dart';

class SectorRepository {
  final PocketBase _pb = PocketbaseService.instance.pb;

  Future<List<ItemSimple>> listar() async {
    final resultado = await _pb.collection('sectores').getFullList(sort: 'nombre');
    return resultado.map(ItemSimple.fromRecord).toList();
  }
}
