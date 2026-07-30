import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../models/animal.dart';
import '../../models/nota_historial.dart';
import '../../services/pocketbase_service.dart';
import '../../services/auth_helper.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dato_item.dart';
import '../../widgets/nota_historial_card.dart';
import '../../utils/text_format.dart';
import '../alta/alta_page.dart';
import '../nota/nota_form_page.dart';
import '../../models/foto.dart';
import '../../services/foto_service.dart';
import '../../widgets/seleccionar_foto_button.dart';
import '../foto/foto_viewer_page.dart';

class FichaPage extends StatefulWidget {
  final Animal animal;
  const FichaPage({super.key, required this.animal});

  @override
  State<FichaPage> createState() => _FichaPageState();
}

class _FichaPageState extends State<FichaPage> {
  final _pbService = PocketbaseService.instance;

  Animal? _animal;
  RecordModel? _registroCrudo;
  List<NotaHistorial> _notas = [];
  List<Foto> _fotos = [];
  bool _cargando = true;
  String? _error;
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
      final pb = _pbService.pb;

      final registro = await pb.collection('animales').getOne(
            widget.animal.id,
            expand: 'sector,especie,estado',
          );

      List<NotaHistorial> notas = [];
      if (AuthHelper.puedeVerNotas) {
        final notasResult = await pb.collection('notas_historial').getFullList(
              filter: "animal = '${widget.animal.id}'",
              expand: 'tipo',
              sort: '-fecha',
            );
        notas = notasResult.map(NotaHistorial.fromRecord).toList();
      }

      final fotosResult = await pb.collection('fotos').getFullList(
            filter: "animal = '${widget.animal.id}' && nota = ''",
            sort: '-created',
          );

      setState(() {
        _animal = Animal.fromRecord(registro);
        _registroCrudo = registro;
        _notas = notas;
        _fotos = fotosResult.map(Foto.fromRecord).toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Widget _buildAlertaBanner(Animal a) {
    if (a.alerta != 'rojo' && a.alerta != 'amarillo') return const SizedBox.shrink();
    final color = a.alerta == 'rojo' ? AppColors.rojo : AppColors.amarillo;
    final texto = a.alerta == 'rojo' ? 'Precaucion: ver detalle en Sobre el animal' : 'Aviso: ver detalle en Sobre el animal';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Future<void> _confirmarBorrado() async {
    final a = _animal ?? widget.animal;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado'),
        content: Text('Seguro que queres borrar a ${a.nombre}? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.rojo)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _pbService.pb.collection('animales').delete(widget.animal.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _animal ?? widget.animal;

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
                      MaterialPageRoute(builder: (_) => AltaPage(animalExistente: _registroCrudo)),
                    );
                    if (resultado == true) {
                      _seModifico = true;
                      _cargarDatos();
                    }
                  },
                ),
              if (AuthHelper.puedeBorrar)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmarBorrado,
                ),
            ],
          ),
          body: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.madera.withOpacity(0.15),
                                child: Text(
                                  a.nombre.isNotEmpty ? a.nombre[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 36, color: AppColors.madera, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(a.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              _buildAlertaBanner(a),
                            ],
                          ),
                        ),
                        const TabBar(
                          labelColor: AppColors.verde,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.verde,
                          tabs: [
                            Tab(text: 'Datos'),
                            Tab(text: 'Sobre el animal'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildTabDatos(a),
                              _buildTabSobre(a),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Future<void> _subirFotoGeneral(List<int> bytes) async {
    setState(() => _subiendoFoto = true);
    try {
      await FotoService.subirFoto(animalId: widget.animal.id, bytes: Uint8List.fromList(bytes));
      await _cargarDatos();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir foto: $e')));
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Future<void> _abrirFormularioNota({NotaHistorial? notaExistente}) async {
    final a = _animal ?? widget.animal;
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NotaFormPage(animalId: a.id, animalNombre: a.nombre, notaExistente: notaExistente),
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
        content: const Text('Seguro que queres borrar esta nota? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar', style: TextStyle(color: AppColors.rojo)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _pbService.pb.collection('notas_historial').delete(nota.id);
      _cargarDatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar la nota: $e')),
        );
      }
    }
  }

  Widget _buildTabDatos(Animal a) {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            children: [
              DatoItem(icono: Icons.pets, label: 'Especie', valor: a.especieNombre),
              DatoItem(icono: Icons.cake_outlined, label: 'Edad', valor: a.edad),
              DatoItem(icono: Icons.favorite_outline, label: 'Estado', valor: formatearEtiqueta(a.estadoNombre)),
              DatoItem(icono: Icons.map_outlined, label: 'Sector', valor: a.sectorNombre),
              DatoItem(icono: Icons.calendar_today_outlined, label: 'Llegada', valor: a.fechaLlegada),
              DatoItem(icono: Icons.restaurant_outlined, label: 'Dieta', valor: a.dieta),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (AuthHelper.puedeSubirFotos)
                SeleccionarFotoButton(texto: 'Agregar', cargando: _subiendoFoto, onFotoSeleccionada: _subirFotoGeneral),
            ],
          ),
          const SizedBox(height: 10),
          if (_fotos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin fotos cargadas todavia', style: TextStyle(fontSize: 13)),
            )
          else
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _fotos.length,
                itemBuilder: (context, index) {
                  final f = _fotos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () async {
                        final resultado = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => FotoViewerPage(foto: f)));
                        if (resultado == true) _cargarDatos();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(f.url, width: 90, height: 90, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (AuthHelper.puedeVerNotas) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (AuthHelper.puedeCrearNotas)
                  TextButton.icon(
                    onPressed: () => _abrirFormularioNota(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar nota'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_notas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Sin notas cargadas todavia', style: TextStyle(fontSize: 13)),
              )
            else
              ..._notas.map((n) => NotaHistorialCard(
                    nota: n,
                    onEditar: () => _abrirFormularioNota(notaExistente: n),
                    onBorrar: () => _confirmarBorradoNota(n),
                  )),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTabSobre(Animal a) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Descripcion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(a.descripcion.isEmpty ? 'Sin descripcion cargada' : a.descripcion, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 24),
        const Text('Historia de llegada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Text(a.historiaLlegada.isEmpty ? 'Sin historia cargada' : a.historiaLlegada, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 40),
      ],
    );
  }
}
