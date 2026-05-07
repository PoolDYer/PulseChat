# PulseChat - Documentacion tecnica

## Objetivo del proyecto
Aplicacion de mensajeria para iOS construida con SwiftUI. Demuestra autenticacion con email/password, lista y detalle de chats, persistencia local con SwiftData, sincronizacion con Firebase y manejo de estados de carga, error y conectividad.

## Alcance funcional (flujo principal)
- Login/registro con email y password.
- Lista de chats y busqueda de usuarios.
- Detalle del chat con envio, edicion y eliminacion de mensajes.
- Adjuntos de imagen desde camara o galeria.
- Notificaciones locales cuando llegan mensajes nuevos (desde la ultima vista).

## Arquitectura y capas (MVVM)
- Views (SwiftUI): pantallas y componentes UI.
- ViewModels: estado y acciones de UI con @Published.
- Repositories: acceso a datos (Firebase/SwiftData).
- Services: utilidades de red, permisos, notificaciones y seguridad.
- Persistence: SwiftData para cache local y modo offline.

## Navegacion
- `LoginView` -> `ChatListView` -> `ChatDetailView`.
- `ChatListView` -> `SearchUserView` -> `ChatDetailView`.
- NavigationStack y NavigationLink con destination por modelo.

## Consumo de datos (API)
- Firebase Auth para autenticacion.
- Firebase Firestore para chats y mensajes.
- Capa REST disponible (APIClient/MockAPIClient) con base `https://mockapi.io` para pruebas o integracion alternativa.

## Manejo de estados y errores
- Estados de carga en ViewModels (`isLoading`).
- Mensajes de error en UI (`ErrorView`).
- Estados vacios (`EmptyStateView`).
- Estados offline con `NetworkMonitor` y banner de aviso.

## Persistencia local
- SwiftData con entidades `ChatEntity`, `MessageEntity`, `UserEntity`.
- Sincronizacion Firestore -> SwiftData en repositorios.
- Uso de UserDefaults para `lastSeen` por chat.

## Seguridad y autenticacion
- Autenticacion basica con email/password via Firebase Auth.
- Sesion restaurada al iniciar la app (AuthViewModel).
- `KeychainManager` disponible para almacenar tokens de forma segura (no conectado al flujo actual).

## Permisos del dispositivo
- Solicitud al inicio:
  - Galeria (Photos).
  - Ubicacion (CoreLocation).
  - Notificaciones (UserNotifications).
- Requiere claves en Info.plist (configurar en Xcode):
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSLocationWhenInUseUsageDescription`

## Tema claro/oscuro
- Selector de tema con `ThemePickerView`.
- Preferencia persistida con AppStorage (`pulsechat.theme`).

## Idioma (i18n)
- Selector de idioma en login y dentro de la app (menu desplegable).
- Soporta Espanol, Ingles y Sistema.

## Dependencias principales
- SwiftUI
- SwiftData (iOS 17+)
- FirebaseAuth
- FirebaseFirestore
- Network (NWPathMonitor)
- UserNotifications
- AVFoundation / Photos / CoreLocation

## Requisitos tecnicos minimos (cumplimiento)
- Arquitectura: MVVM con separacion por capas.
- Navegacion: lista <-> detalle, busqueda -> detalle.
- API: Firebase Auth + Firestore (y REST opcional).
- Estados: loading, error, vacio, offline.
- Persistencia: SwiftData.
- Seguridad: Firebase Auth + Keychain helper.
- Permisos: camara, galeria, ubicacion, notificaciones.

## Extras valorados (estado)
- Tema claro/oscuro persistente: SI.
- Camara/galeria: SI.
- Notificaciones locales: SI.
- Mapas: NO.
- i18n: SI (es/en con Localizable.strings).
- Accesibilidad: SI (labels y hints basicos).
- Pruebas unitarias: NO (solo plantilla).
- CI/CD: NO.

## Instalacion y ejecucion
1. Abrir el proyecto en Xcode 15+.
2. Seleccionar un simulador iPhone con iOS 17+.
3. Run (Cmd + R).

## Configuracion de Firebase
1. Agregar `GoogleService-Info.plist` al target de Xcode (ya incluido en el repo).
2. Verificar que este en Build Phases > Copy Bundle Resources.
3. Asegurar que Firebase Auth y Firestore esten habilitados en el proyecto de Firebase.

## Build de desarrollo
- Xcode: Product > Build.
- CLI: `xcodebuild -scheme PulseChat -destination 'platform=iOS Simulator,name=iPhone 17' build`

## Estructura principal del proyecto
- App: ciclo de vida y entrada (`PulseChatApp`).
- Core: constantes, temas, componentes UI, seguridad y utils.
- Services: API, Firebase y persistencia.
- ViewModels: estado y logica de presentacion.
- Views: pantallas y flujo principal.

## Limitaciones y pendientes
- Accesibilidad avanzada pendiente (tests de VoiceOver, contrastes detallados).
- Pruebas unitarias no desarrolladas (solo plantilla).
- CI/CD no configurado.
