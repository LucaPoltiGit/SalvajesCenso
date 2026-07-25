import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/actividad_item.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/stat_card.dart';
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

  bool _cargando = true;
  String? _error;

  int _totalAnimales = 0;
  int _totalCuidadoEspecial = 0;
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
      final pb = _pbService.pb;

      final totalResult = await pb.collection('animales').getList(
            page: 1,
            perPage: 1,
            filter: "estado.nombre != 'fallecido'",
          );

      final cuidadoResult = await pb.collection('animales').getList(
            page: 1,
            perPage: 1,
            filter: "estado.nombre = 'cuidado_especial'",
          );

      final nombresResult = await pb.collection('animales').getFullList(
            sort: 'nombre',
            filter: "estado.nombre != 'fallecido'",
          );

      final notasResult = await pb.collection('notas_historial').getList(
            page: 1,
            perPage: 5,
            sort: '-created',
            expand: 'animal',
          );

      final fotosResult = await pb.collection('fotos').getList(
            page: 1,
            perPage: 5,
            sort: '-created',
            expand: 'animal',
          );

      final animalesRecientes = await pb.collection('animales').getList(
            page: 1,
            perPage: 5,
            sort: '-created',
          );

      final actividad = <ActividadItem>[
        ...animalesRecientes.items.map(ActividadItem.animalNuevo),
        ...notasResult.items.map(ActividadItem.nota),
        ...fotosResult.items.map(ActividadItem.foto),
      ];
      actividad.sort((a, b) => b.fecha.compareTo(a.fecha));

      final unaSemanaAtras = DateTime.now().subtract(const Duration(days: 7));
      final actividadReciente = actividad.where((a) => a.fecha.isAfter(unaSemanaAtras)).take(4).toList();

      setState(() {
        _totalAnimales = totalResult.totalItems;
        _totalCuidadoEspecial = cuidadoResult.totalItems;
        _accesoRapido = nombresResult.map(Animal.fromRecord).toList();
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
          Row(
            children: [
              Expanded(child: StatCard(numero: '$_totalAnimales', label: 'Total de animales')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(numero: '$_totalCuidadoEspecial', label: 'Cuidado especial')),
            ],
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
