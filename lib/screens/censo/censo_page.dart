import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animal_card.dart';
import '../../widgets/animal_tile.dart';
import '../../widgets/filtro_censo_sheet.dart';
import '../ficha/ficha_page.dart';

class CensoPage extends StatefulWidget {
  const CensoPage({super.key});

  @override
  State<CensoPage> createState() => _CensoPageState();
}

class _CensoPageState extends State<CensoPage> {
  final _pbService = PocketbaseService.instance;
  final _busquedaController = TextEditingController();
  Timer? _debounce;

  List<Animal> _animales = [];
  Map<String, String> _fotosPorAnimal = {};
  bool _cargando = true;
  String? _error;
  FiltrosCenso _filtros = const FiltrosCenso();
  String _busqueda = '';
  bool _vistaGrid = true;

  @override
  void initState() {
    super.initState();
    _cargarAnimales();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onBusquedaCambiada(String valor) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _busqueda = valor;
      _cargarAnimales();
    });
  }

  String? _armarFiltroPocketBase() {
    final condiciones = <String>[];
    if (_busqueda.isNotEmpty) {
      condiciones.add("nombre ~ '$_busqueda'");
    }
    if (_filtros.especie != null) {
      condiciones.add("especie.nombre = '${_filtros.especie}'");
    }
    if (_filtros.estado != null) {
      condiciones.add("estado.nombre = '${_filtros.estado}'");
    }
    if (_filtros.sector != null) {
      condiciones.add("sector.nombre = '${_filtros.sector}'");
    }
    if (_filtros.alerta != null) {
      condiciones.add("alerta = '${_filtros.alerta}'");
    }
    if (condiciones.isEmpty) return null;
    return condiciones.join(' && ');
  }

  Future<void> _cargarAnimales() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();
      final resultado = await _pbService.pb.collection('animales').getFullList(
            expand: 'sector,especie,estado',
            sort: 'nombre',
            filter: _armarFiltroPocketBase(),
          );

      final fotosResult = await _pbService.pb.collection('fotos').getFullList(
            filter: "nota = ''",
            sort: '-created',
          );
      final mapaFotos = <String, String>{};
      for (final f in fotosResult) {
        final animalId = f.data['animal'] as String?;
        if (animalId == null) continue;
        if (mapaFotos.containsKey(animalId)) continue;
        final filename = f.data['imagen'] ?? '';
        final baseUrl = _pbService.pb.baseUrl;
        mapaFotos[animalId] = '$baseUrl/api/files/${f.collectionId}/${f.id}/$filename';
      }

      setState(() {
        _animales = resultado.map(Animal.fromRecord).toList();
        _fotosPorAnimal = mapaFotos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _abrirFiltros() async {
    final resultado = await showModalBottomSheet<FiltrosCenso>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FiltroCensoSheet(filtrosActuales: _filtros),
    );
    if (resultado != null) {
      setState(() => _filtros = resultado);
      _cargarAnimales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: _onBusquedaCambiada,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _vistaGrid = !_vistaGrid),
                icon: Icon(_vistaGrid ? Icons.view_list : Icons.grid_view),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.verde.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: _abrirFiltros,
                    icon: const Icon(Icons.tune),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.verde.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_filtros.tieneFiltros)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.rojo, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _animales.isEmpty
                      ? const Center(child: Text('No se encontraron animales'))
                      : RefreshIndicator(
                          onRefresh: _cargarAnimales,
                          child: _vistaGrid ? _buildGrid() : _buildLista(),
                        ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _animales.length,
      itemBuilder: (context, index) {
        final a = _animales[index];
        return AnimalCard(
          animal: a,
          fotoUrl: _fotosPorAnimal[a.id],
          onTap: () async {
            final resultado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FichaPage(animal: a)));
            if (resultado == true) {
              _cargarAnimales();
            }
          },
        );
      },
    );
  }

  Widget _buildLista() {
    return ListView.separated(
      itemCount: _animales.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final a = _animales[index];
        return GestureDetector(
          onTap: () async {
            final resultado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FichaPage(animal: a)));
            if (resultado == true) {
              _cargarAnimales();
            }
          },
          child: AnimalTile(animal: a, fotoUrl: _fotosPorAnimal[a.id]),
        );
      },
    );
  }
}
