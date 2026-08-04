import 'package:flutter/material.dart';
import '../models/nota_historial.dart';
import '../models/foto.dart';
import '../repositories/animal_repository.dart';
import '../repositories/foto_repository.dart';
import '../repositories/nota_repository.dart';
import '../screens/ficha/ficha_page.dart';
import '../screens/foto/foto_viewer_page.dart';
import '../screens/nota/nota_form_page.dart';
import '../services/auth_helper.dart';
import '../theme/app_colors.dart';
import '../utils/formatear_fecha.dart';
import '../utils/mensajes_error.dart';
import '../utils/text_format.dart';

class NotaDetalleDialog extends StatefulWidget {
  final NotaHistorial nota;
  final String animalNombre;
  final String animalId;
  final VoidCallback onCambio;

  const NotaDetalleDialog({
    super.key,
    required this.nota,
    required this.animalNombre,
    required this.animalId,
    required this.onCambio,
  });

  @override
  State<NotaDetalleDialog> createState() => _NotaDetalleDialogState();
}

class _NotaDetalleDialogState extends State<NotaDetalleDialog> {
  final _fotoRepo = FotoRepository();
  final _notaRepo = NotaRepository();
  final _animalRepo = AnimalRepository();

  List<Foto> _fotos = [];
  bool _cargandoFotos = true;

  @override
  void initState() {
    super.initState();
    _cargarFotos();
  }

  Future<void> _cargarFotos() async {
    try {
      final fotos = await _fotoRepo.listarPorNota(widget.nota.id);
      if (mounted) {
        setState(() {
          _fotos = fotos;
          _cargandoFotos = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cargandoFotos = false);
    }
  }

  Color get _colorTipo {
    switch (widget.nota.tipoNombre) {
      case 'medica':
        return AppColors.rojo;
      case 'comida':
        return AppColors.amarillo;
      case 'cambio_sector':
      case 'cambio_estado':
        return AppColors.madera;
      default:
        return AppColors.verde;
    }
  }

  Future<void> _editar() async {
    Navigator.pop(context);
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NotaFormPage(
          animalId: widget.animalId,
          animalNombre: widget.animalNombre,
          notaExistente: widget.nota,
        ),
      ),
    );
    if (resultado == true) widget.onCambio();
  }

  Future<void> _borrar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Borrar nota'),
        content: const Text(
          'Seguro que queres borrar esta nota? Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Borrar',
              style: TextStyle(color: AppColors.rojo),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _notaRepo.borrar(widget.nota.id);
      if (mounted) Navigator.pop(context);
      widget.onCambio();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  Future<void> _irAlPerfil() async {
    try {
      final animal = await _animalRepo.obtenerPorId(widget.animalId);
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FichaPage(animal: animal)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  Future<void> _crearNuevaNota() async {
    Navigator.pop(context);
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NotaFormPage(
          animalId: widget.animalId,
          animalNombre: widget.animalNombre,
        ),
      ),
    );
    if (resultado == true) widget.onCambio();
  }

  @override
  Widget build(BuildContext context) {
    final mostrarMenu =
        AuthHelper.puedeEditarNotas || AuthHelper.puedeBorrarNotas;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.animalNombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (mostrarMenu)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) {
                        if (v == 'editar') _editar();
                        if (v == 'borrar') _borrar();
                      },
                      itemBuilder: (context) => [
                        if (AuthHelper.puedeEditarNotas)
                          const PopupMenuItem(
                            value: 'editar',
                            child: Text('Editar'),
                          ),
                        if (AuthHelper.puedeBorrarNotas)
                          const PopupMenuItem(
                            value: 'borrar',
                            child: Text('Borrar'),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    formatearEtiqueta(widget.nota.tipoNombre),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _colorTipo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatearFecha(widget.nota.fecha),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.madera,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.nota.contenido, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              if (_cargandoFotos)
                const SizedBox(
                  height: 80,
                  width: 80,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_fotos.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _fotos.length,
                    itemBuilder: (context, index) {
                      final f = _fotos[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FotoViewerPage(foto: f),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              f.url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verde,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _irAlPerfil,
                  child: const Text('Ir al perfil'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _crearNuevaNota,
                  child: const Text('Crear nueva nota'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
