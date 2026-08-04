import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../repositories/contacto_repository.dart';
import '../../theme/app_strings.dart';
import '../../utils/mensajes_error.dart';

class ContactosPage extends StatefulWidget {
  const ContactosPage({super.key});

  @override
  State<ContactosPage> createState() => _ContactosPageState();
}

class _ContactosPageState extends State<ContactosPage> {
  List<RecordModel> _contactos = [];
  bool _cargando = true;
  Object? _error;

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
      final contactos = await ContactoRepository.listarTodos();
      setState(() {
        _contactos = contactos;
        _cargando = false;
      });
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
      appBar: AppBar(title: const Text(AppStrings.contactosRecibidos)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(mensajeErrorAmigable(_error!)))
          : _contactos.isEmpty
          ? const Center(child: Text('No hay contactos recibidos'))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView.builder(
                itemCount: _contactos.length,
                itemBuilder: (context, index) {
                  final c = _contactos[index];
                  final nombre = (c.data['nombre'] as String?) ?? '';
                  final telefono = (c.data['telefono'] as String?) ?? '';
                  final email = (c.data['email'] as String?) ?? '';
                  final mensaje = (c.data['mensaje'] as String?) ?? '';
                  return ListTile(
                    title: Text(nombre.isEmpty ? 'Sin nombre' : nombre),
                    subtitle: Text(
                      [
                        if (telefono.isNotEmpty) telefono,
                        if (email.isNotEmpty) email,
                        if (mensaje.isNotEmpty) mensaje,
                      ].join('\n'),
                    ),
                    isThreeLine: mensaje.isNotEmpty,
                  );
                },
              ),
            ),
    );
  }
}
