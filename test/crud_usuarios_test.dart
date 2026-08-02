import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  late String url;
  late PocketBase pb;
  late PocketBase pbEstandar;
  late PocketBase pbVisita;

  int contadorEmail = 0;
  String emailTemporal() {
    contadorEmail++;
    return 'test.usuario.temp.${DateTime.now().millisecondsSinceEpoch}.$contadorEmail@example.com';
  }

  Future<RecordModel> crearUsuarioTemporal({String rol = 'estandar', bool bloqueado = false}) {
    return pb.collection('users').create(body: {
      'name': 'Test Usuario Temporal',
      'email': emailTemporal(),
      'password': 'Temporal123',
      'passwordConfirm': 'Temporal123',
      'rol': rol,
      'bloqueado': bloqueado,
    });
  }

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';

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

  group('Usuarios - casos buenos', () {
    test('Admin puede crear un usuario nuevo y el usuario puede loguearse despues', () async {
      final email = emailTemporal();
      const password = 'Temporal123';
      final creado = await pb.collection('users').create(body: {
        'name': 'Test Usuario Nuevo',
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'rol': 'estandar',
        'bloqueado': false,
      });
      expect(creado.id, isNotEmpty);

      final pbNuevo = PocketBase(url);
      final auth = await pbNuevo.collection('users').authWithPassword(email, password);
      expect(auth.record.id, creado.id);

      await pb.collection('users').delete(creado.id);
    });

    test('Admin puede listar todos los usuarios y encontrar el recien creado', () async {
      final creado = await crearUsuarioTemporal();

      final listado = await pb.collection('users').getFullList();
      expect(listado.any((u) => u.id == creado.id), isTrue);

      await pb.collection('users').delete(creado.id);
    });

    test('Admin puede cambiar el rol de un usuario existente', () async {
      final creado = await crearUsuarioTemporal(rol: 'estandar');

      final actualizado = await pb.collection('users').update(creado.id, body: {'rol': 'admin'});
      expect(actualizado.data['rol'], 'admin');

      final releido = await pb.collection('users').getOne(creado.id);
      expect(releido.data['rol'], 'admin');

      await pb.collection('users').delete(creado.id);
    });

    test('Admin puede bloquear y luego desbloquear a un usuario', () async {
      final creado = await crearUsuarioTemporal();

      final bloqueado = await pb.collection('users').update(creado.id, body: {'bloqueado': true});
      expect(bloqueado.data['bloqueado'], true);

      final desbloqueado = await pb.collection('users').update(creado.id, body: {'bloqueado': false});
      expect(desbloqueado.data['bloqueado'], false);

      await pb.collection('users').delete(creado.id);
    });

    test('Admin puede borrar un usuario', () async {
      final creado = await crearUsuarioTemporal();

      await pb.collection('users').delete(creado.id);

      expect(
        () => pb.collection('users').getOne(creado.id),
        throwsA(isA<ClientException>()),
      );
    });

    test('Un usuario puede ver y actualizar su propio registro', () async {
      final miId = pbEstandar.authStore.model!.id;
      final nombreOriginal = pbEstandar.authStore.model!.data['name'] ?? '';
      const nombreTemporal = 'Estandar Nombre Actualizado Test';

      final visto = await pbEstandar.collection('users').getOne(miId);
      expect(visto.id, miId);

      final actualizado = await pbEstandar.collection('users').update(miId, body: {'name': nombreTemporal});
      expect(actualizado.data['name'], nombreTemporal);

      final releido = await pbEstandar.collection('users').getOne(miId);
      expect(releido.data['name'], nombreTemporal);

      // Restauramos el nombre original: PB_TEST_ESTANDAR es un usuario fijo
      // compartido con otros archivos de test, no debe quedar modificado.
      await pb.collection('users').update(miId, body: {'name': nombreOriginal});
    });
  });

  group('Usuarios - casos malos', () {
    test('Estandar no puede crear usuarios', () async {
      final email = emailTemporal();
      expect(
        () => pbEstandar.collection('users').create(body: {
          'name': 'Intento Estandar',
          'email': email,
          'password': 'Temporal123',
          'passwordConfirm': 'Temporal123',
          'rol': 'estandar',
          'bloqueado': false,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Estandar no puede listar todos los usuarios', () async {
      // Comportamiento real observado: la regla de List/Search rechaza cada
      // fila (no es un gate 403 aunque solo referencie @request.auth.rol),
      // PocketBase la aplica como filtro por registro. Con ningun registro
      // matcheando para un no-admin, la respuesta es 200 con lista vacia,
      // no una excepcion.
      final listado = await pbEstandar.collection('users').getFullList();
      expect(listado, isEmpty);
    });

    test('Visita no puede crear usuarios', () async {
      final email = emailTemporal();
      expect(
        () => pbVisita.collection('users').create(body: {
          'name': 'Intento Visita',
          'email': email,
          'password': 'Temporal123',
          'passwordConfirm': 'Temporal123',
          'rol': 'estandar',
          'bloqueado': false,
        }),
        throwsA(isA<ClientException>()),
      );
    });

    test('Un usuario bloqueado igual puede autenticarse a nivel PocketBase (el rechazo lo aplica el cliente Flutter)', () async {
      // PocketBase no tiene conocimiento del campo 'bloqueado': es un campo
      // de negocio nuestro. authWithPassword va a tener exito igual; quien
      // rechaza la sesion es PocketbaseService.login() en la app (borra el
      // token y lanza una excepcion). Este test solo puede verificar la
      // parte que la API si controla: que el registro quedo bloqueado.
      final email = emailTemporal();
      const password = 'Temporal123';
      final creado = await pb.collection('users').create(body: {
        'name': 'Test Usuario Bloqueado',
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'rol': 'estandar',
        'bloqueado': true,
      });

      final pbNuevo = PocketBase(url);
      final auth = await pbNuevo.collection('users').authWithPassword(email, password);
      expect(auth.record.id, creado.id);
      expect(auth.record.data['bloqueado'], true);

      await pb.collection('users').delete(creado.id);
    });

    test('Un usuario estandar no puede actualizar el registro de otro usuario', () async {
      final creado = await crearUsuarioTemporal();

      expect(
        () => pbEstandar.collection('users').update(creado.id, body: {'name': 'Hackeado'}),
        throwsA(isA<ClientException>()),
      );

      await pb.collection('users').delete(creado.id);
    });
  });
}
