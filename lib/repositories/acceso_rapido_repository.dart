import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';

class AccesoRapidoRepository {
  static Future<List<RecordModel>> listarCrudo() async {
    final pb = PocketbaseService.instance.pb;
    final userId = pb.authStore.model?.id;
    if (userId == null) return [];
    return pb.collection('accesos_rapidos').getFullList(
          filter: "users = '$userId'",
          expand: 'animales',
        );
  }

  static Future<void> agregar(String animalId) async {
    final pb = PocketbaseService.instance.pb;
    final userId = pb.authStore.model?.id;
    if (userId == null) return;
    await pb.collection('accesos_rapidos').create(body: {
      'users': userId,
      'animales': animalId,
    });
  }

  static Future<void> quitar(String accesoRapidoId) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('accesos_rapidos').delete(accesoRapidoId);
  }
}
