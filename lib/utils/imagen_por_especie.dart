const Map<String, String> _imagenesPorEspecie = {
  'vaca': 'assets/icons/vaca_icon.png',
  'toro': 'assets/icons/toro_icon.png',
  'cabra': 'assets/icons/cabra_icon.png',
  'oveja': 'assets/icons/oveja_icon.png',
  'chancho': 'assets/icons/chancho_icon.png',
  'pato': 'assets/icons/pato_icon.png',
  'gallina': 'assets/icons/gallina_icon.png',
  'conejo': 'assets/icons/conejo_icon.png',
};

String? imagenPorEspecie(String especieNombre) {
  return _imagenesPorEspecie[especieNombre.toLowerCase().trim()];
}
