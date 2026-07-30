import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  late PocketBase pb;
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
}
