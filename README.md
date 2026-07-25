# Santuario App

Aplicacion de gestion para un santuario de animales rescatados (mas de 300 residentes: bovinos, caprinos, ovinos, gallinas, cerdos, patos). Permite censar animales, ver su historial medico y de notas, organizarlos por sectores, y gestionar fotos.

## Stack tecnologico
- Flutter (Android + Windows, un solo codebase)
- PocketBase como backend (self-hosted)
- SQLite local (offline-first) - pendiente de implementar
- flutter_dotenv para variables de entorno

## Estado actual
Estructura de navegacion completa (shell con bottom nav bar de 4 pestañas: Principal, Censo, Historial, Sectores, mas menu hamburguesa y FAB de agregar animal).

Pantallas funcionales:
- Principal: estadisticas rapidas, acceso rapido a animales, actividad reciente (ultima semana), accesos a Sectores y Galeria
- Censo: lista de animales conectada a PocketBase con expand de relaciones (sector, especie, estado)
- Resto de pantallas (Ficha, Historial, Sectores, Galeria, Categorias, Ajustes, Alta): placeholders con navegacion funcional, sin logica de datos todavia

Modelo de datos en PocketBase (colecciones): sectores, animales, notas_historial, fotos, especies, estados, tipos_nota, mas rol agregado a la coleccion users (admin / estandar) para permisos de edicion de categorias.

## Configuracion local
1. Copiar .env.example a .env y completar con los valores reales (URL de PocketBase, credenciales)
2. flutter pub get
3. flutter run -d windows (o -d android, -d chrome)

Requiere PocketBase corriendo por separado (no incluido en este repo).
