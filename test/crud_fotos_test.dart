import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

Uint8List _generarImagenDePrueba() {
  final imagen = img.Image(width: 4, height: 4);
  img.fill(imagen, color: img.ColorRgb8(120, 80, 40));
  return Uint8List.fromList(img.encodeJpg(imagen));
}

http.MultipartFile _archivoDePrueba() {
  return http.MultipartFile.fromBytes('imagen', _generarImagenDePrueba(), filename: 'test.jpg');
}

void main() {
  late PocketBase pb;
  late PocketBase pbEstandar;
  late PocketBase pbVisita;

  String? especieIdValida;
  String? sectorIdValido;
  String? estadoIdValido;
  String? tipoIdValido;
  String? animalTempId;
  String? notaTempId;

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
    final tipos = await pb.collection('tipos_nota').getList(page: 1, perPage: 1);

    if (especies.items.isEmpty || sectores.items.isEmpty || estados.items.isEmpty || tipos.items.isEmpty) {
      throw Exception('Necesitas al menos 1 especie, 1 sector, 1 estado y 1 tipo de nota cargados en PocketBase');
    }

    especieIdValida = especies.items.first.id;
    sectorIdValido = sectores.items.first.id;
    estadoIdValido = estados.items.first.id;
    tipoIdValido = tipos.items.first.id;

    final animalTemp = await pb.collection('animales').create(body: {
      'nombre': 'Test Fotos Animal Temporal',
      'especie': especieIdValida,
      'sector': sectorIdValido,
      'estado': estadoIdValido,
    });
    animalTempId = animalTemp.id;

    final notaTemp = await pb.collection('notas_historial').create(body: {
      'animal': animalTempId,
      'tipo': tipoIdValido,
      'contenido': 'Nota temporal para tests de fotos',
      'fecha': DateTime.now().toIso8601String(),
    });
    notaTempId = notaTemp.id;
  });

  tearDownAll(() async {
    if (notaTempId != null) {
      try {
        await pb.collection('notas_historial').delete(notaTempId!);
      } catch (_) {}
    }
    if (animalTempId != null) {
      try {
        await pb.collection('animales').delete(animalTempId!);
      } catch (_) {}
    }
  });

  group('Fotos - casos buenos', () {
    test('Admin puede subir foto general', () async {
      final foto = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      expect(foto.id, isNotEmpty);
      await pb.collection('fotos').delete(foto.id);
    });

    test('Estandar puede subir foto', () async {
      final foto = await pbEstandar.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      expect(foto.id, isNotEmpty);
      await pb.collection('fotos').delete(foto.id);
    });

    test('Foto se puede asociar a una nota', () async {
      final foto = await pb.collection('fotos').create(
        body: {'animal': animalTempId, 'nota': notaTempId},
        files: [_archivoDePrueba()],
      );
      expect(foto.data['nota'], notaTempId);
      await pb.collection('fotos').delete(foto.id);
    });

    test('Admin puede editar descripcion de una foto', () async {
      final foto = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      final editada = await pb.collection('fotos').update(foto.id, body: {'descripcion': 'Editada'});
      expect(editada.data['descripcion'], 'Editada');
      await pb.collection('fotos').delete(foto.id);
    });

    test('Admin puede borrar foto', () async {
      final foto = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      await pb.collection('fotos').delete(foto.id);
      expect(
        () => pb.collection('fotos').getOne(foto.id),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('Fotos - casos malos', () {
    test('Subir foto sin animal falla', () async {
      expect(
        () => pb.collection('fotos').create(body: {}, files: [_archivoDePrueba()]),
        throwsA(isA<ClientException>()),
      );
    });

    test('Subir foto sin imagen falla', () async {
      expect(
        () => pb.collection('fotos').create(body: {'animal': animalTempId}),
        throwsA(isA<ClientException>()),
      );
    });

    test('Estandar no puede borrar foto', () async {
      final foto = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      expect(
        () => pbEstandar.collection('fotos').delete(foto.id),
        throwsA(isA<ClientException>()),
      );
      await pb.collection('fotos').delete(foto.id);
    });

    test('Visita no puede crear foto', () async {
      expect(
        () => pbVisita.collection('fotos').create(
          body: {'animal': animalTempId},
          files: [_archivoDePrueba()],
        ),
        throwsA(isA<ClientException>()),
      );
    });
  });

  group('Fotos - permisos de visualizacion por rol', () {
    test('Visita ve fotos generales pero no fotos de notas', () async {
      final fotoGeneral = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      final fotoDeNota = await pb.collection('fotos').create(
        body: {'animal': animalTempId, 'nota': notaTempId},
        files: [_archivoDePrueba()],
      );

      final vistaGeneral = await pbVisita.collection('fotos').getOne(fotoGeneral.id);
      expect(vistaGeneral.id, fotoGeneral.id);

      expect(
        () => pbVisita.collection('fotos').getOne(fotoDeNota.id),
        throwsA(isA<ClientException>()),
      );

      final listado = await pbVisita.collection('fotos').getFullList(
        filter: "animal = '$animalTempId'",
      );
      expect(listado.any((f) => f.id == fotoDeNota.id), isFalse);
      expect(listado.any((f) => f.id == fotoGeneral.id), isTrue);

      await pb.collection('fotos').delete(fotoGeneral.id);
      await pb.collection('fotos').delete(fotoDeNota.id);
    });

    test('Estandar ve fotos generales y de notas por igual', () async {
      final fotoGeneral = await pb.collection('fotos').create(
        body: {'animal': animalTempId},
        files: [_archivoDePrueba()],
      );
      final fotoDeNota = await pb.collection('fotos').create(
        body: {'animal': animalTempId, 'nota': notaTempId},
        files: [_archivoDePrueba()],
      );

      final vistaGeneral = await pbEstandar.collection('fotos').getOne(fotoGeneral.id);
      final vistaDeNota = await pbEstandar.collection('fotos').getOne(fotoDeNota.id);
      expect(vistaGeneral.id, fotoGeneral.id);
      expect(vistaDeNota.id, fotoDeNota.id);

      await pb.collection('fotos').delete(fotoGeneral.id);
      await pb.collection('fotos').delete(fotoDeNota.id);
    });
  });
}
