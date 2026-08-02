import '../services/pocketbase_service.dart';

/// Operaciones sobre el propio usuario logueado (perfil y credenciales).
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
}
