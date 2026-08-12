import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/temas_disponibles.dart';

class ThemeService extends ChangeNotifier {
  ThemeService._internal();
  static final ThemeService instance = ThemeService._internal();

  String _temaActualId = temasDisponibles.first.id;
  String get temaActualId => _temaActualId;

  DefinicionTema get temaActual =>
      temasDisponibles.firstWhere((t) => t.id == _temaActualId, orElse: () => temasDisponibles.first);

  Future<void> cargarTemaGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString('tema_seleccionado');
    if (guardado != null && temasDisponibles.any((t) => t.id == guardado)) {
      _temaActualId = guardado;
    }
    _aplicar();
  }

  Future<void> cambiarTema(String id) async {
    if (!temasDisponibles.any((t) => t.id == id)) return;
    _temaActualId = id;
    _aplicar();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tema_seleccionado', id);
  }

  void _aplicar() {
    final t = temaActual;
    AppColors.verde = t.verde;
    AppColors.madera = t.madera;
    AppColors.fondo = t.fondo;
    AppColors.textoPrincipal = t.textoPrincipal;
    AppColors.brillo = t.brillo;
  }
}
