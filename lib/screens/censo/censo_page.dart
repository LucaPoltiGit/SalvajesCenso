import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/foto_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/animal_card.dart';
import '../../widgets/animal_tile.dart';
import '../../widgets/censo_barra_superior.dart';
import '../../widgets/filtro_censo_sheet.dart';
import '../ficha/ficha_page.dart';

class CensoPage extends StatefulWidget {
  final FiltrosCenso? filtroInicial;
  const CensoPage({super.key, this.filtroInicial});

  @override
  State<CensoPage> createState() => _CensoPageState();
}

class _CensoPageState extends State<CensoPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();
  final _fotoRepo = FotoRepository();

  List<Animal> _animales = [];
  Map<String, String> _fotosPorAnimal = {};
  bool _cargando = true;
  Object? _error;
  late FiltrosCenso _filtros;
  String _busqueda = '';
  bool _vistaGrid = true;

  @override
  void initState() {
    super.initState();
    _filtros = widget.filtroInicial ?? const FiltrosCenso();
    _cargarAnimales();
  }

  void _onBusquedaCambiada(String valor) {
    _busqueda = valor;
    _cargarAnimales();
  }

  Future<void> _cargarAnimales() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();
      final animales = await _animalRepo.listar(
        nombre: _busqueda.isEmpty ? null : _busqueda,
        especie: _filtros.especie,
        estado: _filtros.estado,
        sector: _filtros.sector,
        alerta: _filtros.alerta,
      );

      final fotosGenerales = await _fotoRepo.listarGeneralesGlobal();
      final mapaFotos = <String, String>{};
      for (final f in fotosGenerales) {
        if (mapaFotos.containsKey(f.animalId)) continue;
        mapaFotos[f.animalId] = f.url;
      }

      setState(() {
        _animales = animales;
        _fotosPorAnimal = mapaFotos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
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
        CensoBarraSuperior(
          vistaGrid: _vistaGrid,
          hayFiltrosActivos: _filtros.tieneFiltros,
          onBusquedaCambiada: _onBusquedaCambiada,
          onToggleVista: () => setState(() => _vistaGrid = !_vistaGrid),
          onAbrirFiltros: _abrirFiltros,
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(mensajeErrorAmigable(_error!)))
              : _animales.isEmpty
              ? const Center(child: Text(AppStrings.sinAnimalesEncontrados))
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
            final resultado = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => FichaPage(animal: a)),
            );
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
            final resultado = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => FichaPage(animal: a)),
            );
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
