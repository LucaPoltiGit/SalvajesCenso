import 'package:flutter/material.dart';
import '../../models/nota_historial.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/foto_repository.dart';
import '../../repositories/item_simple.dart';
import '../../repositories/nota_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_strings.dart';
import '../../utils/text_format.dart';
import '../../utils/formatear_fecha.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/ancho_formulario.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/campo_texto.dart';
import '../../widgets/seleccionar_foto_button.dart';

class NotaFormPage extends StatefulWidget {
  final String animalId;
  final String animalNombre;
  final NotaHistorial? notaExistente;

  const NotaFormPage({
    super.key,
    required this.animalId,
    required this.animalNombre,
    this.notaExistente,
  });

  @override
  State<NotaFormPage> createState() => _NotaFormPageState();
}

class _NotaFormPageState extends State<NotaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notaRepo = NotaRepository();
  final _fotoRepo = FotoRepository();
  final _tipoRepo = CategoriaRepository('tipos_nota');
  final _contenidoCtrl = TextEditingController();

  bool _cargandoOpciones = true;
  bool _guardando = false;
  Object? _error;

  List<ItemSimple> _tipos = [];
  String? _tipoId;
  DateTime _fecha = DateTime.now();
  List<int>? _fotoBytes;

  bool get _esEdicion => widget.notaExistente != null;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  @override
  void dispose() {
    _contenidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarOpciones() async {
    try {
      await PocketbaseService.instance.ensureAuth();
      final tipos = await _tipoRepo.listar();

      if (_esEdicion) {
        _contenidoCtrl.text = widget.notaExistente!.contenido;
        _tipoId = widget.notaExistente!.tipoId;
        _fecha = widget.notaExistente!.fecha;
      }

      setState(() {
        _tipos = tipos;
        _cargandoOpciones = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _cargandoOpciones = false;
      });
    }
  }

  void _onFotoSeleccionada(List<int> bytes) =>
      setState(() => _fotoBytes = bytes);

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() => _fecha = fecha);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoId == null) {
      setState(() => _error = 'Elegi un tipo de nota');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      String notaId;
      if (_esEdicion) {
        await _notaRepo.editar(
          id: widget.notaExistente!.id,
          animalId: widget.animalId,
          tipoId: _tipoId!,
          contenido: _contenidoCtrl.text.trim(),
          fecha: _fecha,
        );
        notaId = widget.notaExistente!.id;
      } else {
        notaId = await _notaRepo.crear(
          animalId: widget.animalId,
          tipoId: _tipoId!,
          contenido: _contenidoCtrl.text.trim(),
          fecha: _fecha,
        );
      }

      if (_fotoBytes != null) {
        await _fotoRepo.subir(
          animalId: widget.animalId,
          notaId: notaId,
          bytes: _fotoBytes!,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e;
        _guardando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion
              ? AppStrings.editarNota(widget.animalNombre)
              : AppStrings.agregarNota(widget.animalNombre),
        ),
      ),
      body: _cargandoOpciones
          ? const Center(child: CircularProgressIndicator())
          : AnchoFormulario(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error is Exception
                              ? mensajeErrorAmigable(_error!)
                              : _error.toString(),
                          style: const TextStyle(color: AppColors.rojo),
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      value: _tipoId,
                      items: _tipos
                          .map<DropdownMenuItem<String>>(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(formatearEtiqueta(t.nombre)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _tipoId = v),
                      validator: (v) => v == null ? 'Elegi un tipo' : null,
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _elegirFecha,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(formatearFecha(_fecha)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CampoTexto(
                      controller: _contenidoCtrl,
                      label: 'Contenido',
                      maxLines: 5,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Este campo es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    SeleccionarFotoButton(
                      texto: _fotoBytes == null
                          ? 'Adjuntar foto (opcional)'
                          : 'Foto seleccionada, tocar para cambiar',
                      onFotoSeleccionada: _onFotoSeleccionada,
                    ),
                    const SizedBox(height: 24),
                    BotonGuardar(
                      cargando: _guardando,
                      texto: _esEdicion ? 'Guardar cambios' : 'Guardar nota',
                      onPressed: _guardar,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
