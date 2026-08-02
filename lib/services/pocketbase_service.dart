import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PocketbaseService {
  PocketbaseService._internal();
  static final PocketbaseService instance = PocketbaseService._internal();

  late final PocketBase pb;
  bool _inicializado = false;

  Future<void> init() async {
    if (_inicializado) return;
    final prefs = await SharedPreferences.getInstance();

    final store = AsyncAuthStore(
      save: (String data) async => prefs.setString('pb_auth', data),
      initial: prefs.getString('pb_auth'),
      clear: () async => prefs.remove('pb_auth'),
    );

    pb = PocketBase(
      dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090',
      authStore: store,
    );

    _inicializado = true;
  }

  Future<bool> intentarRestaurarSesion() async {
    if (!pb.authStore.isValid) return false;
    try {
      await pb.collection('users').authRefresh();
      return true;
    } catch (_) {
      pb.authStore.clear();
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    await pb.collection('users').authWithPassword(email, password);
  }

  Future<void> loginComoVisitante() async {
    final email = dotenv.env['PB_VISITANTE_EMAIL'] ?? '';
    final password = dotenv.env['PB_VISITANTE_PASSWORD'] ?? '';
    await pb.collection('users').authWithPassword(email, password);
  }

  void logout() {
    pb.authStore.clear();
  }

  Future<void> ensureAuth() async {
    if (!pb.authStore.isValid) {
      throw Exception('No hay sesion activa. Inicia sesion nuevamente.');
    }
  }
}
