import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/nota_historial.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/item_simple.dart';
import '../../repositories/nota_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/nota_historial_card.dart';
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
  final _busquedaController = TextEditingController();
  Timer? _debounce;

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

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _cargarTipos() async {
    await _pbService.ensureAuth();
    final tipos = await _tipoRepo.listar();
    setState(() => _tipos = tipos);
  }

  void _onBusquedaCambiada(String valor) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _busquedaAnimal = valor;
      _cargarNotas();
    });
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
      _busquedaController.clear();
      _busquedaAnimal = '';
    });
    _cargarNotas();
  }

  bool get _tieneFiltrosActivos => _tipoFiltro != null || _fechaDesde != null || _fechaHasta != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre de animal',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: _onBusquedaCambiada,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._tipos.map((t) {
                  final nombre = t.nombre;
                  final seleccionado = _tipoFiltro == nombre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(nombre),
                      selected: seleccionado,
                      onSelected: (v) {
                        setState(() => _tipoFiltro = v ? nombre : null);
                        _cargarNotas();
                      },
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(_fechaDesde == null ? 'Desde' : '${_fechaDesde!.day}/${_fechaDesde!.month}'),
                    onPressed: () => _elegirFecha(true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: const Icon(Icons.calendar_today, size: 14),
                    label: Text(_fechaHasta == null ? 'Hasta' : '${_fechaHasta!.day}/${_fechaHasta!.month}'),
                    onPressed: () => _elegirFecha(false),
                  ),
                ),
                if (_tieneFiltrosActivos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.close, size: 14, color: AppColors.rojo),
                      label: const Text('Limpiar', style: TextStyle(color: AppColors.rojo)),
                      onPressed: _limpiarFiltros,
                    ),
                  ),
              ],
            ),
          ),
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
