import 'package:flutter/material.dart';
import '../../data/mapa_sectores_data.dart';
import '../../repositories/animal_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/filtro_censo_sheet.dart';
import '../../widgets/mapa_sectores.dart';
import '../censo/censo_filtrado_page.dart';

class SectoresPage extends StatefulWidget {
  const SectoresPage({super.key});

  @override
  State<SectoresPage> createState() => _SectoresPageState();
}

class _SectoresPageState extends State<SectoresPage> {
  final _animalRepo = AnimalRepository();

  Map<String, int> _conteos = {};
  bool _cargando = true;

  List<String> get _nombresTappables =>
      regionesMapa.where((r) => r.tappable).map((r) => r.nombre).toList();

  @override
  void initState() {
    super.initState();
    _cargarConteos();
  }

  Future<void> _cargarConteos() async {
    setState(() => _cargando = true);
    try {
      final conteos = await _animalRepo.contarPorSectores(_nombresTappables);
      setState(() {
        _conteos = conteos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  void _irAlCenso(String nombreSector) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CensoFiltradoPage(titulo: nombreSector, filtro: FiltrosCenso(sector: nombreSector)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarConteos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MapaSectores(onSectorTocado: _irAlCenso),
          const SizedBox(height: 20),
          const Text('Todos los sectores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._nombresTappables.map((nombre) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(nombre),
                  trailing: Text(
                    '${_conteos[nombre] ?? 0} animales',
                    style: TextStyle(color: AppColors.madera, fontSize: 12),
                  ),
                  onTap: () => _irAlCenso(nombre),
                )),
        ],
      ),
    );
  }
}
