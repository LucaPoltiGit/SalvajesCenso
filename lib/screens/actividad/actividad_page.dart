import 'package:flutter/material.dart';
import '../../models/actividad_item.dart';
import '../../repositories/actividad_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_strings.dart';
import '../../utils/formatear_fecha.dart';
import '../../widgets/actividad_filtros_bar.dart';
import '../../widgets/actividad_tile.dart';

class ActividadPage extends StatefulWidget {
  const ActividadPage({super.key});

  @override
  State<ActividadPage> createState() => _ActividadPageState();
}

class _ActividadPageState extends State<ActividadPage> {
  List<ActividadItem> _items = [];
  bool _cargando = true;
  String? _error;

  String? _quienFiltro;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

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
      final items = await ActividadRepository.obtenerReciente(diasAtras: null, maxPorTipo: 50);
      setState(() {
        _items = items;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  List<String> get _quienesDisponibles {
    final unicos = _items.map((i) => i.quien).whereType<String>().toSet().toList();
    unicos.sort();
    return unicos;
  }

  List<ActividadItem> get _itemsFiltrados {
    return _items.where((i) {
      if (_quienFiltro != null && i.quien != _quienFiltro) return false;
      if (_fechaDesde != null) {
        final inicioDia = DateTime(_fechaDesde!.year, _fechaDesde!.month, _fechaDesde!.day);
        if (i.fecha.isBefore(inicioDia)) return false;
      }
      if (_fechaHasta != null) {
        final finDia = DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59);
        if (i.fecha.isAfter(finDia)) return false;
      }
      return true;
    }).toList();
  }

  Map<String, List<ActividadItem>> get _agrupadoPorFecha {
    final mapa = <String, List<ActividadItem>>{};
    for (final item in _itemsFiltrados) {
      final clave = formatearFecha(item.fecha);
      mapa.putIfAbsent(clave, () => []).add(item);
    }
    return mapa;
  }

  Future<void> _elegirFecha(bool esDesde) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        if (esDesde) {
          _fechaDesde = fecha;
        } else {
          _fechaHasta = fecha;
        }
      });
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _quienFiltro = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final agrupado = _agrupadoPorFecha;
    final claves = agrupado.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.actividad)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    ActividadFiltrosBar(
                      quienes: _quienesDisponibles,
                      quienSeleccionado: _quienFiltro,
                      fechaDesde: _fechaDesde,
                      fechaHasta: _fechaHasta,
                      onQuienSeleccionado: (q) => setState(() => _quienFiltro = q),
                      onElegirFecha: _elegirFecha,
                      onLimpiar: _limpiarFiltros,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: claves.isEmpty
                          ? const Center(child: Text('Sin actividad registrada'))
                          : RefreshIndicator(
                              onRefresh: _cargar,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: claves.length,
                                itemBuilder: (context, index) {
                                  final clave = claves[index];
                                  final itemsDelDia = agrupado[clave]!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 8, bottom: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.verde.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          clave,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.verde),
                                        ),
                                      ),
                                      ...itemsDelDia.map((item) => ActividadTile(item: item)),
                                    ],
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
