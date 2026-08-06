import 'package:flutter/material.dart';
import '../../repositories/contacto_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/ancho_formulario.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/campo_texto.dart';

class ContactoFormPage extends StatefulWidget {
  const ContactoFormPage({super.key});

  @override
  State<ContactoFormPage> createState() => _ContactoFormPageState();
}

class _ContactoFormPageState extends State<ContactoFormPage> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();

  bool _enviando = false;
  Object? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      await ContactoRepository.crear(
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        mensaje: _mensajeCtrl.text.trim(),
      );

      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Gracias!'),
            content: const Text('Te vamos a contactar pronto.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e;
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quieroAyudar)),
      body: AnchoFormulario(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  mensajeErrorAmigable(_error!),
                  style: const TextStyle(color: AppColors.rojo),
                ),
              ),
            CampoTexto(
              controller: _nombreCtrl,
              label: 'Nombre (opcional)',
            ),
            const SizedBox(height: 14),
            CampoTexto(
              controller: _telefonoCtrl,
              label: 'Telefono (opcional)',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            CampoTexto(
              controller: _emailCtrl,
              label: 'Email (opcional)',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            CampoTexto(
              controller: _mensajeCtrl,
              label: 'Mensaje (opcional)',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            BotonGuardar(
              cargando: _enviando,
              texto: 'Enviar',
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}
