import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/validadores.dart';

class CategoriaFormDialog extends StatefulWidget {
  final String titulo;
  final String? valorInicial;

  const CategoriaFormDialog({super.key, required this.titulo, this.valorInicial});

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.valorInicial ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _nombreCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nombreCtrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          validator: validadorRequerido,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
          onPressed: _confirmar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
