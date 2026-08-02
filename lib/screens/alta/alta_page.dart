import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/item_simple.dart';
import '../../repositories/sector_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/validadores.dart';
import '../../widgets/alta_datos_basicos_section.dart';
import '../../widgets/alta_detalles_section.dart';

class AltaPage extends StatefulWidget {
  final RecordModel? animalExistente;
  const AltaPage({super.key, this.animalExistente});

  @override
  State<AltaPage> createState() => _AltaPageState();
}

class _AltaPageState extends State<AltaPage> {
  final _formKey = GlobalKey<FormState>();
  final _animalRepo = AnimalRepository();
  final _sectorRepo = SectorRepository();
  final _especieRepo = CategoriaRepository('especies');
  final _estadoRepo = CategoriaRepository('estados');

  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _dietaCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _historiaCtrl = TextEditingController();

  bool _cargandoOpciones = true;
  bool _guardando = false;
  String? _error;

  List<ItemSimple> _especies = [];
  List<ItemSimple> _sectores = [];
  List<ItemSimple> _estados = [];

  String? _especieId;
  String? _sectorId;
  String? _estadoId;
  String? _alerta;
  DateTime? _fechaLlegada;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _dietaCtrl.dispose();
    _descripcionCtrl.dispose();
    _historiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarOpciones() async {
    try {
      await PocketbaseService.instance.ensureAuth();
      final especies = await _especieRepo.listar();
      final sectores = await _sectorRepo.listar();
      final estados = await _estadoRepo.listar();

      String? estadoDefault;
      for (final e in estados) {
        if (e.nombre == 'bien') {
          estadoDefault = e.id;
          break;
        }
      }

      setState(() {
        _especies = especies;
        _sectores = sectores;
        _estados = estados;
        final animalExistente = widget.animalExistente;
        if (animalExistente != null) {
          _nombreCtrl.text = animalExistente.data['nombre'] ?? '';
          _edadCtrl.text = animalExistente.data['edad'] ?? '';
          _dietaCtrl.text = animalExistente.data['dieta'] ?? '';
          _descripcionCtrl.text = animalExistente.data['descripcion'] ?? '';
          _historiaCtrl.text = animalExistente.data['historia_llegada'] ?? '';
          _especieId = animalExistente.data['especie'];
          _sectorId = animalExistente.data['sector'];
          _estadoId = animalExistente.data['estado'];
          final alerta = animalExistente.data['alerta'] ?? '';
          _alerta = alerta.isEmpty ? null : alerta;
          final fechaLlegadaTexto = animalExistente.data['fecha_llegada'] ?? '';
          _fechaLlegada = fechaLlegadaTexto.isEmpty ? null : DateTime.tryParse(fechaLlegadaTexto);
        } else {
          _estadoId = estadoDefault;
        }
        _cargandoOpciones = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargandoOpciones = false;
      });
    }
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fechaLlegada = fecha);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_especieId == null || _sectorId == null || _estadoId == null) {
      setState(() => _error = 'Completa especie, sector y estado');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final body = {
        'nombre': _nombreCtrl.text.trim(),
        'especie': _especieId,
        'sector': _sectorId,
        'estado': _estadoId,
        'edad': _edadCtrl.text.trim(),
        'dieta': _dietaCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'historia_llegada': _historiaCtrl.text.trim(),
        if (_alerta != null) 'alerta': _alerta,
        if (_fechaLlegada != null) 'fecha_llegada': _fechaLlegada!.toIso8601String(),
      };

      final animalExistente = widget.animalExistente;
      if (animalExistente != null) {
        await _animalRepo.editar(animalExistente.id, body);
      } else {
        await _animalRepo.crear(body);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.animalExistente != null ? 'Editar animal' : 'Agregar animal')),
      body: _cargandoOpciones
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: AppColors.rojo)),
                    ),
                  AltaDatosBasicosSection(
                    nombreCtrl: _nombreCtrl,
                    validadorNombre: validadorRequerido,
                    especies: _especies,
                    sectores: _sectores,
                    estados: _estados,
                    especieId: _especieId,
                    sectorId: _sectorId,
                    estadoId: _estadoId,
                    onEspecieCambiada: (v) => setState(() => _especieId = v),
                    onSectorCambiado: (v) => setState(() => _sectorId = v),
                    onEstadoCambiado: (v) => setState(() => _estadoId = v),
                  ),
                  const SizedBox(height: 14),
                  AltaDetallesSection(
                    edadCtrl: _edadCtrl,
                    dietaCtrl: _dietaCtrl,
                    descripcionCtrl: _descripcionCtrl,
                    historiaCtrl: _historiaCtrl,
                    fechaLlegada: _fechaLlegada,
                    onElegirFecha: _elegirFecha,
                    alerta: _alerta,
                    onAlertaCambiada: (v) => setState(() => _alerta = v),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.animalExistente != null ? 'Guardar cambios' : 'Guardar residente'),
                  ),
                ],
              ),
            ),
    );
  }
}
