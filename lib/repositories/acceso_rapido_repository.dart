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
      'oculto': false,
    });
  }

  static Future<void> quitar(String accesoRapidoId) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('accesos_rapidos').delete(accesoRapidoId);
  }

  /// Crea un registro con oculto:true para que un animal automatico
  /// (enfermo/cuidado especial) deje de aparecer en el acceso rapido de
  /// este usuario aunque siga cumpliendo esa condicion.
  static Future<void> ocultarAutomatico(String animalId) async {
    final pb = PocketbaseService.instance.pb;
    final userId = pb.authStore.model?.id;
    if (userId == null) return;
    await pb.collection('accesos_rapidos').create(body: {
      'users': userId,
      'animales': animalId,
      'oculto': true,
    });
  }

  static Future<void> mostrarAutomatico(String recordId) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('accesos_rapidos').delete(recordId);
  }
}
