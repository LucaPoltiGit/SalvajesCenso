import 'package:flutter/material.dart';
import '../models/nota_historial.dart';
import '../models/foto.dart';
import '../theme/app_colors.dart';
import '../services/auth_helper.dart';
import '../utils/text_format.dart';
import '../utils/formatear_fecha.dart';
import '../screens/foto/foto_viewer_page.dart';

class NotaHistorialCard extends StatelessWidget {
  final NotaHistorial nota;
  final VoidCallback? onEditar;
  final VoidCallback? onBorrar;
  final String? animalNombre;
  final List<Foto> fotos;

  const NotaHistorialCard({
    super.key,
    required this.nota,
    this.onEditar,
    this.onBorrar,
    this.animalNombre,
    this.fotos = const [],
  });

  Color get _colorTipo {
    switch (nota.tipoNombre) {
      case 'medica':
        return AppColors.rojo;
      case 'comida':
        return AppColors.amarillo;
      case 'cambio_sector':
      case 'cambio_estado':
        return AppColors.madera;
      default:
        return AppColors.verde;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mostrarMenu = AuthHelper.puedeEditarNotas || AuthHelper.puedeBorrarNotas;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: _colorTipo, width: 3)),
        color: AppColors.fondo,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (animalNombre != null) ...[
            Text(animalNombre!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.verde)),
            const SizedBox(height: 4),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatearEtiqueta(nota.tipoNombre),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _colorTipo),
              ),
              Row(
                children: [
                  Text(formatearFecha(nota.fecha), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (mostrarMenu)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, size: 16),
                      onSelected: (v) {
                        if (v == 'editar' && onEditar != null) onEditar!();
                        if (v == 'borrar' && onBorrar != null) onBorrar!();
                      },
                      itemBuilder: (context) => [
                        if (AuthHelper.puedeEditarNotas)
                          const PopupMenuItem(value: 'editar', child: Text('Editar')),
                        if (AuthHelper.puedeBorrarNotas)
                          const PopupMenuItem(value: 'borrar', child: Text('Borrar')),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(nota.contenido, style: const TextStyle(fontSize: 13)),
          if (fotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  final f = fotos[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FotoViewerPage(foto: f)));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(f.url, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
