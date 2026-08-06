import 'package:flutter/material.dart';
import '../../repositories/user_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';
import '../../utils/validadores.dart';
import '../../widgets/ancho_formulario.dart';
import '../../widgets/boton_guardar.dart';
import '../../widgets/campo_password.dart';
import '../../widgets/campo_texto.dart';

class CrearUsuarioPage extends StatefulWidget {
  const CrearUsuarioPage({super.key});

  @override
  State<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String _rol = 'estandar';
  bool _guardando = false;
  Object? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validadorPassword(String? valor) {
    if (valor == null || valor.isEmpty) return 'Este campo es obligatorio';
    if (valor.length < 8) return 'Debe tener al menos 8 caracteres';
    return null;
  }

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await UserRepository.crear(
        nombre: _nombreCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        rol: _rol,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
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
      appBar: AppBar(title: const Text(AppStrings.crearUsuario)),
      body: AnchoFormulario(
        child: Form(
          key: _formKey,
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
                label: 'Nombre',
                validator: validadorRequerido,
              ),
              const SizedBox(height: 14),
              CampoTexto(
                controller: _emailCtrl,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: validadorEmail,
              ),
              const SizedBox(height: 14),
              CampoPassword(
                controller: _passwordCtrl,
                label: 'Contrasena temporal',
                validator: _validadorPassword,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  border: OutlineInputBorder(),
                ),
                value: _rol,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'estandar',
                    child: Text('Voluntario'),
                  ),
                  DropdownMenuItem(value: 'visita', child: Text('Visita')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _rol = v);
                },
              ),
              const SizedBox(height: 24),
              BotonGuardar(
                cargando: _guardando,
                texto: 'Crear usuario',
                onPressed: _crear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
