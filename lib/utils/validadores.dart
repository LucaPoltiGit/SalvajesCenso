String? validadorRequerido(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
  return null;
}

String? validadorEmail(String? valor) {
  if (valor == null || valor.trim().isEmpty) return 'Este campo es obligatorio';
  if (!valor.contains('@')) return 'Ingresa un email valido';
  return null;
}
