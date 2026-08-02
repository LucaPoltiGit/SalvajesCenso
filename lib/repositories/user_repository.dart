import '../models/usuario.dart';
import '../services/pocketbase_service.dart';

/// Operaciones sobre el propio usuario logueado (perfil y credenciales) y
/// gestion de usuarios en general (solo admin).
class UserRepository {
  static Future<void> actualizarNombre(String nombre) async {
    final pb = PocketbaseService.instance.pb;
    final userId = pb.authStore.model?.id;
    if (userId == null) return;
    await pb.collection('users').update(userId, body: {'name': nombre});
  }

  static Future<void> cambiarPassword({
    required String actual,
    required String nueva,
    required String confirmar,
  }) async {
    final pb = PocketbaseService.instance.pb;
    final userId = pb.authStore.model?.id;
    if (userId == null) return;
    await pb.collection('users').update(userId, body: {
      'oldPassword': actual,
      'password': nueva,
      'passwordConfirm': confirmar,
    });
  }

  static Future<void> crear({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('users').create(body: {
      'name': nombre,
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'rol': rol,
      'bloqueado': false,
    });
  }

  static Future<List<Usuario>> listarTodos() async {
    final pb = PocketbaseService.instance.pb;
    final resultado = await pb.collection('users').getFullList(sort: 'name');
    return resultado.map(Usuario.fromRecord).toList();
  }

  static Future<void> cambiarRol(String userId, String nuevoRol) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('users').update(userId, body: {'rol': nuevoRol});
  }

  static Future<void> cambiarBloqueo(String userId, bool bloqueado) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('users').update(userId, body: {'bloqueado': bloqueado});
  }

  static Future<void> borrar(String userId) async {
    final pb = PocketbaseService.instance.pb;
    await pb.collection('users').delete(userId);
  }
}
