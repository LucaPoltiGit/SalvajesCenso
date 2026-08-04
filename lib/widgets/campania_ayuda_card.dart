import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/campania_ayuda.dart';
import '../repositories/ayuda_repository.dart';
import '../theme/app_colors.dart';
import '../services/auth_helper.dart';
import '../utils/mensajes_error.dart';

class CampaniaAyudaCard extends StatelessWidget {
  final CampaniaAyuda campania;
  final VoidCallback? onEditar;
  final VoidCallback? onBorrar;

  const CampaniaAyudaCard({
    super.key,
    required this.campania,
    this.onEditar,
    this.onBorrar,
  });

  Future<void> _copiarAlias(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: campania.aliasDonacion));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alias copiado')));
    }
  }

  Future<void> _descargarImagen(BuildContext context) async {
    if (campania.imagenUrl == null) return;
    try {
      await AyudaRepository.descargarYCompartirImagen(
        campania.imagenUrl!,
        campania.titulo,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeErrorAmigable(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.madera.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (campania.imagenUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                campania.imagenUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campania.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (AuthHelper.puedeGestionarAyuda)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (v) {
                          if (v == 'editar' && onEditar != null) onEditar!();
                          if (v == 'borrar' && onBorrar != null) onBorrar!();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'borrar', child: Text('Borrar')),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(campania.problema, style: const TextStyle(fontSize: 13)),
                if (campania.montoNecesario != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: campania.progreso,
                      minHeight: 8,
                      backgroundColor: AppColors.madera.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(AppColors.verde),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${campania.montoRecaudado.toStringAsFixed(0)} de \$${campania.montoNecesario!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.madera,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copiarAlias(context),
                        icon: const Icon(Icons.copy, size: 16),
                        label: Text(
                          campania.aliasDonacion,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (campania.imagenUrl != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _descargarImagen(context),
                        icon: const Icon(Icons.download_outlined),
                        color: AppColors.madera,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
