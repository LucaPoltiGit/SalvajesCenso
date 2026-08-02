import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../repositories/acceso_rapido_repository.dart';
import '../../repositories/animal_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../widgets/acceso_rapido_list_tile.dart';
import '../../widgets/buscador_debounced.dart';

class AccesoRapidoManagerPage extends StatefulWidget {
  const AccesoRapidoManagerPage({super.key});

  @override
  State<AccesoRapidoManagerPage> createState() => _AccesoRapidoManagerPageState();
}

class _AccesoRapidoManagerPageState extends State<AccesoRapidoManagerPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();

  List<Animal> _animales = [];
  Map<String, String> _favoritosMap = {};
  Map<String, String> _ocultosMap = {};
  Set<String> _idsAutomaticos = {};
  bool _cargando = true;
  String? _error;
  String _busqueda = '';

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
      await _pbService.ensureAuth();

      final animales = await _animalRepo.listar(
        nombre: _busqueda.isEmpty ? null : _busqueda,
        excluirEstado: 'fallecido',
      );
      final registrosUsuario = await AccesoRapidoRepository.listarCrudo();
      final idsAutomaticos = await _animalRepo.listarIdsAutomaticosAccesoRapido();

      final favoritosMapa = <String, String>{};
      final ocultosMapa = <String, String>{};
      for (final r in registrosUsuario) {
        final animalId = r.data['animales'] as String?;
        if (animalId == null) continue;
        final oculto = r.data['oculto'] == true;
        if (oculto) {
          ocultosMapa[animalId] = r.id;
        } else {
          favoritosMapa[animalId] = r.id;
        }
      }

      setState(() {
        _animales = animales;
        _favoritosMap = favoritosMapa;
        _ocultosMap = ocultosMapa;
        _idsAutomaticos = idsAutomaticos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _onBusquedaCambiada(String valor) {
    _busqueda = valor;
    _cargar();
  }

  Future<void> _toggle(Animal animal) async {
    final esFavorito = _favoritosMap.containsKey(animal.id);
    try {
      if (esFavorito) {
        final accesoRapidoId = _favoritosMap[animal.id];
        if (accesoRapidoId != null) await AccesoRapidoRepository.quitar(accesoRapidoId);
      } else {
        await AccesoRapidoRepository.agregar(animal.id);
      }
      await _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleAutomatico(Animal animal) async {
    final estaOculto = _ocultosMap.containsKey(animal.id);
    try {
      if (estaOculto) {
        await AccesoRapidoRepository.mostrarAutomatico(_ocultosMap[animal.id]!);
      } else {
        await AccesoRapidoRepository.ocultarAutomatico(animal.id);
      }
      await _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar accesos rapidos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BuscadorDebounced(
              hint: 'Buscar por nombre',
              onCambio: _onBusquedaCambiada,
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _animales.isEmpty
                        ? const Center(child: Text('No se encontraron animales'))
                        : ListView.builder(
                            itemCount: _animales.length,
                            itemBuilder: (context, index) {
                              final a = _animales[index];
                              final esAutomatico = _idsAutomaticos.contains(a.id);
                              final estaOculto = _ocultosMap.containsKey(a.id);
                              return AccesoRapidoListTile(
                                animal: a,
                                esAutomatico: esAutomatico,
                                esFavorito: _favoritosMap.containsKey(a.id),
                                visible: esAutomatico ? !estaOculto : _favoritosMap.containsKey(a.id),
                                onToggle: () => esAutomatico ? _toggleAutomatico(a) : _toggle(a),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
