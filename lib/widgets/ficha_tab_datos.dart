import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/foto.dart';
import '../models/nota_historial.dart';
import '../services/auth_helper.dart';
import '../utils/formatear_fecha.dart';
import '../utils/text_format.dart';
import 'aviso_dialog.dart';
import 'dato_item.dart';
import 'nota_historial_card.dart';
import 'seleccionar_foto_button.dart';

class FichaTabDatos extends StatelessWidget {
  final Animal animal;
  final List<Foto> fotos;
  final List<NotaHistorial> notas;
  final Map<String, List<Foto>> fotosPorNota;
  final bool subiendoFoto;
  final Future<void> Function() onRefresh;
  final void Function(List<int> bytes) onSubirFoto;
  final Future<void> Function(Foto foto) onTapFoto;
  final VoidCallback onAgregarNota;
  final void Function(NotaHistorial nota) onEditarNota;
  final void Function(NotaHistorial nota) onBorrarNota;

  const FichaTabDatos({
    super.key,
    required this.animal,
    required this.fotos,
    required this.notas,
    required this.fotosPorNota,
    required this.subiendoFoto,
    required this.onRefresh,
    required this.onSubirFoto,
    required this.onTapFoto,
    required this.onAgregarNota,
    required this.onEditarNota,
    required this.onBorrarNota,
  });

  /// animal.fechaLlegada ya viene limpio (yyyy-MM-dd) desde el modelo;
  /// aca solo la reformateamos a dd/mm/aaaa para mostrarla.
  String _formatearLlegada(String fechaLlegada) {
    if (fechaLlegada.isEmpty) return '';
    final parseada = DateTime.tryParse(fechaLlegada);
    return parseada != null ? formatearFecha(parseada) : fechaLlegada;
  }

  void _mostrarDetalle(BuildContext context, String label, String valor) {
    mostrarAviso(context, titulo: label, mensaje: valor.isEmpty ? '-' : valor);
  }

  @override
  Widget build(BuildContext context) {
    final llegada = _formatearLlegada(animal.fechaLlegada);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            children: [
              DatoItem(
                icono: Icons.pets,
                label: 'Especie',
                valor: animal.especieNombre,
                onTap: () => _mostrarDetalle(context, 'Especie', animal.especieNombre),
              ),
              DatoItem(
                icono: Icons.cake_outlined,
                label: 'Edad',
                valor: animal.edad,
                onTap: () => _mostrarDetalle(context, 'Edad', animal.edad),
              ),
              if (!AuthHelper.esVisita)
                DatoItem(
                  icono: Icons.favorite_outline,
                  label: 'Estado',
                  valor: formatearEtiqueta(animal.estadoNombre),
                  onTap: () => _mostrarDetalle(context, 'Estado', formatearEtiqueta(animal.estadoNombre)),
                ),
              DatoItem(
                icono: Icons.map_outlined,
                label: 'Sector',
                valor: animal.sectorNombre,
                onTap: () => _mostrarDetalle(context, 'Sector', animal.sectorNombre),
              ),
              if (!AuthHelper.esVisita)
                DatoItem(
                  icono: Icons.calendar_today_outlined,
                  label: 'Llegada',
                  valor: llegada,
                  onTap: () => _mostrarDetalle(context, 'Llegada', llegada),
                ),
              if (!AuthHelper.esVisita)
                DatoItem(
                  icono: Icons.restaurant_outlined,
                  label: 'Dieta',
                  valor: animal.dieta,
                  onTap: () => _mostrarDetalle(context, 'Dieta', animal.dieta),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (AuthHelper.puedeSubirFotos)
                SeleccionarFotoButton(texto: 'Agregar', cargando: subiendoFoto, onFotoSeleccionada: onSubirFoto),
            ],
          ),
          const SizedBox(height: 10),
          if (fotos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Sin fotos cargadas todavia', style: TextStyle(fontSize: 13)),
            )
          else
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  final f = fotos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => onTapFoto(f),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(f.url, width: 90, height: 90, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (AuthHelper.puedeVerNotas) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (AuthHelper.puedeCrearNotas)
                  TextButton.icon(
                    onPressed: onAgregarNota,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Agregar nota'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (notas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Sin notas cargadas todavia', style: TextStyle(fontSize: 13)),
              )
            else
              ...notas.map((n) => NotaHistorialCard(
                    nota: n,
                    onEditar: () => onEditarNota(n),
                    onBorrar: () => onBorrarNota(n),
                    fotos: fotosPorNota[n.id] ?? [],
                  )),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
