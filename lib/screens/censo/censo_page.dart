import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/animal_tile.dart';
import '../ficha/ficha_page.dart';

class CensoPage extends StatefulWidget {
  const CensoPage({super.key});

  @override
  State<CensoPage> createState() => _CensoPageState();
}

class _CensoPageState extends State<CensoPage> {
  final _pbService = PocketbaseService.instance;
  List<Animal> _animales = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarAnimales();
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
          );
      setState(() {
        _animales = resultado.map(Animal.fromRecord).toList();
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
    if (_animales.isEmpty) return const Center(child: Text('Todavia no hay animales cargados'));

    return RefreshIndicator(
      onRefresh: _cargarAnimales,
      child: ListView.separated(
        itemCount: _animales.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final a = _animales[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FichaPage(animal: a)),
              );
            },
            child: AnimalTile(animal: a),
          );
        },
      ),
    );
  }
}
