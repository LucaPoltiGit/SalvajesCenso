String formatearEtiqueta(String texto) {
  if (texto.isEmpty) return texto;
  final conEspacios = texto.replaceAll('_', ' ');
  return conEspacios[0].toUpperCase() + conEspacios.substring(1);
}
