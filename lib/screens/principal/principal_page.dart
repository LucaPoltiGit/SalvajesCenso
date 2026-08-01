import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/actividad_item.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/nota_repository.dart';
import '../../repositories/foto_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/principal_stats_row.dart';
import '../../widgets/animal_quick_chip.dart';
import '../../widgets/actividad_tile.dart';
import '../../widgets/quick_access_card.dart';
import '../ficha/ficha_page.dart';
import '../sectores/sectores_page.dart';
import '../galeria/galeria_page.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();
  final _notaRepo = NotaRepository();
  final _fotoRepo = FotoRepository();

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
      final accesoRapido = await _animalRepo.listar(excluirEstado: 'fallecido', sort: 'nombre');

      final notasRecientes = await _notaRepo.listarRecientesCrudo(5);
      final fotosRecientes = await _fotoRepo.listarRecientesCrudo(5);
      final animalesRecientes = await _animalRepo.listarRecientesCrudo(5);

      final actividad = <ActividadItem>[
        ...animalesRecientes.map(ActividadItem.animalNuevo),
        ...notasRecientes.map(ActividadItem.nota),
        ...fotosRecientes.map(ActividadItem.foto),
      ];
      actividad.sort((a, b) => b.fecha.compareTo(a.fecha));

      final unaSemanaAtras = DateTime.now().subtract(const Duration(days: 7));
      final actividadReciente = actividad.where((a) => a.fecha.isAfter(unaSemanaAtras)).take(4).toList();

      setState(() {
        _totalAnimales = totalActivos;
        _totalCuidadoEspecial = cuidadoEspecial;
        _totalEnfermos = enfermos;
        _accesoRapido = accesoRapido;
        _actividad = actividadReciente;
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

          const Text('Acceso rapido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _accesoRapido.length,
              itemBuilder: (context, index) {
                final a = _accesoRapido[index];
                return AnimalQuickChip(
                  nombre: a.nombre,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FichaPage(animal: a)));
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Actividad reciente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton(
                onPressed: () {
                  // TODO: pantalla de actividad completa
                },
                child: const Text('Ver todo'),
              ),
            ],
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
