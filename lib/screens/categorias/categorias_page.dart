import 'package:flutter/material.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/item_simple.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/aviso_dialog.dart';
import '../../widgets/categoria_form_dialog.dart';
import '../../widgets/categoria_list_tile.dart';
import '../../widgets/confirmar_borrado_dialog.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage>
    with SingleTickerProviderStateMixin {
  static const _colecciones = ['especies', 'estados', 'tipos_nota'];

  late final TabController _tabController;
  final Map<String, CategoriaRepository> _repos = {
    for (final c in _colecciones) c: CategoriaRepository(c),
  };
  final Map<String, List<ItemSimple>> _items = {
    for (final c in _colecciones) c: [],
  };
  final Map<String, bool> _cargando = {for (final c in _colecciones) c: true};
  final Map<String, Object?> _errores = {for (final c in _colecciones) c: null};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _colecciones.length, vsync: this);
    for (final coleccion in _colecciones) {
      _cargar(coleccion);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar(String coleccion) async {
    setState(() {
      _cargando[coleccion] = true;
      _errores[coleccion] = null;
    });
    try {
      final items = await _repos[coleccion]!.listar();
      setState(() {
        _items[coleccion] = items;
        _cargando[coleccion] = false;
      });
    } catch (e) {
      setState(() {
        _errores[coleccion] = e;
        _cargando[coleccion] = false;
      });
    }
  }

  Future<void> _crear(String coleccion) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => const CategoriaFormDialog(titulo: 'Nueva categoria'),
    );
    if (nombre == null) return;
    try {
      await _repos[coleccion]!.crear(nombre);
      _cargar(coleccion);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
    }
  }

  Future<void> _editar(String coleccion, ItemSimple item) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (_) => CategoriaFormDialog(
        titulo: 'Editar categoria',
        valorInicial: item.nombre,
      ),
    );
    if (nombre == null) return;
    try {
      await _repos[coleccion]!.editar(item.id, nombre);
      _cargar(coleccion);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
    }
  }

  Future<void> _borrar(String coleccion, ItemSimple item) async {
    final usos = await _repos[coleccion]!.contarUso(item.id);
    if (usos > 0) {
      final esTipoNota = coleccion == 'tipos_nota';
      final palabra = esTipoNota
          ? (usos == 1 ? 'nota' : 'notas')
          : (usos == 1 ? 'animal' : 'animales');
      if (mounted) {
        await mostrarAviso(
          context,
          titulo: 'Categoria en uso',
          mensaje:
              'No se puede borrar. Hay $usos $palabra usando esta categoria. '
              'Cambia esos registros a otra categoria antes de borrarla.',
        );
      }
      return;
    }

    final confirmado = await confirmarBorrado(
      context,
      titulo: 'Borrar categoria',
      mensaje:
          'Seguro que queres borrar "${item.nombre}"? Esta accion no se puede deshacer.',
    );
    if (!confirmado) return;
    try {
      await _repos[coleccion]!.borrar(item.id);
      _cargar(coleccion);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
    }
  }

  Widget _buildLista(String coleccion) {
    if (_cargando[coleccion] == true) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _errores[coleccion];
    if (error != null) {
      return Center(child: Text(mensajeErrorAmigable(error)));
    }
    final items = _items[coleccion]!;
    if (items.isEmpty) {
      return const Center(child: Text('Sin categorias cargadas todavia'));
    }
    return RefreshIndicator(
      onRefresh: () => _cargar(coleccion),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return CategoriaListTile(
            nombre: item.nombre,
            onEditar: () => _editar(coleccion, item),
            onBorrar: () => _borrar(coleccion, item),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.gestionarCategorias),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Especies'),
            Tab(text: 'Estados'),
            Tab(text: 'Tipos de nota'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crear(_colecciones[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _colecciones.map(_buildLista).toList(),
      ),
    );
  }
}
