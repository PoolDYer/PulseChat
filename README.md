# PulseChat

## Objetivo
Aplicacion de mensajeria basica para iOS construida con SwiftUI. Demuestra flujo completo de autenticacion, lista de chats, detalle de mensajes, integracion con Firebase y manejo de errores/conectividad.

## Requisitos
- Xcode 15 o superior
- iOS 17+ (SwiftData)

## Instalacion y ejecucion
1. Abrir el proyecto en Xcode.
2. Seleccionar un simulador iPhone.
3. Run (Cmd + R).

## Configuracion de Firebase
- Agregar `GoogleService-Info.plist` al target de Xcode (el archivo ya esta en `PulseChat/GoogleService-Info.plist`).
- Verificar que este en Build Phases > Copy Bundle Resources.
- Inicializar Firebase en `PulseChatApp` (ya incluido en codigo).
- Requiere Firebase Auth y Firestore via Swift Package Manager.

## Dependencias principales
- SwiftUI
- FirebaseAuth
- FirebaseFirestore
- UserNotifications

## Seguridad
- Sesion persistida por Firebase Auth.
- UID de Firebase como identificador de usuario.

## Build de desarrollo
- Simulador iOS desde Xcode (Product > Build).
- Opcional: `xcodebuild -scheme PulseChat -destination 'platform=iOS Simulator,name=iPhone 15' build`
