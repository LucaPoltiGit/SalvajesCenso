import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/nota_historial.dart';
import '../../services/pocketbase_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/dato_item.dart';
import '../../widgets/nota_historial_card.dart';
import '../../utils/text_format.dart';

class FichaPage extends StatefulWidget {
  final Animal animal;
  const FichaPage({super.key, required this.animal});

  @override
  State<FichaPage> createState() => _FichaPageState();
}

class _FichaPageState extends State<FichaPage> {
  final _pbService = PocketbaseService.instance;

  Animal? _animal;
  List<NotaHistorial> _notas = [];
  bool _cargando = true;
  String? _error;

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

      final notasResult = await pb.collection('notas_historial').getFullList(
            filter: "animal = '${widget.animal.id}'",
            expand: 'tipo',
            sort: '-fecha',
          );

      setState(() {
        _animal = Animal.fromRecord(registro);
        _notas = notasResult.map(NotaHistorial.fromRecord).toList();
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

  @override
  Widget build(BuildContext context) {
    final a = _animal ?? widget.animal;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(a.nombre)),
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
    );
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
          const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          if (_notas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Sin notas cargadas todavia', style: TextStyle(fontSize: 13)),
            )
          else
            ..._notas.map((n) => NotaHistorialCard(nota: n)),
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
