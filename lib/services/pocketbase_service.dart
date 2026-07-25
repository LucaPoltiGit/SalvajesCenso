import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PocketbaseService {
  PocketbaseService._internal();
  static final PocketbaseService instance = PocketbaseService._internal();

  final pb = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090');

  Future<void> ensureAuth() async {
    if (pb.authStore.token.isNotEmpty) return;
    final email = dotenv.env['PB_TEST_EMAIL'] ?? '';
    final password = dotenv.env['PB_TEST_PASSWORD'] ?? '';
    await pb.collection('users').authWithPassword(email, password);
  }
}
