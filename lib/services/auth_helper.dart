import '../services/pocketbase_service.dart';

class AuthHelper {
  static String get rolActual {
    final model = PocketbaseService.instance.pb.authStore.model;
    if (model == null) return 'visita';
    return model.data['rol'] ?? 'visita';
  }

  static bool get puedeEditar => rolActual == 'admin' || rolActual == 'estandar';
  static bool get puedeBorrar => rolActual == 'admin';
}
