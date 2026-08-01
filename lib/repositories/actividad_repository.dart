import 'package:pocketbase/pocketbase.dart';
import '../models/actividad_item.dart';
import '../services/pocketbase_service.dart';

class ActividadRepository {
  static Future<List<ActividadItem>> obtenerReciente({int? diasAtras, int maxPorTipo = 20}) async {
    final pb = PocketbaseService.instance.pb;

    String? filtroFecha;
    if (diasAtras != null) {
      final corte = DateTime.now().subtract(Duration(days: diasAtras));
      filtroFecha = "created >= '${corte.toIso8601String()}'";
    }

    final animales = await pb.collection('animales').getList(
          page: 1,
          perPage: maxPorTipo,
          sort: '-created',
          filter: filtroFecha,
          expand: 'creado_por',
        );

    final notas = await pb.collection('notas_historial').getList(
          page: 1,
          perPage: maxPorTipo,
          sort: '-created',
          filter: filtroFecha,
          expand: 'animal,autor',
        );

    final fotos = await pb.collection('fotos').getList(
          page: 1,
          perPage: maxPorTipo,
          sort: '-created',
          filter: filtroFecha,
          expand: 'animal,subida_por',
        );

    final items = <ActividadItem>[
      ...animales.items.map(ActividadItem.animalNuevo),
      ...notas.items.map(ActividadItem.nota),
      ...fotos.items.map(ActividadItem.foto),
    ];
    items.sort((a, b) => b.fecha.compareTo(a.fecha));
    return items;
  }
}
