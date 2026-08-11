import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const SantuarioApp());
}

class SantuarioApp extends StatefulWidget {
  const SantuarioApp({super.key});

  @override
  State<SantuarioApp> createState() => _SantuarioAppState();
}

class _SantuarioAppState extends State<SantuarioApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.instance.cargarTemaGuardado().then((_) {
      if (mounted) setState(() {});
    });
    ThemeService.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(ThemeService.instance.temaActualId),
      title: 'Santuario App',
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
