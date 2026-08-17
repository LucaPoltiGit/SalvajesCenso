# 🐐 Santuario App

Aplicación de gestión integral para un santuario de animales rescatados, con más de 300 residentes (bovinos, caprinos, ovinos, gallinas, cerdos, patos y conejos). Construida bajo un marco antiespecista: cada residente tiene nombre propio, historia, y su bienestar es el centro del diseño.

Desarrollada de punta a punta —desde el modelo de datos hasta el servidor de producción— para reemplazar el registro en papel/planillas sueltas por una herramienta real, usada a diario por voluntarios en el campo.

---

## ✨ Funcionalidades

**Censo de animales**
- Alta, edición y baja con formulario en 2 pasos (datos básicos + detalle opcional)
- Vista grilla y lista, búsqueda en tiempo real, filtros combinables (especie, estado, sector, alerta)
- Etiquetas de comportamiento (alerta roja/amarilla) visibles de un vistazo
- Fichas individuales con foto de perfil, historial médico cronológico y galería propia

**Mapa de sectores interactivo**
- Trazado sobre el plano real del predio (formas irregulares, no un grid genérico)
- Cada sector es tocable y navega al censo filtrado
- Referencias visuales (galpón, casas) sin función, solo orientación

**Historial y notas**
- Notas médicas, de alimentación, cambios de sector/estado, con fotos adjuntas
- Vista global con filtros por animal, tipo y rango de fechas, agrupada por día

**Sistema de donaciones ("Ayuda")**
- Campañas con objetivo de recaudación, barra de progreso, alias copiable con un toque
- Descarga de flyer/imagen de campaña para compartir

**Gestión de personas**
- 3 roles con permisos diferenciados: administrador, voluntario, visita
- Alta/edición/bloqueo de usuarios y de categorías (especies, estados, tipos de nota) desde la app
- Modo "visitante" sin fricción para quienes recorren el predio, con vista restringida (sin datos sensibles del censo)
- Formulario de contacto para quienes quieren sumarse como voluntarios o donantes

**Personalización**
- 3 temas visuales (verde, blanco y negro, oscuro), con arquitectura preparada para sumar más
- Accesos rápidos personalizables por usuario, más los casos críticos (enfermos/cuidado especial) siempre visibles

---

## 🛠️ Stack técnico

| Capa | Tecnología |
|---|---|
| App | Flutter (Android + Windows, un solo código base) |
| Backend | PocketBase (self-hosted, Go + SQLite) |
| Acceso remoto | Tailscale Funnel — HTTPS público sin exponer infraestructura propia |
| Servidor | Ubuntu Server 24.04 LTS, corriendo como servicio systemd, en hardware reutilizado |
| Testing | 6 suites de integración (permisos por rol) contra el backend real |

## 🏗️ Arquitectura

Separación estricta en capas, pensada para que una pantalla nunca hable directo con la base:

```
Pantallas (UI)  →  Repositorios  →  PocketbaseService  →  PocketBase
     ↑
 Widgets reutilizables
```

- **Pantallas**: solo estado y orquestación, cero lógica de negocio
- **Repositorios**: un archivo por colección, encapsulan cada consulta y regla de filtrado
- **Constantes centralizadas**: `AppColors`, `AppIcons`, `AppStrings`, `mensajesError` — un único lugar para tema visual, textos e idioma, íconos y mensajes de error legibles

## 🔐 Permisos por rol

| Acción | Admin | Voluntario | Visita |
|---|:---:|:---:|:---:|
| Ver censo y mapa | ✅ | ✅ | ✅ (vista reducida) |
| Cargar/editar animales | ✅ | ✅ | ❌ |
| Borrar animales | ✅ | ❌ | ❌ |
| Cargar notas y fotos | ✅ | ✅ | ❌ |
| Gestionar usuarios/categorías | ✅ | ❌ | ❌ |

Reglas aplicadas también del lado del servidor (API rules de PocketBase), no solo ocultas en la interfaz.

## 🧪 Testing

```
flutter test test/crud_animales_test.dart
flutter test test/crud_fotos_test.dart
flutter test test/crud_accesos_rapidos_test.dart
flutter test test/crud_usuarios_test.dart
flutter test test/crud_ayuda_test.dart
flutter test test/crud_contactos_test.dart
```

Cada suite valida casos válidos, casos inválidos, y el comportamiento real de los 3 roles contra un PocketBase corriendo en vivo — no mocks.

## 🚀 Puesta en marcha (desarrollo)

```bash
git clone <este-repositorio>
cd santuario_app
cp .env.example .env   # completar con la URL de tu PocketBase
flutter pub get
flutter run -d windows   # o -d chrome / -d <id-de-dispositivo-android>
```

Requiere una instancia de PocketBase corriendo por separado (no incluida en este repositorio).

## 📍 Estado del proyecto

**v1.0.0** — en producción, cargando el censo real de más de 300 animales.

Próximo en el roadmap: modo offline-first con sincronización diferida (para conectividad intermitente en el predio), backup automático, y un módulo de gestión de tareas para voluntarios.

---

*Construido por [Luca Polti](https://github.com/LucaPoltiGit) para un santuario que rescata vidas todos los días.*
