# 📚 EduJuegos - Aplicación Educativa Flutter

**APP educativa 100% local** desarrollada para UNICLAS. Juego de completar palabras sin necesidad de internet.

---

## 🚀 Inicialización del Proyecto

### Prerrequisitos
- Flutter instalado (versión 3.0 o superior)
- Dart SDK
- Android Studio o VS Code
- Git (opcional)

### Paso 1: Crear el proyecto

```bash
# Navegar a tu carpeta de proyectos
cd /ruta/donde/quieres/el/proyecto

# Ejecutar el script de inicialización (guarda primero el script como init_edujuegos.sh)
chmod +x init_edujuegos.sh
./init_edujuegos.sh

# O crear manualmente:
flutter create edujuegos
cd edujuegos
```

### Paso 2: Instalar dependencias

```bash
# Agregar todas las dependencias necesarias
flutter pub add shared_preferences
flutter pub add sqflite
flutter pub add path_provider
flutter pub add provider
flutter pub add flutter_animate
flutter pub add google_fonts
flutter pub add lottie

# Actualizar dependencias
flutter pub get
```

### Paso 3: Estructura de carpetas

```bash
mkdir -p lib/models
mkdir -p lib/screens
mkdir -p lib/services
mkdir -p lib/widgets
mkdir -p lib/utils
mkdir -p assets/avatars
mkdir -p assets/data
mkdir -p assets/animations
```

---

## 📁 Estructura del Proyecto

```
edujuegos/
├── lib/
│   ├── main.dart                          # Punto de entrada
│   ├── models/
│   │   └── user_model.dart               # Modelos de datos
│   ├── services/
│   │   ├── auth_service.dart             # Autenticación local
│   │   ├── game_service.dart             # Lógica del juego
│   │   └── group_service.dart            # Gestión de grupos
│   ├── screens/
│   │   ├── splash_screen.dart            # Pantalla de carga
│   │   ├── login_screen.dart             # Inicio de sesión
│   │   ├── register_screen.dart          # Registro
│   │   ├── home_screen.dart              # Menú principal
│   │   ├── profile_screen.dart           # Perfil de usuario
│   │   ├── categories_screen.dart        # Selección de categoría
│   │   ├── game_screen.dart              # Juego principal
│   │   ├── groups_screen.dart            # Lista de grupos
│   │   ├── group_detail_screen.dart      # Chat del grupo
│   │   ├── ranking_screen.dart           # Rankings
│   │   └── teacher_panel_screen.dart     # Panel docente
│   └── widgets/                           # Widgets reutilizables
├── assets/
│   ├── avatars/                          # Imágenes de avatares
│   ├── data/
│   │   └── questions.json                # Base de datos de palabras
│   └── animations/                        # Animaciones Lottie
├── pubspec.yaml                          # Configuración del proyecto
└── README.md                             # Este archivo
```

---

## 📝 Copiar los Archivos

### 1. Actualizar pubspec.yaml
Reemplaza el contenido de `pubspec.yaml` con el archivo proporcionado.

### 2. Copiar archivos principales
Copia los siguientes archivos en sus respectivas ubicaciones:

- `lib/main.dart`
- `lib/models/user_model.dart`
- `lib/services/auth_service.dart`
- `lib/services/game_service.dart`
- `lib/services/group_service.dart`
- Todos los archivos de `lib/screens/`

### 3. Agregar assets

#### Archivo de preguntas (assets/data/questions.json)
El archivo ya está creado automáticamente con el script, pero puedes agregar más categorías y palabras.

#### Avatares (assets/avatars/)
Agrega imágenes PNG o JPG con nombres como:
- `default.png`
- `avatar1.png`
- `avatar2.png`
- `teacher.png`

Puedes usar emojis como avatares o descargar imágenes gratuitas de:
- https://www.flaticon.com
- https://openmoji.org

---

## ⚙️ Configuración

### Actualizar pubspec.yaml para incluir assets

Asegúrate de que `pubspec.yaml` tenga esta sección:

```yaml
flutter:
  uses-material-design: true
  
  assets:
    - assets/avatars/
    - assets/data/
    - assets/animations/
```

