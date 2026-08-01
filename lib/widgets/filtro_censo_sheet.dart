import 'package:flutter/material.dart';
import '../repositories/categoria_repository.dart';
import '../repositories/sector_repository.dart';
import '../theme/app_colors.dart';

class FiltrosCenso {
  final String? especie;
  final String? estado;
  final String? sector;
  final String? alerta;

  const FiltrosCenso({this.especie, this.estado, this.sector, this.alerta});

  bool get tieneFiltros => especie != null || estado != null || sector != null || alerta != null;
}

class FiltroCensoSheet extends StatefulWidget {
  final FiltrosCenso filtrosActuales;
  const FiltroCensoSheet({super.key, required this.filtrosActuales});

  @override
  State<FiltroCensoSheet> createState() => _FiltroCensoSheetState();
}

class _FiltroCensoSheetState extends State<FiltroCensoSheet> {
  final _especieRepo = CategoriaRepository('especies');
  final _estadoRepo = CategoriaRepository('estados');
  final _sectorRepo = SectorRepository();

  List<String> _especies = [];
  List<String> _estados = [];
  List<String> _sectores = [];
  bool _cargando = true;

  String? _especieSel;
  String? _estadoSel;
  String? _sectorSel;
  String? _alertaSel;

  @override
  void initState() {
    super.initState();
    _especieSel = widget.filtrosActuales.especie;
    _estadoSel = widget.filtrosActuales.estado;
    _sectorSel = widget.filtrosActuales.sector;
    _alertaSel = widget.filtrosActuales.alerta;
    _cargarOpciones();
  }

  Future<void> _cargarOpciones() async {
    final especies = await _especieRepo.listar();
    final estados = await _estadoRepo.listar();
    final sectores = await _sectorRepo.listar();
    setState(() {
      _especies = especies.map((e) => e.nombre).toList();
      _estados = estados.map((e) => e.nombre).toList();
      _sectores = sectores.map((e) => e.nombre).toList();
      _cargando = false;
    });
  }

  Widget _dropdown(String label, List<String> opciones, String? valor, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        value: valor,
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text('Todos')),
          ...opciones.map((o) => DropdownMenuItem(value: o, child: Text(o))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: _cargando
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filtros', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _dropdown('Especie', _especies, _especieSel, (v) => setState(() => _especieSel = v)),
                _dropdown('Estado', _estados, _estadoSel, (v) => setState(() => _estadoSel = v)),
                _dropdown('Sector', _sectores, _sectorSel, (v) => setState(() => _sectorSel = v)),
                _dropdown('Alerta', const ['rojo', 'amarillo'], _alertaSel, (v) => setState(() => _alertaSel = v)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, const FiltrosCenso());
                        },
                        child: const Text('Limpiar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
                        onPressed: () {
                          Navigator.pop(
                            context,
                            FiltrosCenso(
                              especie: _especieSel,
                              estado: _estadoSel,
                              sector: _sectorSel,
                              alerta: _alertaSel,
                            ),
                          );
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
