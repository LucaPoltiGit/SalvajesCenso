import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/validadores.dart';
import '../../widgets/campo_password.dart';
import '../shell/app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await PocketbaseService.instance.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(key: appShellKey)));
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo iniciar sesion: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _ingresarComoVisitante() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await PocketbaseService.instance.loginComoVisitante();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(key: appShellKey)));
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo ingresar como visitante: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Santuario App',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.verde),
                  ),
                  const SizedBox(height: 32),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: AppColors.rojo)),
                    ),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    validator: validadorRequerido,
                  ),
                  const SizedBox(height: 14),
                  CampoPassword(
                    controller: _passwordCtrl,
                    label: 'Contrasena',
                    validator: validadorRequerido,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _cargando ? null : _ingresar,
                    child: _cargando
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Ingresar'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('o', style: TextStyle(color: AppColors.madera)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.madera,
                      side: const BorderSide(color: AppColors.madera),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _cargando ? null : _ingresarComoVisitante,
                    child: const Text('Soy visitante'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
