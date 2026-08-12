import 'package:flutter/material.dart';

class AppIcons {
  AppIcons._();

  // Navegacion (bottom nav) - version normal (no visita)
  static const IconData principal = Icons.home_outlined;
  static const IconData principalActivo = Icons.home;
  static const IconData censo = Icons.pets_outlined;
  static const IconData censoActivo = Icons.pets;
  static const IconData notas = Icons.edit_note_outlined;
  static const IconData notasActivo = Icons.edit_note;
  static const IconData sectores = Icons.map_outlined;
  static const IconData sectoresActivo = Icons.map;
  static const IconData ayuda = Icons.favorite_outline;
  static const IconData ayudaActivo = Icons.favorite;

  // Menu hamburguesa
  static const IconData menuGaleria = Icons.photo_library_outlined;
  static const IconData menuAyuda = Icons.favorite_outline;
  static const IconData menuQuieroAyudar = Icons.volunteer_activism_outlined;
  static const IconData menuContactos = Icons.contact_mail_outlined;
  static const IconData menuCategorias = Icons.category_outlined;
  static const IconData menuUsuarios = Icons.people_outline;
  static const IconData menuAjustes = Icons.settings_outlined;
  static const IconData menuCerrarSesion = Icons.logout;

  // Navegacion general
  static const IconData backArrow = Icons.arrow_back;

  // Acciones (eliminar/descargar/compartir/copiar)
  static const IconData eliminar = Icons.delete_outline;
  static const IconData descargar = Icons.download_outlined;
  static const IconData compartir = Icons.share_outlined;
  static const IconData copiar = Icons.copy_outlined;
}
