import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/mensajes_error.dart';
import '../../utils/validadores.dart';
import '../../widgets/ancho_formulario.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/campo_password.dart';
import '../../widgets/campo_texto.dart';
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
  Object? _error;

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
      await PocketbaseService.instance.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AppShell(key: appShellKey)),
        );
      }
    } catch (e) {
      setState(() {
        _error = e;
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AppShell(key: appShellKey)),
        );
      }
    } catch (e) {
      setState(() {
        _error = e;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: AnchoFormulario(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Santuario App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.verde,
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  mensajeErrorAmigable(_error!),
                                  style: const TextStyle(color: AppColors.rojo),
                                ),
                              ),
                            CampoTexto(
                              controller: _emailCtrl,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: validadorRequerido,
                            ),
                            const SizedBox(height: 14),
                            CampoPassword(
                              controller: _passwordCtrl,
                              label: 'Contrasena',
                              validator: validadorRequerido,
                            ),
                            const SizedBox(height: 24),
                            BotonGuardar(
                              cargando: _cargando,
                              texto: 'Ingresar',
                              onPressed: _ingresar,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'o',
                                    style: TextStyle(color: AppColors.madera),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.madera,
                                side: const BorderSide(color: AppColors.madera),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: _cargando
                                  ? null
                                  : _ingresarComoVisitante,
                              child: const Text('Soy visitante'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
