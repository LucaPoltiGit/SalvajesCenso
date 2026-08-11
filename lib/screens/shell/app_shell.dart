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
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_strings.dart';

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
      return [AppStrings.censo, AppStrings.ayuda, AppStrings.sectores];
    }
    final base = [AppStrings.principal, AppStrings.censo];
    if (AuthHelper.puedeVerNotas) base.add(AppStrings.notas);
    base.add(AppStrings.sectores);
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
        NavigationDestination(icon: Icon(AppIcons.censo), selectedIcon: Icon(AppIcons.censoActivo), label: AppStrings.censo),
        NavigationDestination(icon: Icon(AppIcons.ayuda), selectedIcon: Icon(AppIcons.ayudaActivo), label: AppStrings.ayuda),
        NavigationDestination(icon: Icon(AppIcons.sectores), selectedIcon: Icon(AppIcons.sectoresActivo), label: AppStrings.sectores),
      ];
    }
    final base = <NavigationDestination>[
      const NavigationDestination(icon: Icon(AppIcons.principal), selectedIcon: Icon(AppIcons.principalActivo), label: AppStrings.principal),
      const NavigationDestination(icon: Icon(AppIcons.censo), selectedIcon: Icon(AppIcons.censoActivo), label: AppStrings.censo),
    ];
    if (AuthHelper.puedeVerNotas) {
      base.add(const NavigationDestination(icon: Icon(AppIcons.notas), selectedIcon: Icon(AppIcons.notasActivo), label: AppStrings.notas));
    }
    base.add(const NavigationDestination(icon: Icon(AppIcons.sectores), selectedIcon: Icon(AppIcons.sectoresActivo), label: AppStrings.sectores));
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
            DrawerHeader(
              child: Center(
                child: SizedBox(
                  height: 100,
                  child: Image.asset(
                    'assets/images/logo 2.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.pets,
                      size: 64,
                      color: AppColors.madera,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(AppIcons.menuGaleria),
              title: const Text(AppStrings.menuGaleria),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriaPage()));
              },
            ),
            if (!AuthHelper.esVisita)
              ListTile(
                leading: const Icon(AppIcons.menuAyuda),
                title: const Text(AppStrings.menuAyuda),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AyudaStandalonePage()));
                },
              ),
            if (AuthHelper.esVisita)
              ListTile(
                leading: const Icon(AppIcons.menuQuieroAyudar),
                title: const Text(AppStrings.menuQuieroAyudar),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactoFormPage()));
                },
              ),
            if (AuthHelper.puedeVerContactos)
              ListTile(
                leading: const Icon(AppIcons.menuContactos),
                title: const Text(AppStrings.menuContactosRecibidos),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactosPage()));
                },
              ),
            if (AuthHelper.esAdmin)
              ListTile(
                leading: const Icon(AppIcons.menuCategorias),
                title: const Text(AppStrings.menuGestionarCategorias),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriasPage()));
                },
              ),
            if (AuthHelper.esAdmin)
              ListTile(
                leading: const Icon(AppIcons.menuUsuarios),
                title: const Text(AppStrings.menuGestionarUsuarios),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuariosPage()));
                },
              ),
            ListTile(
              leading: const Icon(AppIcons.menuAjustes),
              title: const Text(AppStrings.menuAjustes),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AjustesPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(AppIcons.menuCerrarSesion),
              title: const Text(AppStrings.menuCerrarSesion),
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
