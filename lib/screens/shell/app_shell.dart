import 'package:flutter/material.dart';
import '../principal/principal_page.dart';
import '../censo/censo_page.dart';
import '../notas/notas_page.dart';
import '../sectores/sectores_page.dart';
import '../ayuda/ayuda_page.dart';
import '../ayuda/ayuda_standalone_page.dart';
import '../contacto/contacto_form_page.dart';
import '../contacto/contactos_page.dart';
import '../galeria/galeria_page.dart';
import '../categorias/categorias_page.dart';
import '../ajustes/ajustes_page.dart';
import '../alta/alta_page.dart';
import '../login/login_page.dart';
import '../usuarios/usuarios_page.dart';
import '../../services/pocketbase_service.dart';
import '../../services/auth_helper.dart';

final GlobalKey<_AppShellState> appShellKey = GlobalKey<_AppShellState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indiceActual = 0;

  int _censoRefreshKey = 0;
  int _principalRefreshKey = 0;

  List<String> get _titulos {
    if (AuthHelper.esVisita) {
      return ['Censo', 'Ayuda', 'Sectores'];
    }
    final base = ['Principal', 'Censo'];
    if (AuthHelper.puedeVerNotas) base.add('Notas');
    base.add('Sectores');
    return base;
  }

  List<Widget> get _paginas {
    if (AuthHelper.esVisita) {
      return [
        CensoPage(key: ValueKey(_censoRefreshKey)),
        const AyudaPage(),
        const SectoresPage(),
      ];
    }
    final base = <Widget>[
      PrincipalPage(key: ValueKey(_principalRefreshKey)),
      CensoPage(key: ValueKey(_censoRefreshKey)),
    ];
    if (AuthHelper.puedeVerNotas) base.add(const NotasPage());
    base.add(const SectoresPage());
    return base;
  }

  void irASectores() {
    final indice = _paginas.indexWhere((p) => p is SectoresPage);
    if (indice != -1) {
      setState(() {
        if (indice == 0 && _indiceActual != 0) _principalRefreshKey++;
        _indiceActual = indice;
      });
    }
  }

  List<NavigationDestination> get _destinos {
    if (AuthHelper.esVisita) {
      return const [
        NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Censo'),
        NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Ayuda'),
        NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Sectores'),
      ];
    }
    final base = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Principal'),
      const NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Censo'),
    ];
    if (AuthHelper.puedeVerNotas) {
      base.add(const NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Notas'));
    }
    base.add(const NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Sectores'));
    return base;
  }

  @override
  Widget build(BuildContext context) {
    if (_indiceActual >= _paginas.length) _indiceActual = 0;

    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indiceActual])),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _indiceActual,
        children: _paginas,
      ),
      floatingActionButton: AuthHelper.esVisita
          ? null
          : FloatingActionButton(
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
        onDestinationSelected: (i) {
          setState(() {
            if (i == 0 && _indiceActual != 0) _principalRefreshKey++;
            _indiceActual = i;
          });
        },
        destinations: _destinos,
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
            if (!AuthHelper.esVisita)
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Ayuda'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AyudaStandalonePage()));
                },
              ),
            if (AuthHelper.esVisita)
              ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: const Text('Quiero ayudar'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactoFormPage()));
                },
              ),
            if (AuthHelper.puedeVerContactos)
              ListTile(
                leading: const Icon(Icons.contact_mail_outlined),
                title: const Text('Contactos recibidos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactosPage()));
                },
              ),
            if (AuthHelper.esAdmin)
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Gestionar categorias'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriasPage()));
                },
              ),
            if (AuthHelper.esAdmin)
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Gestionar usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuariosPage()));
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
                Navigator.pop(context);
                PocketbaseService.instance.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
