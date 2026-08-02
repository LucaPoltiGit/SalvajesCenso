import 'package:flutter/material.dart';
import '../../repositories/user_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/campo_password.dart';

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});

  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  final _nombreCtrl = TextEditingController();
  final _passwordActualCtrl = TextEditingController();
  final _passwordNuevaCtrl = TextEditingController();
  final _passwordConfirmarCtrl = TextEditingController();

  bool _guardandoNombre = false;
  bool _cambiandoPassword = false;
  String? _errorNombre;
  String? _errorPassword;

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = PocketbaseService.instance.pb.authStore.model?.data['name'] ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _passwordActualCtrl.dispose();
    _passwordNuevaCtrl.dispose();
    _passwordConfirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarNombre() async {
    final nuevoNombre = _nombreCtrl.text.trim();
    if (nuevoNombre.isEmpty) {
      setState(() => _errorNombre = 'El nombre no puede estar vacio');
      return;
    }

    setState(() {
      _guardandoNombre = true;
      _errorNombre = null;
    });
    try {
      await UserRepository.actualizarNombre(nuevoNombre);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
      }
    } catch (e) {
      setState(() => _errorNombre = e.toString());
    } finally {
      if (mounted) setState(() => _guardandoNombre = false);
    }
  }

  Future<void> _cambiarPassword() async {
    final actual = _passwordActualCtrl.text;
    final nueva = _passwordNuevaCtrl.text;
    final confirmar = _passwordConfirmarCtrl.text;

    if (actual.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
      setState(() => _errorPassword = 'Completa los 3 campos');
      return;
    }
    if (nueva.length < 8) {
      setState(() => _errorPassword = 'La nueva contrasena debe tener al menos 8 caracteres');
      return;
    }
    if (nueva != confirmar) {
      setState(() => _errorPassword = 'Las contrasenas nuevas no coinciden');
      return;
    }

    setState(() {
      _cambiandoPassword = true;
      _errorPassword = null;
    });
    try {
      await UserRepository.cambiarPassword(actual: actual, nueva: nueva, confirmar: confirmar);
      _passwordActualCtrl.clear();
      _passwordNuevaCtrl.clear();
      _passwordConfirmarCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contrasena actualizada')));
      }
    } catch (e) {
      setState(() => _errorPassword = e.toString());
    } finally {
      if (mounted) setState(() => _cambiandoPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Mi perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          if (_errorNombre != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_errorNombre!, style: const TextStyle(color: AppColors.rojo)),
            ),
          TextFormField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _guardandoNombre ? null : _guardarNombre,
            child: _guardandoNombre
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Guardar nombre'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Cambiar contrasena', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          if (_errorPassword != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_errorPassword!, style: const TextStyle(color: AppColors.rojo)),
            ),
          CampoPassword(
            controller: _passwordActualCtrl,
            label: 'Contrasena actual',
          ),
          const SizedBox(height: 14),
          CampoPassword(
            controller: _passwordNuevaCtrl,
            label: 'Nueva contrasena',
          ),
          const SizedBox(height: 14),
          CampoPassword(
            controller: _passwordConfirmarCtrl,
            label: 'Confirmar nueva contrasena',
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _cambiandoPassword ? null : _cambiarPassword,
            child: _cambiandoPassword
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Cambiar contrasena'),
          ),
        ],
      ),
    );
  }
}
