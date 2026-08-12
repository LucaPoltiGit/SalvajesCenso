import 'package:flutter/material.dart';
import '../screens/censo/censo_filtrado_page.dart';
import 'filtro_censo_sheet.dart';
import 'stat_card.dart';

class PrincipalStatsRow extends StatelessWidget {
  final int totalAnimales;
  final int totalEnfermos;
  final int totalCuidadoEspecial;

  const PrincipalStatsRow({
    super.key,
    required this.totalAnimales,
    required this.totalEnfermos,
    required this.totalCuidadoEspecial,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCard(
              numero: '$totalAnimales',
              label: 'Total de animales',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CensoFiltradoPage(titulo: 'Todos los animales', filtro: FiltrosCenso()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              numero: '$totalEnfermos',
              label: 'Enfermo',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CensoFiltradoPage(titulo: 'Enfermos', filtro: FiltrosCenso(estado: 'enfermo')),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              numero: '$totalCuidadoEspecial',
              label: 'Cuidado especial',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CensoFiltradoPage(titulo: 'Cuidado especial', filtro: FiltrosCenso(estado: 'cuidado_especial')),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
