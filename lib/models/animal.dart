import 'package:pocketbase/pocketbase.dart';

class Animal {
  final String id;
  final String nombre;
  final String especieNombre;
  final String estadoNombre;
  final String alerta;
  final String sectorNombre;
  final String edad;
  final String fechaLlegada;
  final String dieta;
  final String descripcion;
  final String historiaLlegada;

  Animal({
    required this.id,
    required this.nombre,
    required this.especieNombre,
    required this.estadoNombre,
    required this.alerta,
    required this.sectorNombre,
    this.edad = '',
    this.fechaLlegada = '',
    this.dieta = '',
    this.descripcion = '',
    this.historiaLlegada = '',
  });

  factory Animal.fromRecord(RecordModel record) {
    String nombreRelacion(String campo, String fallback) {
      final expand = record.expand[campo];
      if (expand != null && expand.isNotEmpty) {
        return expand.first.data['nombre'] ?? fallback;
      }
      return fallback;
    }

    String fecha = record.data['fecha_llegada'] ?? '';
    // PocketBase devuelve la fecha con hora, separada por 'T' al escribirla
    // pero por un espacio al leerla de vuelta - nos quedamos con los
    // primeros 10 caracteres (yyyy-MM-dd) sin importar el separador.
    if (fecha.length >= 10) fecha = fecha.substring(0, 10);

    return Animal(
      id: record.id,
      nombre: record.data['nombre'] ?? '(sin nombre)',
      especieNombre: nombreRelacion('especie', 'Sin especie'),
      estadoNombre: nombreRelacion('estado', 'bien'),
      alerta: record.data['alerta'] ?? '',
      sectorNombre: nombreRelacion('sector', 'Sin sector'),
      edad: record.data['edad'] ?? '',
      fechaLlegada: fecha,
      dieta: record.data['dieta'] ?? '',
      descripcion: record.data['descripcion'] ?? '',
      historiaLlegada: record.data['historia_llegada'] ?? '',
    );
  }
}
