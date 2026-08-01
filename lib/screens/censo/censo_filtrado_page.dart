import 'package:flutter/material.dart';
import '../../widgets/filtro_censo_sheet.dart';
import 'censo_page.dart';

class CensoFiltradoPage extends StatelessWidget {
  final String titulo;
  final FiltrosCenso filtro;

  const CensoFiltradoPage({super.key, required this.titulo, required this.filtro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: CensoPage(filtroInicial: filtro),
    );
  }
}
