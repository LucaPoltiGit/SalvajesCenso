import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/campania_ayuda.dart';
import '../../repositories/ayuda_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/seleccionar_foto_button.dart';

class AyudaFormPage extends StatefulWidget {
  final CampaniaAyuda? campaniaExistente;

  const AyudaFormPage({super.key, this.campaniaExistente});

  @override
  State<AyudaFormPage> createState() => _AyudaFormPageState();
}

class _AyudaFormPageState extends State<AyudaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _problemaCtrl = TextEditingController();
  final _montoNecesarioCtrl = TextEditingController();
  final _montoRecaudadoCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();

  bool _guardando = false;
  String? _error;
  bool _estado = true;
  Uint8List? _imagenBytes;

  bool get _esEdicion => widget.campaniaExistente != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final c = widget.campaniaExistente!;
      _tituloCtrl.text = c.titulo;
      _problemaCtrl.text = c.problema;
      if (c.montoNecesario != null) _montoNecesarioCtrl.text = c.montoNecesario!.toStringAsFixed(0);
      _montoRecaudadoCtrl.text = c.montoRecaudado.toStringAsFixed(0);
      _aliasCtrl.text = c.aliasDonacion;
      _estado = c.estado;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _problemaCtrl.dispose();
    _montoNecesarioCtrl.dispose();
    _montoRecaudadoCtrl.dispose();
    _aliasCtrl.dispose();
    super.dispose();
  }

  void _onFotoSeleccionada(List<int> bytes) => setState(() => _imagenBytes = Uint8List.fromList(bytes));

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final montoNecesario = _montoNecesarioCtrl.text.trim().isEmpty ? null : double.tryParse(_montoNecesarioCtrl.text.trim());

      if (_esEdicion) {
        final montoRecaudado = double.tryParse(_montoRecaudadoCtrl.text.trim()) ?? 0;
        await AyudaRepository.editar(
          id: widget.campaniaExistente!.id,
          titulo: _tituloCtrl.text.trim(),
          problema: _problemaCtrl.text.trim(),
          montoNecesario: montoNecesario,
          montoRecaudado: montoRecaudado,
          aliasDonacion: _aliasCtrl.text.trim(),
          estado: _estado,
          imagenBytesNueva: _imagenBytes,
        );
      } else {
        await AyudaRepository.crear(
          titulo: _tituloCtrl.text.trim(),
          problema: _problemaCtrl.text.trim(),
          montoNecesario: montoNecesario,
          aliasDonacion: _aliasCtrl.text.trim(),
          imagenBytes: _imagenBytes,
        );
      }

      if (mounted) Navigator.pop(context, true);
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
      appBar: AppBar(title: Text(_esEdicion ? 'Editar campania' : 'Nueva campania')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: AppColors.rojo)),
              ),
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Titulo', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _problemaCtrl,
              decoration: const InputDecoration(labelText: 'Problema', border: OutlineInputBorder()),
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _montoNecesarioCtrl,
              decoration: const InputDecoration(labelText: 'Monto necesario (opcional)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            if (_esEdicion) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _montoRecaudadoCtrl,
                decoration: const InputDecoration(labelText: 'Monto recaudado', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _aliasCtrl,
              decoration: const InputDecoration(labelText: 'Alias de donacion', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
            ),
            const SizedBox(height: 14),
            SeleccionarFotoButton(
              texto: _imagenBytes == null ? 'Adjuntar imagen (opcional)' : 'Imagen seleccionada, tocar para cambiar',
              onFotoSeleccionada: _onFotoSeleccionada,
            ),
            if (_esEdicion) ...[
              const SizedBox(height: 14),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Campania activa'),
                value: _estado,
                onChanged: (v) => setState(() => _estado = v),
              ),
            ],
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
                  : Text(_esEdicion ? 'Guardar cambios' : 'Crear campania'),
            ),
          ],
        ),
      ),
    );
  }
}
