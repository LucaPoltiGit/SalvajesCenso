import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class ContactoRepository {
  static Future<void> crear({String? nombre, String? telefono, String? email, String? mensaje}) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('contactos').create(body: {
      'nombre': nombre ?? '',
      'telefono': telefono ?? '',
      'email': email ?? '',
      'mensaje': mensaje ?? '',
    });
  }

  static Future<List<RecordModel>> listarTodos() async {
    final pb = PocketbaseService.instance.pb;
    return pb.collection('contactos').getFullList(sort: '-created');
  }
}
