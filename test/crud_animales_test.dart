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

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    pb = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090');
    await pb.collection('users').authWithPassword(
          dotenv.env['PB_TEST_EMAIL'] ?? '',
          dotenv.env['PB_TEST_PASSWORD'] ?? '',
        );

    pbEstandar = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090');
    await pbEstandar.collection('users').authWithPassword(
          dotenv.env['PB_TEST_ESTANDAR_EMAIL'] ?? '',
          dotenv.env['PB_TEST_ESTANDAR_PASSWORD'] ?? '',
        );

    pbVisita = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090');
    await pbVisita.collection('users').authWithPassword(
          dotenv.env['PB_TEST_VISITA_EMAIL'] ?? '',
          dotenv.env['PB_TEST_VISITA_PASSWORD'] ?? '',
        );

    final especies = await pb.collection('especies').getList(page: 1, perPage: 1);
    final sectores = await pb.collection('sectores').getList(page: 1, perPage: 1);
    final estados = await pb.collection('estados').getList(page: 1, perPage: 1);

    if (especies.items.isEmpty || sectores.items.isEmpty || estados.items.isEmpty) {
      throw Exception('Necesitas al menos 1 especie, 1 sector y 1 estado cargados en PocketBase para correr estos tests');
    }

    especieIdValida = especies.items.first.id;
    sectorIdValido = sectores.items.first.id;
    estadoIdValido = estados.items.first.id;
  });

  group('Casos buenos', () {
    test('Crear animal con datos validos funciona', () async {
      final record = await pb.collection('animales').create(body: {
        'nombre': 'Test Animal Crear',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });

      expect(record.id, isNotEmpty);
      expect(record.data['nombre'], 'Test Animal Crear');

      await pb.collection('animales').delete(record.id);
    });

    test('Editar animal existente funciona', () async {
      final creado = await pb.collection('animales').create(body: {
        'nombre': 'Test Animal Editar',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });

      final editado = await pb.collection('animales').update(creado.id, body: {
        'nombre': 'Test Animal Editado',
        'edad': '5 anos',
      });

      expect(editado.data['nombre'], 'Test Animal Editado');
      expect(editado.data['edad'], '5 anos');

      await pb.collection('animales').delete(creado.id);
    });

    test('Borrar animal existente funciona', () async {
      final creado = await pb.collection('animales').create(body: {
        'nombre': 'Test Animal Borrar',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });

      await pb.collection('animales').delete(creado.id);

      expect(
        () => pb.collection('animales').getOne(creado.id),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('Casos malos', () {
    test('Crear animal sin nombre falla', () async {
      expect(
        () => pb.collection('animales').create(body: {
          'especie': especieIdValida,
          'sector': sectorIdValido,
          'estado': estadoIdValido,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Crear animal sin especie falla', () async {
      expect(
        () => pb.collection('animales').create(body: {
          'nombre': 'Test Sin Especie',
          'sector': sectorIdValido,
          'estado': estadoIdValido,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Crear animal con especie inexistente falla', () async {
      expect(
        () => pb.collection('animales').create(body: {
          'nombre': 'Test Especie Invalida',
          'especie': 'idquenoexiste123',
          'sector': sectorIdValido,
          'estado': estadoIdValido,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Crear animal sin autenticacion falla', () async {
      final pbSinAuth = PocketBase(dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090');

      expect(
        () => pbSinAuth.collection('animales').create(body: {
          'nombre': 'Test Sin Auth',
          'especie': especieIdValida,
          'sector': sectorIdValido,
          'estado': estadoIdValido,
        }),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('Permisos por rol', () {
    test('Admin puede crear, editar y borrar', () async {
      final creado = await pb.collection('animales').create(body: {
        'nombre': 'Test Rol Admin',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });
      expect(creado.id, isNotEmpty);

      final editado = await pb.collection('animales').update(creado.id, body: {'edad': '2 anos'});
      expect(editado.data['edad'], '2 anos');

      await pb.collection('animales').delete(creado.id);
      expect(
        () => pb.collection('animales').getOne(creado.id),
        throwsA(isA<ClientException>()),
      );
    });

    test('Estandar puede crear y editar, pero no borrar', () async {
      final creado = await pbEstandar.collection('animales').create(body: {
        'nombre': 'Test Rol Estandar',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });
      expect(creado.id, isNotEmpty);

      final editado = await pbEstandar.collection('animales').update(creado.id, body: {'edad': '3 anos'});
      expect(editado.data['edad'], '3 anos');

      expect(
        () => pbEstandar.collection('animales').delete(creado.id),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('animales').delete(creado.id);
    });

    test('Visita no puede crear', () async {
      expect(
        () => pbVisita.collection('animales').create(body: {
          'nombre': 'Test Rol Visita Crear',
          'especie': especieIdValida,
          'sector': sectorIdValido,
          'estado': estadoIdValido,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Visita puede ver pero no editar ni borrar', () async {
      final creado = await pb.collection('animales').create(body: {
        'nombre': 'Test Rol Visita Ver',
        'especie': especieIdValida,
        'sector': sectorIdValido,
        'estado': estadoIdValido,
      });

      final visto = await pbVisita.collection('animales').getOne(creado.id);
      expect(visto.id, creado.id);

      expect(
        () => pbVisita.collection('animales').update(creado.id, body: {'edad': '1 ano'}),
        throwsA(isA<ClientException>()),
      );

      expect(
        () => pbVisita.collection('animales').delete(creado.id),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('animales').delete(creado.id);
    });
  });
}
