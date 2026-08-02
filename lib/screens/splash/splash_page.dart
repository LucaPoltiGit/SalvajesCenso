import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../login/login_page.dart';
import '../shell/app_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      await PocketbaseService.instance.init();
      final sesionRestaurada = await PocketbaseService.instance.intentarRestaurarSesion();
      if (!mounted) return;
      if (sesionRestaurada) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppShell()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error de conexion: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        _iniciar();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: AppColors.verde),
      ),
    );
  }
}
