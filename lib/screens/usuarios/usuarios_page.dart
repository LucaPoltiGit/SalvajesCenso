import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../repositories/user_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/usuario_list_tile.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<Usuario> _usuarios = [];
  bool _cargando = true;
  String? _error;

  String? get _miId => PocketbaseService.instance.pb.authStore.model?.id;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final usuarios = await UserRepository.listarTodos();
      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarRol(String id, String nuevoRol) async {
    try {
      await UserRepository.cambiarRol(id, nuevoRol);
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _toggleBloqueo(String id, bool bloqueadoActual) async {
    try {
      await UserRepository.cambiarBloqueo(id, !bloqueadoActual);
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _confirmarBorrado(String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar usuario'),
        content: Text('Seguro que queres borrar a $nombre? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Borrar', style: TextStyle(color: AppColors.rojo))),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await UserRepository.borrar(id);
        _cargar();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar usuarios')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    itemCount: _usuarios.length,
                    itemBuilder: (context, index) {
                      final u = _usuarios[index];
                      return UsuarioListTile(
                        id: u.id,
                        nombre: u.nombre,
                        email: u.email,
                        rol: u.rol,
                        bloqueado: u.bloqueado,
                        esUsuarioActual: u.id == _miId,
                        onCambiarRol: (nuevoRol) => _cambiarRol(u.id, nuevoRol),
                        onToggleBloqueo: () => _toggleBloqueo(u.id, u.bloqueado),
                        onBorrar: () => _confirmarBorrado(u.id, u.nombre.isNotEmpty ? u.nombre : u.email),
                      );
                    },
                  ),
                ),
    );
  }
}
