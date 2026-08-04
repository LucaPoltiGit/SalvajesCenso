String mensajeErrorAmigable(Object error) {
  final texto = error.toString();

  if (texto.contains('Failed to authenticate')) {
    return 'Email o contrasena incorrectos.';
  }
  if (texto.contains('oldPassword')) {
    return 'La contrasena actual ingresada es incorrecta.';
  }
  if (texto.contains('SocketException') ||
      texto.contains('Connection refused') ||
      texto.contains('tiempo de espera') ||
      texto.contains('TimeoutException')) {
    return 'No se pudo conectar al servidor. Revisa tu conexion e intenta de nuevo.';
  }
  if (texto.contains('validation_required')) {
    return 'Falta completar un campo obligatorio.';
  }
  if (texto.contains('validation_invalid_email') ||
      texto.contains('invalid email')) {
    return 'El email ingresado no es valido.';
  }
  if (texto.contains('404')) {
    return 'No se encontro el registro solicitado.';
  }
  if (texto.contains('403') ||
      texto.contains('not allowed') ||
      texto.contains('Only superusers')) {
    return 'No tenes permiso para hacer esta accion.';
  }
  if (texto.contains('unique')) {
    return 'Ya existe un registro con ese dato (por ejemplo, ese email ya esta en uso).';
  }

  return 'Ocurrio un error inesperado. Intenta de nuevo.';
}
