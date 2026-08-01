import 'package:flutter/material.dart';
import '../../models/nota_historial.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/item_simple.dart';
import '../../repositories/nota_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/buscador_debounced.dart';
import '../../widgets/nota_historial_card.dart';
import '../../widgets/notas_filtros_bar.dart';
import '../ficha/ficha_page.dart';

class NotasPage extends StatefulWidget {
  const NotasPage({super.key});

  @override
  State<NotasPage> createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _pbService = PocketbaseService.instance;
  final _notaRepo = NotaRepository();
  final _animalRepo = AnimalRepository();
  final _tipoRepo = CategoriaRepository('tipos_nota');
  int _busquedaResetKey = 0;

  List<NotaHistorial> _notas = [];
  Map<String, String> _animalNombrePorNotaId = {};
  bool _cargando = true;
  String? _error;

  String _busquedaAnimal = '';
  String? _tipoFiltro;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  List<ItemSimple> _tipos = [];

  @override
  void initState() {
    super.initState();
    _cargarTipos();
    _cargarNotas();
  }

  Future<void> _cargarTipos() async {
    await _pbService.ensureAuth();
    final tipos = await _tipoRepo.listar();
    setState(() => _tipos = tipos);
  }

  void _onBusquedaCambiada(String valor) {
    _busquedaAnimal = valor;
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();
      final notas = await _notaRepo.listarConFiltros(
        busquedaAnimal: _busquedaAnimal.isEmpty ? null : _busquedaAnimal,
        tipo: _tipoFiltro,
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      );

      final nombres = <String, String>{};
      for (final n in notas) {
        nombres[n.id] = n.animalNombre ?? 'Animal';
      }

      setState(() {
        _notas = notas;
        _animalNombrePorNotaId = nombres;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _abrirFichaDesdeNota(NotaHistorial nota) async {
    try {
      final animal = await _animalRepo.obtenerPorId(nota.animalId);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FichaPage(animal: animal)));
      }
    } catch (_) {}
  }

  Future<void> _elegirFecha(bool esDesde) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        if (esDesde) {
          _fechaDesde = fecha;
        } else {
          _fechaHasta = fecha;
        }
      });
      _cargarNotas();
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _tipoFiltro = null;
      _fechaDesde = null;
      _fechaHasta = null;
      _busquedaAnimal = '';
      _busquedaResetKey++;
    });
    _cargarNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: BuscadorDebounced(
            key: ValueKey(_busquedaResetKey),
            hint: 'Buscar por nombre de animal',
            onCambio: _onBusquedaCambiada,
          ),
        ),
        NotasFiltrosBar(
          tipos: _tipos,
          tipoSeleccionado: _tipoFiltro,
          fechaDesde: _fechaDesde,
          fechaHasta: _fechaHasta,
          onTipoSeleccionado: (tipo) {
            setState(() => _tipoFiltro = tipo);
            _cargarNotas();
          },
          onElegirFecha: _elegirFecha,
          onLimpiar: _limpiarFiltros,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _notas.isEmpty
                      ? const Center(child: Text('No se encontraron notas'))
                      : RefreshIndicator(
                          onRefresh: _cargarNotas,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notas.length,
                            itemBuilder: (context, index) {
                              final n = _notas[index];
                              return GestureDetector(
                                onTap: () => _abrirFichaDesdeNota(n),
                                child: NotaHistorialCard(
                                  nota: n,
                                  animalNombre: _animalNombrePorNotaId[n.id],
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
