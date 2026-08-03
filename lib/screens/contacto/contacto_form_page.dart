import 'package:flutter/material.dart';
import '../../repositories/contacto_repository.dart';
import '../../theme/app_colors.dart';

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
  String? _error;

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
        _error = e.toString();
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiero ayudar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: AppColors.rojo)),
            ),
          TextFormField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre (opcional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _telefonoCtrl,
            decoration: const InputDecoration(labelText: 'Telefono (opcional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email (opcional)', border: OutlineInputBorder()),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _mensajeCtrl,
            decoration: const InputDecoration(labelText: 'Mensaje (opcional)', border: OutlineInputBorder()),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
