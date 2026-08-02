import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  late PocketBase pb;
  late PocketBase pbEstandar;
  late PocketBase pbVisita;

  String? especieIdValida;
  String? sectorIdValido;
  String? estadoIdValido;
  String? animalTempId;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    final url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';

    pb = PocketBase(url);
    await pb.collection('users').authWithPassword(
          dotenv.env['PB_TEST_EMAIL'] ?? '',
          dotenv.env['PB_TEST_PASSWORD'] ?? '',
        );

    pbEstandar = PocketBase(url);
    await pbEstandar.collection('users').authWithPassword(
          dotenv.env['PB_TEST_ESTANDAR_EMAIL'] ?? '',
          dotenv.env['PB_TEST_ESTANDAR_PASSWORD'] ?? '',
        );

    pbVisita = PocketBase(url);
    await pbVisita.collection('users').authWithPassword(
          dotenv.env['PB_TEST_VISITA_EMAIL'] ?? '',
          dotenv.env['PB_TEST_VISITA_PASSWORD'] ?? '',
        );

    final especies = await pb.collection('especies').getList(page: 1, perPage: 1);
    final sectores = await pb.collection('sectores').getList(page: 1, perPage: 1);
    final estados = await pb.collection('estados').getList(page: 1, perPage: 1);

    if (especies.items.isEmpty || sectores.items.isEmpty || estados.items.isEmpty) {
      throw Exception('Necesitas al menos 1 especie, 1 sector y 1 estado cargados en PocketBase');
    }

    especieIdValida = especies.items.first.id;
    sectorIdValido = sectores.items.first.id;
    estadoIdValido = estados.items.first.id;

    final animalTemp = await pb.collection('animales').create(body: {
      'nombre': 'Test Accesos Rapidos Animal Temporal',
      'especie': especieIdValida,
      'sector': sectorIdValido,
      'estado': estadoIdValido,
    });
    animalTempId = animalTemp.id;
  });

  tearDownAll(() async {
    if (animalTempId != null) {
      try {
        await pb.collection('animales').delete(animalTempId!);
      } catch (_) {}
    }
  });

  group('Accesos rapidos - casos buenos', () {
    test('Crear un acceso rapido favorito (oculto false)', () async {
      final userId = pb.authStore.model!.id;
      final registro = await pb.collection('accesos_rapidos').create(body: {
        'users': userId,
        'animales': animalTempId,
        'oculto': false,
      });
      expect(registro.id, isNotEmpty);
      expect(registro.data['oculto'], false);
      await pb.collection('accesos_rapidos').delete(registro.id);
    });

    test('Crear un acceso rapido oculto (oculto true)', () async {
      final userId = pb.authStore.model!.id;
      final registro = await pb.collection('accesos_rapidos').create(body: {
        'users': userId,
        'animales': animalTempId,
        'oculto': true,
      });
      expect(registro.data['oculto'], true);
      await pb.collection('accesos_rapidos').delete(registro.id);
    });

    test('Listar solo trae los accesos rapidos del usuario logueado', () async {
      final userId = pb.authStore.model!.id;
      final registro = await pb.collection('accesos_rapidos').create(body: {
        'users': userId,
        'animales': animalTempId,
        'oculto': false,
      });

      final listado = await pb.collection('accesos_rapidos').getFullList(
            filter: "users = '$userId'",
          );
      expect(listado.any((r) => r.id == registro.id), isTrue);
      expect(listado.every((r) => r.data['users'] == userId), isTrue);

      await pb.collection('accesos_rapidos').delete(registro.id);
    });

    test('Borrar un registro propio funciona', () async {
      final userId = pb.authStore.model!.id;
      final registro = await pb.collection('accesos_rapidos').create(body: {
        'users': userId,
        'animales': animalTempId,
        'oculto': false,
      });

      await pb.collection('accesos_rapidos').delete(registro.id);

      expect(
        () => pb.collection('accesos_rapidos').getOne(registro.id),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('Accesos rapidos - permisos', () {
    test('Un usuario no puede ver los accesos rapidos de otro usuario', () async {
      final adminUserId = pb.authStore.model!.id;
      final registro = await pb.collection('accesos_rapidos').create(body: {
        'users': adminUserId,
        'animales': animalTempId,
        'oculto': false,
      });

      expect(
        () => pbEstandar.collection('accesos_rapidos').getOne(registro.id),
        throwsA(isA<ClientException>()),
      );

      final listadoEstandar = await pbEstandar.collection('accesos_rapidos').getFullList(
            filter: "users = '$adminUserId'",
          );
      expect(listadoEstandar.any((r) => r.id == registro.id), isFalse);

      await pb.collection('accesos_rapidos').delete(registro.id);
    });

    test('Visita no puede crear un acceso rapido', () async {
      final visitaUserId = pbVisita.authStore.model!.id;
      expect(
        () => pbVisita.collection('accesos_rapidos').create(body: {
          'users': visitaUserId,
          'animales': animalTempId,
          'oculto': false,
        }),
        throwsA(isA<ClientException>()),
      );
    });
  });
}
