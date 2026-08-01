import 'package:flutter/material.dart';
import '../../models/actividad_item.dart';
import '../../repositories/actividad_repository.dart';
import '../../widgets/actividad_tile.dart';

class ActividadPage extends StatefulWidget {
  const ActividadPage({super.key});

  @override
  State<ActividadPage> createState() => _ActividadPageState();
}

class _ActividadPageState extends State<ActividadPage> {
  List<ActividadItem> _items = [];
  bool _cargando = true;
  String? _error;

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
      final items = await ActividadRepository.obtenerReciente(diasAtras: null, maxPorTipo: 50);
      setState(() {
        _items = items;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Actividad')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _items.isEmpty
                  ? const Center(child: Text('Sin actividad registrada'))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) => ActividadTile(item: _items[index]),
                      ),
                    ),
    );
  }
}