### Ejecutar el proyecto

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en un dispositivo específico
flutter run -d <device_id>
```

---

## 📦 Construir el APK

### APK de Debug (para pruebas)

```bash
flutter build apk --debug
```

El APK estará en: `build/app/outputs/flutter-apk/app-debug.apk`

### APK de Release (para distribución)

```bash
# APK de release
flutter build apk --release

# APK dividido por arquitectura (más pequeño)
flutter build apk --split-per-abi

# Bundle de Android (recomendado para Play Store)
flutter build appbundle
```

Los archivos estarán en:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### Instalar APK en dispositivo

```bash
# Conectar dispositivo por USB y habilitar depuración USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎮 Características Implementadas

### ✅ Autenticación Local
- Registro de usuarios sin internet
- Login con validación local
- Roles: Estudiante y Docente
- Almacenamiento en SharedPreferences

### ✅ Gestión de Perfiles
- Edición de nombre
- Selección de avatar
- Visualización de puntos y estadísticas
- Historial de juegos

### ✅ Juego "Completar la Palabra"
- 7 categorías predefinidas
- Palabras con pistas
- Sistema de puntuación
- Contador de intentos (máximo 6)
- Teclado visual

### ✅ Sistema de Grupos
- Creación de grupos (máximo 10 miembros)
- Chat local por grupo
- Unirse/salir de grupos
- Puntuación grupal

### ✅ Rankings
- Ranking individual de usuarios
- Ranking de grupos
- Ordenamiento por puntos

### ✅ Panel del Docente
- Ver estadísticas de estudiantes
- Agregar palabras personalizadas
- Ver historial de juegos

---

## 🔧 Personalización

### Agregar nuevas categorías

Edita `assets/data/questions.json`:

```json
{
  "Nueva Categoría": [
    {
      "word": "PALABRA",
      "hint": "Descripción de la palabra"
    }
  ]
}
```

### Cambiar colores del tema

Edita `lib/main.dart` en la sección `ThemeData`:

```dart
primaryColor: const Color(0xFF6C63FF), // Cambiar color principal
scaffoldBackgroundColor: const Color(0xFFF5F5FF), // Color de fondo
```

### Modificar puntuación

Edita `lib/services/game_service.dart` en el método `calculatePoints()`.

---

## 🐛 Solución de Problemas

### Error: "No se encuentra el paquete"
```bash
flutter pub get
flutter clean
flutter pub get
```

### Error: "Assets not found"
Verifica que `pubspec.yaml` tenga los assets configurados y ejecuta:
```bash
flutter clean
flutter pub get
```

### Error en Android Studio
```bash
# Invalidar caché
File > Invalidate Caches / Restart

# Sincronizar Gradle
flutter pub get
```

