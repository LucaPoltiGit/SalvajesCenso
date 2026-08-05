class AppStrings {
  AppStrings._();

  // Titulos de pantallas (bottom nav)
  static const principal = 'Principal';
  static const censo = 'Censo';
  static const notas = 'Notas';
  static const sectores = 'Sectores';
  static const ayuda = 'Ayuda';

  // Titulos de pantallas (Navigator.push)
  static const agregarAnimal = 'Agregar animal';
  static const editarAnimal = 'Editar animal';
  static const crearUsuario = 'Crear usuario';
  static const actividad = 'Actividad';
  static const galeriaDeFotos = 'Galeria de fotos';
  static const gestionarCategorias = 'Gestionar categorias';
  static const gestionarUsuarios = 'Gestionar usuarios';
  static const ajustes = 'Ajustes';
  static const quieroAyudar = 'Quiero ayudar';
  static const contactosRecibidos = 'Contactos recibidos';
  static const nuevaCampania = 'Nueva campania';
  static const editarCampania = 'Editar campania';
  static const editarAccesosRapidos = 'Editar accesos rapidos';

  // Titulos de pantalla con datos dinamicos (el nombre del animal ya
  // formaba parte del texto real en el codigo, no son titulos fijos)
  static String agregarNota(String animalNombre) => 'Nota para $animalNombre';
  static String editarNota(String animalNombre) => 'Editar nota de $animalNombre';

  // Pantalla de gestion de categorias
  static const categoriaEnUso = 'Categoria en uso';
  static String categoriaEnUsoMensaje(int usos, String palabra) =>
      'No se puede borrar. Hay $usos $palabra usando esta categoria. '
      'Cambia esos registros a otra categoria antes de borrarla.';
  static const borrarCategoria = 'Borrar categoria';
  static String confirmarBorrarCategoria(String nombre) =>
      'Seguro que queres borrar "$nombre"? Esta accion no se puede deshacer.';
  static const sinCategoriasCargadas = 'Sin categorias cargadas todavia';

  // Labels de menu hamburguesa (si difieren del titulo de la pantalla)
  static const menuGaleria = 'Galeria de fotos';
  static const menuAyuda = 'Ayuda';
  static const menuQuieroAyudar = 'Quiero ayudar';
  static const menuContactosRecibidos = 'Contactos recibidos';
  static const menuGestionarCategorias = 'Gestionar categorias';
  static const menuGestionarUsuarios = 'Gestionar usuarios';
  static const menuAjustes = 'Ajustes';
  static const menuCerrarSesion = 'Cerrar sesion';
}
