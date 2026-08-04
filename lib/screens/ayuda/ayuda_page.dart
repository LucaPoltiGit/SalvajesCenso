import 'package:flutter/material.dart';
import '../../models/campania_ayuda.dart';
import '../../repositories/ayuda_repository.dart';
import '../../services/auth_helper.dart';
import '../../theme/app_colors.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/campania_ayuda_card.dart';
import 'ayuda_form_page.dart';

class AyudaPage extends StatefulWidget {
  const AyudaPage({super.key});

  @override
  State<AyudaPage> createState() => _AyudaPageState();
}

class _AyudaPageState extends State<AyudaPage> {
  List<CampaniaAyuda> _campanias = [];
  bool _cargando = true;
  Object? _error;

  bool get _puedeGestionar => AuthHelper.puedeGestionarAyuda;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final campanias = _puedeGestionar
          ? await AyudaRepository.listarTodas()
          : await AyudaRepository.listarActivas();
      setState(() {
        _campanias = campanias;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _cargando = false;
      });
    }
  }

  Future<void> _crear() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AyudaFormPage()),
    );
    if (resultado == true) _cargar();
  }

  Future<void> _editar(CampaniaAyuda campania) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AyudaFormPage(campaniaExistente: campania),
      ),
    );
    if (resultado == true) _cargar();
  }

  Future<void> _borrar(CampaniaAyuda campania) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar campania'),
        content: Text(
          'Seguro que queres borrar "${campania.titulo}"? Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Borrar',
              style: TextStyle(color: AppColors.rojo),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await AyudaRepository.borrar(campania.id);
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contenido;
    if (_cargando) {
      contenido = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      contenido = Center(child: Text(mensajeErrorAmigable(_error!)));
    } else if (_campanias.isEmpty) {
      contenido = const Center(child: Text('No hay campanias para mostrar'));
    } else {
      contenido = RefreshIndicator(
        onRefresh: _cargar,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _campanias.length,
          itemBuilder: (context, index) {
            final c = _campanias[index];
            return CampaniaAyudaCard(
              campania: c,
              onEditar: _puedeGestionar ? () => _editar(c) : null,
              onBorrar: _puedeGestionar ? () => _borrar(c) : null,
            );
          },
        ),
      );
    }

    if (!_puedeGestionar) return contenido;

    return Stack(
      children: [
        contenido,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _crear,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
