import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../theme/app_colors.dart';

class AccesoRapidoListTile extends StatelessWidget {
  final Animal animal;
  final bool esAutomatico;
  final bool esFavorito;
  final bool visible;
  final VoidCallback onToggle;

  const AccesoRapidoListTile({
    super.key,
    required this.animal,
    required this.esAutomatico,
    required this.esFavorito,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(animal.nombre),
      subtitle: Text(
        esAutomatico
            ? '${animal.sectorNombre} - aparece automatico (enfermo o cuidado especial)'
            : animal.sectorNombre,
      ),
      trailing: Switch(
        value: visible,
        activeColor: AppColors.verde,
        onChanged: (_) => onToggle(),
      ),
    );
  }
}
