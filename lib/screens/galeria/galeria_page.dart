import 'package:flutter/material.dart';
import '../../models/foto.dart';
import '../../repositories/foto_repository.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_strings.dart';
import '../../widgets/buscador_debounced.dart';
import '../foto/foto_viewer_page.dart';

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final _pbService = PocketbaseService.instance;
  final _fotoRepo = FotoRepository();

  List<Foto> _fotos = [];
  bool _cargando = true;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarFotos();
  }

  void _onBusquedaCambiada(String valor) {
    _busqueda = valor;
    _cargarFotos();
  }

  Future<void> _cargarFotos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _pbService.ensureAuth();
      final fotos = await _fotoRepo.listarParaGaleria(busqueda: _busqueda);
      setState(() {
        _fotos = fotos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.galeriaDeFotos)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BuscadorDebounced(
              hint: 'Buscar por nombre de animal',
              onCambio: _onBusquedaCambiada,
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _fotos.isEmpty
                        ? const Center(child: Text('No hay fotos cargadas'))
                        : RefreshIndicator(
                            onRefresh: _cargarFotos,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 130,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: _fotos.length,
                              itemBuilder: (context, index) {
                                final f = _fotos[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final resultado = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(builder: (_) => FotoViewerPage(foto: f)),
                                    );
                                    if (resultado == true) _cargarFotos();
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(f.url, fit: BoxFit.cover),
                                      ),
                                      if (f.notaId != null)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                            child: const Icon(Icons.edit_note, size: 12, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
