import 'package:flutter/material.dart';
import '../../theme/app_strings.dart';
import 'ayuda_page.dart';

/// Envuelve AyudaPage con su propio Scaffold para accederla desde el menu
/// hamburguesa (admin/estandar), ya que AyudaPage en si no trae Scaffold
/// porque tambien vive como pestana dentro de AppShell para el rol visita.
class AyudaStandalonePage extends StatelessWidget {
  const AyudaStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.ayuda)),
      body: const AyudaPage(),
    );
  }
}
