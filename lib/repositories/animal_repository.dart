import 'package:pocketbase/pocketbase.dart';
import '../models/animal.dart';
import '../services/pocketbase_service.dart';

class AnimalRepository {
  final PocketBase _pb = PocketbaseService.instance.pb;

  String? _armarFiltro({
    String? nombre,
    String? especie,
    String? estado,
    String? sector,
    String? alerta,
    String? excluirEstado,
  }) {
    final condiciones = <String>[];
    if (nombre != null && nombre.isNotEmpty) condiciones.add("nombre ~ '$nombre'");
    if (especie != null) condiciones.add("especie.nombre = '$especie'");
    if (estado != null) condiciones.add("estado.nombre = '$estado'");
    if (sector != null) condiciones.add("sector.nombre = '$sector'");
    if (alerta != null) condiciones.add("alerta = '$alerta'");
    if (excluirEstado != null) condiciones.add("estado.nombre != '$excluirEstado'");
    if (condiciones.isEmpty) return null;
    return condiciones.join(' && ');
  }

  Future<List<Animal>> listar({
    String? nombre,
    String? especie,
    String? estado,
    String? sector,
    String? alerta,
    String? excluirEstado,
    String sort = 'nombre',
  }) async {
    final resultado = await _pb.collection('animales').getFullList(
          expand: 'sector,especie,estado',
          sort: sort,
          filter: _armarFiltro(
            nombre: nombre,
            especie: especie,
            estado: estado,
            sector: sector,
            alerta: alerta,
            excluirEstado: excluirEstado,
          ),
        );
    return resultado.map(Animal.fromRecord).toList();
  }

  Future<int> contar({String? estadoIgual, String? estadoDistinto}) async {
    final condiciones = <String>[];
    if (estadoIgual != null) condiciones.add("estado.nombre = '$estadoIgual'");
    if (estadoDistinto != null) condiciones.add("estado.nombre != '$estadoDistinto'");
    final filtro = condiciones.isEmpty ? null : condiciones.join(' && ');
    final resultado = await _pb.collection('animales').getList(page: 1, perPage: 1, filter: filtro);
    return resultado.totalItems;
  }

  Future<Animal> obtenerPorId(String id) async {
    final registro = await _pb.collection('animales').getOne(id, expand: 'sector,especie,estado');
    return Animal.fromRecord(registro);
  }

  /// Devuelve el RecordModel crudo (no un Animal) porque AltaPage necesita
  /// los ids de relacion (especie/sector/estado) tal cual estan guardados
  /// para precargar los dropdowns del formulario de edicion.
  Future<RecordModel> obtenerRecordCrudo(String id) async {
    return _pb.collection('animales').getOne(id, expand: 'sector,especie,estado');
  }

  /// Solo para alimentar ActividadItem.animalNuevo, que necesita la fecha de
  /// creacion cruda del registro (dato que Animal no modela).
  Future<List<RecordModel>> listarRecientesCrudo(int cantidad) async {
    final resultado = await _pb.collection('animales').getList(page: 1, perPage: cantidad, sort: '-created');
    return resultado.items;
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    final body = {
      ...datos,
      'creado_por': _pb.authStore.model?.id,
    };
    await _pb.collection('animales').create(body: body);
  }

  Future<void> editar(String id, Map<String, dynamic> datos) async {
    await _pb.collection('animales').update(id, body: datos);
  }

  Future<void> borrar(String id) async {
    await _pb.collection('animales').delete(id);
  }
}
