import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  late PocketBase pb;
  late PocketBase pbEstandar;
  late PocketBase pbVisita;

  Map<String, dynamic> campaniaBody({String? titulo}) => {
        'titulo': titulo ?? 'Test Campania Ayuda',
        'problema': 'Problema de prueba para test de integracion',
        'monto_necesario': 1000,
        'monto_recaudado': 0,
        'alias_donacion': 'test.alias.donacion',
        'estado': true,
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

  group('Ayuda - casos buenos', () {
    test('Admin puede crear una campania de ayuda', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      expect(registro.id, isNotEmpty);
      expect(registro.data['titulo'], 'Test Campania Ayuda');
      expect(registro.data['problema'], isNotEmpty);
      expect((registro.data['monto_necesario'] as num).toInt(), 1000);
      expect(registro.data['alias_donacion'], 'test.alias.donacion');
      expect(registro.data['estado'], true);

      await pb.collection('ayuda').delete(registro.id);
    });

    test('Admin puede editar una campania existente', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      final editado = await pb.collection('ayuda').update(registro.id, body: {'monto_recaudado': 500});
      expect((editado.data['monto_recaudado'] as num).toInt(), 500);

      await pb.collection('ayuda').delete(registro.id);
    });

    test('Admin puede borrar una campania', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      await pb.collection('ayuda').delete(registro.id);

      expect(
        () => pb.collection('ayuda').getOne(registro.id),
        throwsA(isA<ClientException>()),
      );
    });

    test('Estandar puede leer (getOne) una campania creada por admin', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      final leido = await pbEstandar.collection('ayuda').getOne(registro.id);
      expect(leido.id, registro.id);
      expect(leido.data['titulo'], 'Test Campania Ayuda');

      await pb.collection('ayuda').delete(registro.id);
    });

    test('Visita puede leer (getOne) una campania creada por admin', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      final leido = await pbVisita.collection('ayuda').getOne(registro.id);
      expect(leido.id, registro.id);
      expect(leido.data['titulo'], 'Test Campania Ayuda');

      await pb.collection('ayuda').delete(registro.id);
    });

    test('Estandar y visita pueden listar campanias activas sin error', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      final listadoEstandar = await pbEstandar.collection('ayuda').getFullList(filter: 'estado = true');
      expect(listadoEstandar.any((r) => r.id == registro.id), isTrue);

      final listadoVisita = await pbVisita.collection('ayuda').getFullList(filter: 'estado = true');
      expect(listadoVisita.any((r) => r.id == registro.id), isTrue);

      await pb.collection('ayuda').delete(registro.id);
    });
  });

  group('Ayuda - casos malos', () {
    test('Estandar no puede crear una campania', () async {
      expect(
        () => pbEstandar.collection('ayuda').create(body: campaniaBody()),
        throwsA(isA<ClientException>()),
      );
    });

    test('Visita no puede crear una campania', () async {
      expect(
        () => pbVisita.collection('ayuda').create(body: campaniaBody()),
        throwsA(isA<ClientException>()),
      );
    });

    test('Estandar no puede editar una campania existente', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      expect(
        () => pbEstandar.collection('ayuda').update(registro.id, body: {'monto_recaudado': 999}),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('ayuda').delete(registro.id);
    });

    test('Estandar no puede borrar una campania existente', () async {
      final registro = await pb.collection('ayuda').create(body: campaniaBody());

      expect(
        () => pbEstandar.collection('ayuda').delete(registro.id),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('ayuda').delete(registro.id);
    });
  });
}
