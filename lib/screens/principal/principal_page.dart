import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/actividad_item.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/actividad_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/principal_stats_row.dart';
import '../../widgets/acceso_rapido_row.dart';
import '../../widgets/actividad_tile.dart';
import '../../widgets/quick_access_card.dart';
import '../../widgets/seccion_header.dart';
import '../acceso_rapido/acceso_rapido_manager_page.dart';
import '../ficha/ficha_page.dart';
import '../sectores/sectores_page.dart';
import '../galeria/galeria_page.dart';
import '../actividad/actividad_page.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();

  bool _cargando = true;
  String? _error;

  int _totalAnimales = 0;
  int _totalCuidadoEspecial = 0;
  int _totalEnfermos = 0;
  List<Animal> _accesoRapido = [];
  List<ActividadItem> _actividad = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();

      final totalActivos = await _animalRepo.contar(estadoDistinto: 'fallecido');
      final cuidadoEspecial = await _animalRepo.contar(estadoIgual: 'cuidado_especial');
      final enfermos = await _animalRepo.contar(estadoIgual: 'enfermo');
      final accesoRapido = await _animalRepo.listarAccesoRapido();

      final actividad = await ActividadRepository.obtenerReciente(diasAtras: 7, maxPorTipo: 5);

      setState(() {
        _totalAnimales = totalActivos;
        _totalCuidadoEspecial = cuidadoEspecial;
        _totalEnfermos = enfermos;
        _accesoRapido = accesoRapido;
        _actividad = actividad;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PrincipalStatsRow(
            totalAnimales: _totalAnimales,
            totalEnfermos: _totalEnfermos,
            totalCuidadoEspecial: _totalCuidadoEspecial,
          ),
          const SizedBox(height: 24),

          SeccionHeader(
            titulo: 'Acceso rapido',
            accion: IconButton(
              iconSize: 18,
              icon: const Icon(Icons.tune, color: AppColors.madera),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AccesoRapidoManagerPage()));
                _cargarDatos();
              },
            ),
          ),
          const SizedBox(height: 10),
          AccesoRapidoRow(
            animales: _accesoRapido,
            onTap: (a) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FichaPage(animal: a)));
            },
          ),
          const SizedBox(height: 24),

          SeccionHeader(
            titulo: 'Actividad reciente',
            accion: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ActividadPage()));
              },
              child: const Text('Ver todo'),
            ),
          ),
          if (_actividad.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Sin actividad en la ultima semana', style: TextStyle(fontSize: 13)),
            )
          else
            ..._actividad.map((item) => ActividadTile(item: item)),
          const SizedBox(height: 24),

          Row(
            children: [
              QuickAccessCard(
                icono: Icons.map_outlined,
                titulo: 'Ver sectores',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SectoresPage()));
                },
              ),
              const SizedBox(width: 12),
              QuickAccessCard(
                icono: Icons.photo_library_outlined,
                titulo: 'Galeria de fotos',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriaPage()));
                },
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
