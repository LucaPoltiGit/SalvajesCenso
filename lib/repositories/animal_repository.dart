import 'package:pocketbase/pocketbase.dart';
import '../models/animal.dart';
import '../services/pocketbase_service.dart';

class AnimalRepository {
  final PocketBase _pb = PocketbaseService.instance.pb;

  static const String _filtroAutomaticosAccesoRapido = "estado.nombre = 'enfermo' || estado.nombre = 'cuidado_especial'";

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
    // Si no se eligio un estado especifico, excluimos fallecidos por
    // defecto (el usuario los ve a proposito via el filtro "Los que ya
    // no estan", que si pasa estado: 'fallecido').
    final excluirEstadoEfectivo = estado == null
        ? (excluirEstado ?? 'fallecido')
        : excluirEstado;
    final resultado = await _pb.collection('animales').getFullList(
          expand: 'sector,especie,estado',
          sort: sort,
          filter: _armarFiltro(
            nombre: nombre,
            especie: especie,
            estado: estado,
            sector: sector,
            alerta: alerta,
            excluirEstado: excluirEstadoEfectivo,
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

  /// Combina los animales enfermos/en cuidado especial (automaticos) con los
  /// favoritos personales del usuario logueado (accesos_rapidos), deduplicando
  /// por id. Toda esta logica vive aca para que la pantalla solo orqueste.
  Future<List<Animal>> listarAccesoRapido() async {
    final userId = _pb.authStore.model?.id;

    final automaticos = await _pb.collection('animales').getFullList(
          filter: _filtroAutomaticosAccesoRapido,
          expand: 'sector,especie,estado',
        );

    List<RecordModel> favoritos = [];
    final idsOcultos = <String>{};

    if (userId != null) {
      final registrosUsuario = await _pb.collection('accesos_rapidos').getFullList(
            filter: "users = '$userId'",
            expand: 'animales.sector,animales.especie,animales.estado',
          );

      for (final r in registrosUsuario) {
        final oculto = r.data['oculto'] == true;
        final animalId = r.data['animales'] as String?;
        if (oculto && animalId != null) {
          idsOcultos.add(animalId);
          continue;
        }
        final animalExpand = r.expand['animales'];
        if (!oculto && animalExpand != null && animalExpand.isNotEmpty) {
          favoritos.add(animalExpand.first);
        }
      }
    }

    final vistos = <String>{};
    final resultado = <Animal>[];
    for (final r in [...automaticos, ...favoritos]) {
      if (idsOcultos.contains(r.id)) continue;
      if (vistos.contains(r.id)) continue;
      vistos.add(r.id);
      resultado.add(Animal.fromRecord(r));
    }
    return resultado;
  }

  /// Ids de los animales que aparecen automaticamente en el acceso rapido
  /// (enfermo o cuidado especial), para que la pantalla de gestion de
  /// favoritos pueda marcarlos como no editables sin duplicar el filtro.
  Future<Set<String>> listarIdsAutomaticosAccesoRapido() async {
    final automaticos = await _pb.collection('animales').getFullList(
          filter: _filtroAutomaticosAccesoRapido,
        );
    return automaticos.map((r) => r.id).toSet();
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

  Future<int> contarPorSector(String nombreSector) async {
    final resultado = await _pb.collection('animales').getList(
          page: 1,
          perPage: 1,
          filter: "sector.nombre = '$nombreSector' && estado.nombre != 'fallecido'",
        );
    return resultado.totalItems;
  }

  Future<Map<String, int>> contarPorSectores(List<String> nombres) async {
    final resultados = await Future.wait(nombres.map(contarPorSector));
    return Map.fromIterables(nombres, resultados);
  }
}