### El APK no instala
```bash
# Desinstalar versión anterior
adb uninstall com.example.edujuegos

# Reinstalar
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Usuarios Demo

Para probar la aplicación, usa estas credenciales:

**Estudiante:**
- Usuario: `ana123`
- Contraseña: `12345`

**Docente:**
- Usuario: `profe`
- Contraseña: `profe123`

---
## tree

edujuegos/
│
├── android/                                    # Configuración Android (generado por Flutter)
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── AndroidManifest.xml
│   │   │       └── kotlin/
│   │   └── build.gradle
│   ├── gradle/
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
│
├── ios/                                        # Configuración iOS (generado por Flutter)
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── Assets.xcassets/
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
│
├── lib/                                        # 📱 CÓDIGO FUENTE PRINCIPAL
│   │
│   ├── main.dart                              # ⭐ Punto de entrada de la aplicación
│   │
│   ├── models/                                # 📦 Modelos de datos
│   │   └── user_model.dart                   # UserModel, GameHistory, GroupModel, ChatMessage, WordQuestion
│   │
│   ├── services/                              # 🔧 Lógica de negocio
│   │   ├── auth_service.dart                 # Autenticación local (login, registro, sesión)
│   │   ├── game_service.dart                 # Lógica del juego (palabras, puntuación, categorías)
│   │   └── group_service.dart                # Gestión de grupos y chat local
│   │
│   ├── screens/                               # 📺 Pantallas de la aplicación
│   │   ├── splash_screen.dart                # Pantalla de carga inicial
│   │   ├── login_screen.dart                 # Inicio de sesión
│   │   ├── register_screen.dart              # Registro de usuario
│   │   ├── home_screen.dart                  # Menú principal
│   │   ├── profile_screen.dart               # Perfil y estadísticas del usuario
│   │   ├── categories_screen.dart            # Selección de categoría para jugar
│   │   ├── game_screen.dart                  # Pantalla del juego (completar palabra)
│   │   ├── groups_screen.dart                # Lista de grupos disponibles
│   │   ├── group_detail_screen.dart          # Chat y detalles del grupo
│   │   ├── ranking_screen.dart               # Rankings de usuarios y grupos
│   │   └── teacher_panel_screen.dart         # Panel administrativo del docente
│   │
│   ├── widgets/                               # 🧩 Widgets reutilizables (opcional)
│   │   ├── custom_button.dart                # (Crear si necesitas)
│   │   ├── avatar_selector.dart              # (Crear si necesitas)
│   │   └── score_card.dart                   # (Crear si necesitas)
│   │
│   └── utils/                                 # 🛠️ Utilidades (opcional)
│       ├── constants.dart                     # (Crear si necesitas constantes)
│       └── helpers.dart                       # (Crear si necesitas funciones auxiliares)
│
├── assets/                                     # 📁 RECURSOS ESTÁTICOS
│   │
│   ├── avatars/                               # 🖼️ Imágenes de avatares
│   │   ├── default.png                       # Avatar por defecto (200x200px recomendado)
│   │   ├── avatar1.png                       # Avatar estudiante 1
│   │   ├── avatar2.png                       # Avatar estudiante 2
│   │   ├── avatar3.png                       # Avatar estudiante 3
│   │   ├── avatar4.png                       # Avatar estudiante 4
│   │   ├── avatar5.png                       # Avatar estudiante 5
│   │   └── teacher.png                       # Avatar docente
│   │
│   ├── data/                                  # 📊 Datos locales
│   │   └── questions.json                    # ⭐ Base de datos de palabras por categoría
│   │
│   ├── animations/                            # 🎬 Animaciones Lottie (opcional)
│   │   ├── success.json                      # Animación de victoria
│   │   ├── loading.json                      # Animación de carga
│   │   └── confetti.json                     # Animación de celebración
│   │
│   ├── icon/                                  # 📱 Icono de la aplicación
│   │   └── app_icon.png                      # Icono (1024x1024px)
│   │
│   └── splash/                                # 🌟 Splash screen
│       └── splash_logo.png                   # Logo para splash
│
├── test/                                       # 🧪 Tests (generado por Flutter)
│   └── widget_test.dart
│
├── web/                                        # 🌐 Configuración Web (generado por Flutter)
│   ├── index.html
│   └── manifest.json
│
├── .gitignore                                  # Git ignore
├── .metadata                                   # Metadata de Flutter
├── analysis_options.yaml                       # Opciones de análisis de código
├── pubspec.yaml                               # ⭐ CONFIGURACIÓN DEL PROYECTO Y DEPENDENCIAS
├── pubspec.lock                               # Lock de versiones de dependencias
├── README.md                                  # ⭐ DOCUMENTACIÓN DEL PROYECTO
└── init_edujuegos.sh                          # ⭐ Script de inicialización


═══════════════════════════════════════════════════════════════════════════════

📋 RESUMEN DE ARCHIVOS A CREAR MANUALMENTE:

OBLIGATORIOS (11 archivos):
─────────────────────────────
1.  lib/main.dart
2.  lib/models/user_model.dart
3.  lib/services/auth_service.dart
4.  lib/services/game_service.dart
5.  lib/services/group_service.dart
6.  lib/screens/splash_screen.dart
7.  lib/screens/login_screen.dart
8.  lib/screens/register_screen.dart
9.  lib/screens/home_screen.dart
10. lib/screens/profile_screen.dart
11. lib/screens/categories_screen.dart
12. lib/screens/game_screen.dart
13. lib/screens/groups_screen.dart
14. lib/screens/group_detail_screen.dart
15. lib/screens/ranking_screen.dart
16. lib/screens/teacher_panel_screen.dart
17. pubspec.yaml
18. README.md
19. init_edujuegos.sh

ASSETS MÍNIMOS NECESARIOS:
───────────────────────────
20. assets/data/questions.json (generado por script)
21. assets/avatars/default.png
22. assets/avatars/avatar1.png
23. assets/avatars/teacher.png

═══════════════════════════════════════════════════════════════════════════════

📝 NOTAS IMPORTANTES:

1. Los archivos de las carpetas android/, ios/, web/ son GENERADOS automáticamente
   por Flutter cuando ejecutas "flutter create edujuegos"

2. La carpeta lib/ es donde irá TODO tu código Dart

3. La carpeta assets/ debe contener:
    - questions.json (se crea con el script init_edujuegos.sh)
    - Imágenes PNG para avatares (puedes usar emojis o descargar de flaticon.com)

4. El archivo pubspec.yaml es CRUCIAL - configura todas las dependencias y assets

5. ORDEN DE CREACIÓN RECOMENDADO:
   ┌─────────────────────────────────────────────────┐
   │ 1. Ejecutar init_edujuegos.sh                  │
   │ 2. Copiar pubspec.yaml                         │
   │ 3. Ejecutar "flutter pub get"                  │
   │ 4. Copiar archivos de lib/models/              │
   │ 5. Copiar archivos de lib/services/            │
   │ 6. Copiar archivos de lib/screens/             │
   │ 7. Copiar lib/main.dart                        │
   │ 8. Agregar imágenes a assets/avatars/          │
   │ 9. Ejecutar "flutter run"                      │
   └─────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════

🎯 TAMAÑO APROXIMADO DE ARCHIVOS:

lib/main.dart                    ~2 KB
lib/models/user_model.dart       ~8 KB
lib/services/auth_service.dart   ~10 KB
lib/services/game_service.dart   ~8 KB
lib/services/group_service.dart  ~7 KB
lib/screens/*.dart               ~3-6 KB cada uno
assets/data/questions.json       ~4 KB
pubspec.yaml                     ~1 KB

TOTAL DEL PROYECTO: ~15-20 MB (incluyendo dependencias de Flutter)

═══════════════════════════════════════════════════════════════════════════════

🔍 VERIFICACIÓN RÁPIDA:

Para verificar que todo está correcto:

1. Ejecuta: flutter doctor
   ✓ Debe mostrar Flutter instalado correctamente

2. Ejecuta: flutter pub get
   ✓ Debe descargar todas las dependencias sin errores

3. Verifica assets: ls assets/data/questions.json
   ✓ El archivo debe existir

4. Verifica estructura: tree lib/ -L 2
   ✓ Debe mostrar models/, services/, screens/

5. Ejecuta: flutter run
   ✓ La app debe compilar y ejecutarse

═══════════════════════════════════════════════════════════════════════════════

---

## 🔐 Seguridad

⚠️ **IMPORTANTE:** Este proyecto usa almacenamiento local SIN encriptación para fines educativos.

Para producción, considera:
- Encriptar contraseñas con `crypto` o `bcrypt`
- Usar `flutter_secure_storage` para datos sensibles
- Implementar validación robusta

---

## 🎨 Mejoras Futuras

- [ ] Sonidos y efectos
- [ ] Más animaciones
- [ ] Modo multijugador en tiempo real
- [ ] Exportar estadísticas a PDF
- [ ] Soporte para imágenes en preguntas
- [ ] Niveles de dificultad
- [ ] Logros y medallas
- [ ] Tema oscuro

---

## 📄 Licencia

Este proyecto es de código abierto para fines educativos.

---

## 👥 Créditos

**Desarrollado para:** UNICLAS  
**Plataforma:** Flutter  
**Versión:** 1.0.0

---

## 📞 Soporte

Para dudas o problemas:
1. Revisa la sección de Solución de Problemas
2. Consulta la documentación de Flutter: https://flutter.dev
3. Comunidad de Flutter en español: https://flutter-es.io

---

## 🎓 Recursos de Aprendizaje

### Flutter
- Documentación oficial: https://docs.flutter.dev
- Flutter Codelabs: https://flutter.dev/docs/codelabs
- Widget Catalog: https://flutter.dev/docs/development/ui/widgets

### Dart
- Dart Language Tour: https://dart.dev/guides/language/language-tour
- Dart Packages: https://pub.dev

### Tutoriales en español
- https://flutter-es.io
- https://www.youtube.com/results?search_query=flutter+español

---

¡Gracias por usar EduJuegos! 🎉📚