import 'dart:async';
import 'package:flutter/material.dart';

class BuscadorDebounced extends StatefulWidget {
  final String hint;
  final void Function(String texto) onCambio;

  const BuscadorDebounced({super.key, required this.hint, required this.onCambio});

  @override
  State<BuscadorDebounced> createState() => _BuscadorDebouncedState();
}

class _BuscadorDebouncedState extends State<BuscadorDebounced> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String valor) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => widget.onCambio(valor));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      onChanged: _onChanged,
    );
  }
}
