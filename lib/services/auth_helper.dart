import '../services/pocketbase_service.dart';

class AuthHelper {
  static String get rolActual {
    final model = PocketbaseService.instance.pb.authStore.model;
    if (model == null) return 'visita';
    return model.data['rol'] ?? 'visita';
  }

  static bool get esAdmin => rolActual == 'admin';

  static bool get puedeEditar => rolActual == 'admin' || rolActual == 'estandar';
  static bool get puedeBorrar => rolActual == 'admin';

  static bool get puedeVerNotas => rolActual == 'admin' || rolActual == 'estandar';
  static bool get puedeCrearNotas => rolActual == 'admin' || rolActual == 'estandar';
  static bool get puedeEditarNotas => rolActual == 'admin';
  static bool get puedeBorrarNotas => rolActual == 'admin';

  static bool get puedeSubirFotos => rolActual == 'admin' || rolActual == 'estandar';
  static bool get puedeBorrarFotos => rolActual == 'admin';
}
