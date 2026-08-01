import 'package:pocketbase/pocketbase.dart';
import '../models/nota_historial.dart';
import '../services/pocketbase_service.dart';

class NotaRepository {
  final PocketBase _pb = PocketbaseService.instance.pb;

  Future<List<NotaHistorial>> listarPorAnimal(String animalId) async {
    final resultado = await _pb.collection('notas_historial').getFullList(
          filter: "animal = '$animalId'",
          expand: 'tipo',
          sort: '-fecha',
        );
    return resultado.map(NotaHistorial.fromRecord).toList();
  }

  Future<List<NotaHistorial>> listarConFiltros({
    String? busquedaAnimal,
    String? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final condiciones = <String>[];
    if (busquedaAnimal != null && busquedaAnimal.isNotEmpty) {
      condiciones.add("animal.nombre ~ '$busquedaAnimal'");
    }
    if (tipo != null) {
      condiciones.add("tipo.nombre = '$tipo'");
    }
    if (fechaDesde != null) {
      final f = fechaDesde.toIso8601String().split('T')[0];
      condiciones.add("fecha >= '$f 00:00:00'");
    }
    if (fechaHasta != null) {
      final f = fechaHasta.toIso8601String().split('T')[0];
      condiciones.add("fecha <= '$f 23:59:59'");
    }
    final filtro = condiciones.isEmpty ? null : condiciones.join(' && ');

    final resultado = await _pb.collection('notas_historial').getFullList(
          expand: 'tipo,animal',
          sort: '-fecha',
          filter: filtro,
        );
    return resultado.map(NotaHistorial.fromRecord).toList();
  }

  /// Solo para alimentar ActividadItem.nota, que necesita la fecha de
  /// creacion cruda del registro (dato que NotaHistorial no modela).
  Future<List<RecordModel>> listarRecientesCrudo(int cantidad) async {
    final resultado = await _pb.collection('notas_historial').getList(
          page: 1,
          perPage: cantidad,
          sort: '-created',
          expand: 'animal',
        );
    return resultado.items;
  }

  Future<String> crear({
    required String animalId,
    required String tipoId,
    required String contenido,
    required DateTime fecha,
  }) async {
    final creada = await _pb.collection('notas_historial').create(body: {
      'animal': animalId,
      'tipo': tipoId,
      'contenido': contenido,
      'fecha': fecha.toIso8601String(),
      'autor': _pb.authStore.model?.id,
    });
    return creada.id;
  }

  Future<void> editar({
    required String id,
    required String animalId,
    required String tipoId,
    required String contenido,
    required DateTime fecha,
  }) async {
    await _pb.collection('notas_historial').update(id, body: {
      'animal': animalId,
      'tipo': tipoId,
      'contenido': contenido,
      'fecha': fecha.toIso8601String(),
    });
  }

  Future<void> borrar(String id) async {
    await _pb.collection('notas_historial').delete(id);
  }
}
