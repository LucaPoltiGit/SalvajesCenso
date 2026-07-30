import 'package:flutter/material.dart';
import '../principal/principal_page.dart';
import '../censo/censo_page.dart';
import '../historial/historial_page.dart';
import '../sectores/sectores_page.dart';
import '../galeria/galeria_page.dart';
import '../categorias/categorias_page.dart';
import '../ajustes/ajustes_page.dart';
import '../alta/alta_page.dart';
import '../../services/pocketbase_service.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indiceActual = 0;

  final _titulos = ['Principal', 'Censo', 'Historial', 'Sectores'];

  int _censoRefreshKey = 0;

  List<Widget> get _paginas => [
        const PrincipalPage(),
        CensoPage(key: ValueKey(_censoRefreshKey)),
        const HistorialPage(),
        const SectoresPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indiceActual])),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _indiceActual,
        children: _paginas,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AltaPage()),
          );
          if (resultado == true) {
            setState(() => _censoRefreshKey++);
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (i) => setState(() => _indiceActual = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Principal'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Censo'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Sectores'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Santuario App')),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria de fotos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriaPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Gestionar categorias'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriasPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AjustesPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesion'),
              onTap: () {
                PocketbaseService.instance.pb.authStore.clear();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
