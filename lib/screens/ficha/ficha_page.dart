import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../models/animal.dart';
import '../../models/nota_historial.dart';
import '../../models/foto.dart';
import '../../repositories/animal_repository.dart';
import '../../repositories/nota_repository.dart';
import '../../repositories/foto_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../services/auth_helper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../utils/mensajes_error.dart';
import '../../widgets/ficha_header.dart';
import '../../widgets/ficha_tab_datos.dart';
import '../../widgets/ficha_tab_sobre.dart';
import '../alta/alta_page.dart';
import '../nota/nota_form_page.dart';
import '../foto/foto_viewer_page.dart';

class FichaPage extends StatefulWidget {
  final Animal animal;
  const FichaPage({super.key, required this.animal});

  @override
  State<FichaPage> createState() => _FichaPageState();
}

class _FichaPageState extends State<FichaPage> {
  final _pbService = PocketbaseService.instance;
  final _animalRepo = AnimalRepository();
  final _notaRepo = NotaRepository();
  final _fotoRepo = FotoRepository();

  Animal? _animal;
  RecordModel? _registroCrudo;
  List<NotaHistorial> _notas = [];
  List<Foto> _fotos = [];
  Map<String, List<Foto>> _fotosPorNota = {};
  bool _cargando = true;
  Object? _error;
  bool _seModifico = false;
  bool _subiendoFoto = false;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();

      final registro = await _animalRepo.obtenerRecordCrudo(widget.animal.id);

      List<NotaHistorial> notas = [];
      if (AuthHelper.puedeVerNotas) {
        notas = await _notaRepo.listarPorAnimal(widget.animal.id);
      }

      final fotosGenerales = await _fotoRepo.listarGeneralesDeAnimal(
        widget.animal.id,
      );
      final fotosDeNotas = await _fotoRepo.listarDeNotasDeAnimal(
        widget.animal.id,
      );
      final fotosPorNota = <String, List<Foto>>{};
      for (final f in fotosDeNotas) {
        if (f.notaId == null) continue;
        fotosPorNota.putIfAbsent(f.notaId!, () => []).add(f);
      }

      setState(() {
        _animal = Animal.fromRecord(registro);
        _registroCrudo = registro;
        _notas = notas;
        _fotos = fotosGenerales;
        _fotosPorNota = fotosPorNota;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _cargando = false;
      });
    }
  }

  Future<void> _confirmarBorrado() async {
    final a = _animal ?? widget.animal;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text(
          'Seguro que queres borrar a ${a.nombre}? Esta accion no se puede deshacer.',
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
      await _animalRepo.borrar(widget.animal.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  Future<void> _elegirFotoPerfil() async {
    final resultado = await FilePicker.pickFiles(type: FileType.image);
    if (resultado == null || resultado.files.isEmpty) return;
    final archivo = resultado.files.first;
    Uint8List? bytes = archivo.bytes;
    if (bytes == null && archivo.path != null) {
      bytes = await File(archivo.path!).readAsBytes();
    }
    if (bytes == null) return;
    await _subirFoto(bytes, esPerfil: true);
  }

  Future<void> _subirFotoGeneral(List<int> bytes) async {
    await _subirFoto(bytes, esPerfil: false);
  }

  Future<void> _subirFoto(List<int> bytes, {required bool esPerfil}) async {
    setState(() => _subiendoFoto = true);
    try {
      await _fotoRepo.subir(
        animalId: widget.animal.id,
        bytes: bytes,
        esPerfil: esPerfil,
      );
      _seModifico = true;
      await _cargarDatos();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _verFoto(Foto foto) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FotoViewerPage(foto: foto)),
    );
    if (resultado == true) {
      _seModifico = true;
      _cargarDatos();
    }
  }

  Future<void> _abrirFormularioNota({NotaHistorial? notaExistente}) async {
    final a = _animal ?? widget.animal;
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NotaFormPage(
          animalId: a.id,
          animalNombre: a.nombre,
          notaExistente: notaExistente,
        ),
      ),
    );
    if (resultado == true) {
      _cargarDatos();
    }
  }

  Future<void> _confirmarBorradoNota(NotaHistorial nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
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
      await _notaRepo.borrar(nota.id);
      _cargarDatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _animal ?? widget.animal;

    Foto? fotoPerfil;
    try {
      fotoPerfil = _fotos.firstWhere((f) => f.esPerfil);
    } catch (_) {
      fotoPerfil = null;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_seModifico);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(a.nombre),
            actions: [
              if (AuthHelper.puedeEditar)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final resultado = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AltaPage(animalExistente: _registroCrudo),
                      ),
                    );
                    if (resultado == true) {
                      _seModifico = true;
                      _cargarDatos();
                    }
                  },
                ),
              if (AuthHelper.puedeBorrar)
                IconButton(
                  icon: const Icon(AppIcons.eliminar),
                  onPressed: _confirmarBorrado,
                ),
            ],
          ),
          body: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(mensajeErrorAmigable(_error!)))
              : Column(
                  children: [
                    FichaHeader(
                      animal: a,
                      fotoUrl: fotoPerfil?.url,
                      onEditarFoto: _elegirFotoPerfil,
                    ),
                    TabBar(
                      labelColor: AppColors.verde,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.verde,
                      tabs: const [
                        Tab(text: 'Datos'),
                        Tab(text: 'Sobre el animal'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          FichaTabDatos(
                            animal: a,
                            fotos: _fotos,
                            notas: _notas,
                            fotosPorNota: _fotosPorNota,
                            subiendoFoto: _subiendoFoto,
                            onRefresh: _cargarDatos,
                            onSubirFoto: _subirFotoGeneral,
                            onTapFoto: _verFoto,
                            onAgregarNota: () => _abrirFormularioNota(),
                            onEditarNota: (n) =>
                                _abrirFormularioNota(notaExistente: n),
                            onBorrarNota: _confirmarBorradoNota,
                          ),
                          FichaTabSobre(animal: a),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
