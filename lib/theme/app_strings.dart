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

  // Mensajes de "sin resultados"
  static const sinAnimalesEncontrados = 'No se encontraron animales';

  // Validaciones y labels compartidos entre varias pantallas
  static const campoObligatorio = 'Este campo es obligatorio';
  static const labelNombre = 'Nombre';
  static const labelEmail = 'Email';
  static const guardarCambios = 'Guardar cambios';
  static const guardar = 'Guardar';

  // Ajustes
  static const nombreVacio = 'El nombre no puede estar vacio';
  static const nombreActualizado = 'Nombre actualizado';
  static const contrasenaActualizada = 'Contrasena actualizada';
  static const completaLosTresCampos = 'Completa los 3 campos';
  static const nuevaContrasenaCorta =
      'La nueva contrasena debe tener al menos 8 caracteres';
  static const contrasenasNoCoinciden = 'Las contrasenas nuevas no coinciden';
  static const guardarNombre = 'Guardar nombre';
  static const cambiarContrasena = 'Cambiar contrasena';
  static const tema = 'Tema';

  // Alta de animal
  static const guardarResidente = 'Guardar residente';
  static const basico = 'Basico';
  static const detalle = 'Detalle';
  static const agregarFotoPerfilOpcional = 'Agregar foto de perfil (opcional)';
  static const cambiarFoto = 'Cambiar foto';
  static String animalGuardadoFotoFallo(String error) =>
      'El animal se guardo, pero la foto no se pudo subir: $error';

  // Formulario de ayuda
  static const labelTitulo = 'Titulo';
  static const labelProblema = 'Problema';
  static const labelMontoNecesario = 'Monto necesario (opcional)';
  static const labelMontoRecaudado = 'Monto recaudado';
  static const labelAliasDonacion = 'Alias de donacion';
  static const crearCampania = 'Crear campania';

  // Categorias (tabs)
  static const tabEspecies = 'Especies';
  static const tabEstados = 'Estados';
  static const tabTiposNota = 'Tipos de nota';

  // Contacto
  static const labelNombreOpcional = 'Nombre (opcional)';
  static const labelTelefonoOpcional = 'Telefono (opcional)';
  static const labelEmailOpcional = 'Email (opcional)';
  static const labelMensajeOpcional = 'Mensaje (opcional)';
  static const graciasTitulo = 'Gracias!';
  static const teVamosAContactar = 'Te vamos a contactar pronto.';

  // Foto
  static const borrarFoto = 'Borrar foto';
  static const confirmarBorrarFoto =
      'Segura que queres borrar esta foto? Esta accion no se puede deshacer.';

  // Login
  static const labelContrasena = 'Contrasena';
  static const ingresar = 'Ingresar';
  static const soyVisitante = 'Soy visitante';
  static const separadorO = 'o';

  // Nota
  static const labelContenido = 'Contenido';
  static const guardarNota = 'Guardar nota';

  // Crear usuario
  static const debeTenerAlMenosOchoCaracteres =
      'Debe tener al menos 8 caracteres';

  // Principal
  static const accesoRapidoTitulo = 'Acceso rapido';
  static const actividadReciente = 'Actividad reciente';
  static const verTodo = 'Ver todo';
  static const sinActividadUltimaSemana = 'Sin actividad en la ultima semana';
  static const verSectores = 'Ver sectores';
}
