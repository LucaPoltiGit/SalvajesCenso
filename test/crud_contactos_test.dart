import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  late PocketBase pb;
  late PocketBase pbEstandar;
  late PocketBase pbVisita;

  Map<String, dynamic> contactoBody() => {
        'nombre': 'Test Contacto',
        'telefono': '11-2222-3333',
        'email': 'test.contacto@example.com',
        'mensaje': 'Mensaje de prueba para test de integracion',
      };

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
  });

  group('Contactos - casos buenos', () {
    test('Visita puede crear un contacto', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      expect(registro.id, isNotEmpty);
      expect(registro.data['nombre'], 'Test Contacto');
      expect(registro.data['telefono'], isNotEmpty);
      expect(registro.data['email'], isNotEmpty);
      expect(registro.data['mensaje'], isNotEmpty);

      await pb.collection('contactos').delete(registro.id);
    });

    test('Estandar puede crear un contacto', () async {
      final registro = await pbEstandar.collection('contactos').create(body: contactoBody());

      expect(registro.id, isNotEmpty);
      expect(registro.data['nombre'], 'Test Contacto');

      await pb.collection('contactos').delete(registro.id);
    });

    test('Admin puede listar todos los contactos y encontrar uno recien creado', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      final listado = await pb.collection('contactos').getFullList();
      expect(listado.any((r) => r.id == registro.id), isTrue);

      await pb.collection('contactos').delete(registro.id);
    });

    test('Admin puede ver (getOne) un contacto especifico por id', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      final leido = await pb.collection('contactos').getOne(registro.id);
      expect(leido.id, registro.id);
      expect(leido.data['nombre'], 'Test Contacto');

      await pb.collection('contactos').delete(registro.id);
    });
  });

  group('Contactos - casos malos', () {
    test('Estandar no puede listar contactos', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      final listado = await pbEstandar.collection('contactos').getFullList();
      expect(listado.any((r) => r.id == registro.id), isFalse);

      await pb.collection('contactos').delete(registro.id);
    });

    test('Visita no puede listar contactos', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      final listado = await pbVisita.collection('contactos').getFullList();
      expect(listado.any((r) => r.id == registro.id), isFalse);

      await pb.collection('contactos').delete(registro.id);
    });

    test('Estandar no puede ver (getOne) un contacto especifico creado por otro usuario', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      expect(
        () => pbEstandar.collection('contactos').getOne(registro.id),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('contactos').delete(registro.id);
    });

    test('Estandar no puede borrar un contacto', () async {
      final registro = await pbVisita.collection('contactos').create(body: contactoBody());

      expect(
        () => pbEstandar.collection('contactos').delete(registro.id),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('contactos').delete(registro.id);
    });
  });
}
