import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<void> main() async {
  await pb.collection('users').authWithPassword('test@test.com', 'testtest');
  print('Autenticado.');

  await _limpiarColeccion('fotos');
  await _limpiarColeccion('notas_historial');
  await _limpiarColeccion('animales');
  await _limpiarColeccion('sectores');

  final sectores = <String, String>{};
  final especies = <String, String>{};
  final estados = <String, String>{};

  final registrosEspecies = await pb.collection('especies').getFullList();
  for (final r in registrosEspecies) {
    especies[r.data['nombre']] = r.id;
  }

  final registrosEstados = await pb.collection('estados').getFullList();
  for (final r in registrosEstados) {
    estados[r.data['nombre']] = r.id;
  }

  String idEspecie(String nombre) {
    final id = especies[nombre];
    if (id == null) {
      throw Exception('Especie no encontrada: $nombre');
    }
    return id;
  }

  String idEstado(String nombre) {
    final id = estados[nombre];
    if (id == null) {
      throw Exception('Estado no encontrado: $nombre');
    }
    return id;
  }

  final nombresSectores = [
    ['Cleo', ''],
    ['Barry', ''],
    ['Jane y Aldebaran', ''],
    ['Ovejas', ''],
    ['Cabras', ''],
    ['Falu', ''],
    ['Laguna', 'Sector de patos y gallinas'],
    ['Casita', 'Sector de conejos'],
    ['Guardia', 'Animales enfermos o con cuidados especiales'],
    ['Chanchos', ''],
  ];

  for (final s in nombresSectores) {
    final record = await pb.collection('sectores').create(body: {
      'nombre': s[0],
      'descripcion': s[1],
    });
    sectores[s[0]] = record.id;
    print('Sector creado: ${s[0]}');
  }

  Future<void> crearAnimal({
    required String nombre,
    required String especie,
    String? raza,
    required String sector,
    String estado = 'bien',
    String alerta = '',
    String descripcion = '',
  }) async {
    await pb.collection('animales').create(body: {
      'nombre': nombre,
      'especie': idEspecie(especie),
      if (raza != null) 'raza': raza,
      'sector': sectores[sector],
      'estado': idEstado(estado),
      'alerta': alerta,
      'descripcion': descripcion,
    });
    print('Animal creado: $nombre');
  }

  await crearAnimal(
    nombre: 'Cleo',
    especie: 'Chancho',
    raza: 'chancha (a confirmar)',
    sector: 'Cleo',
    alerta: 'rojo',
    descripcion: 'Muerde.',
  );

  await crearAnimal(nombre: 'Barry', especie: 'Toro', sector: 'Barry', alerta: 'rojo', descripcion: 'Puede atacar.');
  await crearAnimal(nombre: 'Regina', especie: 'Vaca', sector: 'Barry');

  await crearAnimal(nombre: 'Pancho', especie: 'Cabra', sector: 'Jane y Aldebaran');
  await crearAnimal(nombre: 'Blanca', especie: 'Chancho', sector: 'Jane y Aldebaran');
  await crearAnimal(
    nombre: 'Jane',
    especie: 'Vaca',
    sector: 'Jane y Aldebaran',
    alerta: 'amarillo',
    descripcion: 'Si tiene mucha hambre puede empujar.',
  );
  await crearAnimal(nombre: 'Aldebaran', especie: 'Toro', sector: 'Jane y Aldebaran');

  await crearAnimal(nombre: 'Tyron', especie: 'Chancho', sector: 'Ovejas');
  await crearAnimal(nombre: 'Locoto', especie: 'Chancho', sector: 'Ovejas');

  await crearAnimal(nombre: 'Turco', especie: 'Cabra', sector: 'Cabras');
  await crearAnimal(nombre: 'Diablito', especie: 'Cabra', sector: 'Cabras');
  await crearAnimal(nombre: 'Jimmy', especie: 'Cabra', sector: 'Cabras');
  await crearAnimal(
    nombre: 'Gothmo',
    especie: 'Cabra',
    sector: 'Cabras',
    alerta: 'amarillo',
    descripcion: 'Si tiene mucha hambre puede empujar.',
  );

  await crearAnimal(
    nombre: 'Falu',
    especie: 'Toro',
    sector: 'Falu',
    alerta: 'rojo',
    descripcion: 'Cada tanto, si le pinta, puede hacerte algo.',
  );
  await crearAnimal(
    nombre: 'Heracles',
    especie: 'Toro',
    sector: 'Falu',
    alerta: 'rojo',
    descripcion: 'Cada tanto, si le pinta, puede hacerte algo.',
  );

  await crearAnimal(nombre: 'Donald', especie: 'Pato', sector: 'Laguna');
  await crearAnimal(nombre: 'Lucas', especie: 'Pato', sector: 'Laguna');
  await crearAnimal(nombre: 'Pepita', especie: 'Gallina', sector: 'Laguna');
  await crearAnimal(nombre: 'Coco', especie: 'Gallina', sector: 'Laguna');

  await crearAnimal(nombre: 'Copito', especie: 'Conejo', raza: 'Conejo', sector: 'Casita');
  await crearAnimal(nombre: 'Canela', especie: 'Conejo', raza: 'Conejo', sector: 'Casita');
  await crearAnimal(nombre: 'Trufa', especie: 'Conejo', raza: 'Conejo', sector: 'Casita');

  await crearAnimal(
    nombre: 'Roma',
    especie: 'Cabra',
    sector: 'Guardia',
    estado: 'cuidado_especial',
    descripcion: 'No puede pararse sola, hay que ponerla en la caminadora.',
  );
  await crearAnimal(
    nombre: 'Ambar',
    especie: 'Cabra',
    sector: 'Guardia',
    estado: 'cuidado_especial',
    descripcion: 'Le cuesta caminar.',
  );

  await crearAnimal(
    nombre: 'Luna',
    especie: 'Chancho',
    sector: 'Chanchos',
    estado: 'cuidado_especial',
    descripcion: 'Le cuesta pararse pero esta cada dia mejor.',
  );
  await crearAnimal(nombre: 'Bombom', especie: 'Chancho', sector: 'Chanchos');
  await crearAnimal(nombre: 'Burbuja', especie: 'Chancho', sector: 'Chanchos');
  await crearAnimal(nombre: 'Bellota', especie: 'Chancho', sector: 'Chanchos');

  print('Listo! Datos de prueba cargados.');
}

Future<void> _limpiarColeccion(String nombre) async {
  final registros = await pb.collection(nombre).getFullList();
  for (final r in registros) {
    await pb.collection(nombre).delete(r.id);
  }
  print('Coleccion $nombre limpiada (${registros.length} registros borrados).');
}