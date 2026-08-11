import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../repositories/acceso_rapido_repository.dart';
import '../../repositories/animal_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/acceso_rapido_list_tile.dart';
import '../../widgets/buscador_debounced.dart';
import '../../widgets/fab_guardar_condicional.dart';

class AccesoRapidoManagerPage extends StatefulWidget {
  const AccesoRapidoManagerPage({super.key});

  @override
  State<AccesoRapidoManagerPage> createState() =>
      _AccesoRapidoManagerPageState();
}

class _AccesoRapidoManagerPageState extends State<AccesoRapidoManagerPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();

  List<Animal> _animales = [];
  Map<String, String> _favoritosMap = {};
  Map<String, String> _ocultosMap = {};
  Set<String> _idsAutomaticos = {};
  bool _cargando = true;
  bool _guardando = false;
  Object? _error;
  String _busqueda = '';

  // Estado local en memoria: los cambios se acumulan aca y solo se
  // mandan a PocketBase cuando el usuario toca "Guardar".
  Set<String> _favoritosPendientes = {};
  Set<String> _ocultosPendientes = {};

  bool get _hayCambiosSinGuardar =>
      !setEquals(_favoritosPendientes, _favoritosMap.keys.toSet()) ||
      !setEquals(_ocultosPendientes, _ocultosMap.keys.toSet());

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
      final idsAutomaticos = await _animalRepo
          .listarIdsAutomaticosAccesoRapido();

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
        _favoritosPendientes = favoritosMapa.keys.toSet();
        _ocultosPendientes = ocultosMapa.keys.toSet();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _cargando = false;
      });
    }
  }

  void _onBusquedaCambiada(String valor) {
    _busqueda = valor;
    _cargar();
  }

  void _toggle(Animal animal) {
    setState(() {
      if (_favoritosPendientes.contains(animal.id)) {
        _favoritosPendientes.remove(animal.id);
      } else {
        _favoritosPendientes.add(animal.id);
      }
    });
  }

  void _toggleAutomatico(Animal animal) {
    setState(() {
      if (_ocultosPendientes.contains(animal.id)) {
        _ocultosPendientes.remove(animal.id);
      } else {
        _ocultosPendientes.add(animal.id);
      }
    });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final favoritosOriginales = _favoritosMap.keys.toSet();
      final ocultosOriginales = _ocultosMap.keys.toSet();

      for (final id in _favoritosPendientes.difference(favoritosOriginales)) {
        await AccesoRapidoRepository.agregar(id);
      }
      for (final id in favoritosOriginales.difference(_favoritosPendientes)) {
        final accesoRapidoId = _favoritosMap[id];
        if (accesoRapidoId != null) {
          await AccesoRapidoRepository.quitar(accesoRapidoId);
        }
      }

      for (final id in _ocultosPendientes.difference(ocultosOriginales)) {
        await AccesoRapidoRepository.ocultarAutomatico(id);
      }
      for (final id in ocultosOriginales.difference(_ocultosPendientes)) {
        final accesoRapidoId = _ocultosMap[id];
        if (accesoRapidoId != null) {
          await AccesoRapidoRepository.mostrarAutomatico(accesoRapidoId);
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editarAccesosRapidos)),
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
                ? Center(child: Text(mensajeErrorAmigable(_error!)))
                : _animales.isEmpty
                ? const Center(child: Text(AppStrings.sinAnimalesEncontrados))
                : ListView.builder(
                    itemCount: _animales.length,
                    itemBuilder: (context, index) {
                      final a = _animales[index];
                      final esAutomatico = _idsAutomaticos.contains(a.id);
                      final estaOculto = _ocultosPendientes.contains(a.id);
                      return AccesoRapidoListTile(
                        animal: a,
                        esAutomatico: esAutomatico,
                        esFavorito: _favoritosPendientes.contains(a.id),
                        visible: esAutomatico
                            ? !estaOculto
                            : _favoritosPendientes.contains(a.id),
                        onToggle: () =>
                            esAutomatico ? _toggleAutomatico(a) : _toggle(a),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FabGuardarCondicional(
        visible: _hayCambiosSinGuardar,
        cargando: _guardando,
        texto: AppStrings.guardar,
        onPressed: _guardar,
      ),
    );
  }
}
