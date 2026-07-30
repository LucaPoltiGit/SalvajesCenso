import 'package:flutter/material.dart';
import '../models/nota_historial.dart';
import '../theme/app_colors.dart';
import '../services/auth_helper.dart';
import '../utils/text_format.dart';

class NotaHistorialCard extends StatelessWidget {
  final NotaHistorial nota;
  final VoidCallback? onEditar;
  final VoidCallback? onBorrar;

  const NotaHistorialCard({super.key, required this.nota, this.onEditar, this.onBorrar});

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

  String get _fechaTexto {
    final dia = nota.fecha.day.toString().padLeft(2, '0');
    final mes = nota.fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${nota.fecha.year}';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatearEtiqueta(nota.tipoNombre),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _colorTipo),
              ),
              Row(
                children: [
                  Text(_fechaTexto, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
        ],
      ),
    );
  }
}
