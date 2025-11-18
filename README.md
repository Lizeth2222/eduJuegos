# 📚 EduJuegos - Aplicación Educativa 100% Offline en Flutter

Aplicación educativa de "Completar la Palabra", desarrollada en Flutter para funcionar de manera 100% local, sin necesidad de conexión a internet ni servicios de backend como Firebase.

---

## 🎮 Características Implementadas y Mejoradas

Este proyecto ha sido refactorizado para seguir buenas prácticas de desarrollo en Flutter, incluyendo una arquitectura limpia con separación de responsabilidades (UI, servicios, modelos) y gestión de estado con `provider`.

### ✅ Lógica de Negocio (Services)
- **AuthService**: Gestión de autenticación local con contraseñas hasheadas (Base64) para mayor seguridad.
- **GameService**: Lógica completa del juego, incluyendo carga de palabras desde JSON, sistema de intentos, cálculo de puntos y guardado de historial por usuario.
- **GroupService**: Sistema de grupos offline con chat local, cálculo automático de puntos totales y gestión de membresías.
- **Inyección de Dependencias**: Los servicios están interconectados y se inicializan en el orden correcto al arrancar la app para un funcionamiento robusto.

### ✅ Funcionalidades Principales
- **Autenticación Local**: Registro y login seguros con persistencia de sesión.
- **Juego "Completar la Palabra"**: 7 categorías, palabras aleatorias, sistema de puntos y contador de 6 intentos.
- **Sistema de Grupos**: Creación, unión y chat en grupos de hasta 10 miembros.
- **Panel del Docente**: Añadir nuevas palabras al juego y visualizar estadísticas de los estudiantes.
- **Perfil de Usuario**: Selector de avatares, visualización de puntos e historial de partidas.
- **Rankings**: Clasificación de usuarios y grupos por puntuación.

### ✅ Interfaz de Usuario (UI)
- **Diseño Amigable**: Estilo colorido y moderno con Google Fonts.
- **Animaciones**: Preparado para integrar animaciones Lottie.
- **Navegación Fluida**: `SplashScreen` que inicializa los servicios y dirige al usuario a la pantalla correspondiente.

---

## 📁 Estructura del Proyecto

```
edujuegos/
├── lib/
│   ├── main.dart                      # Punto de entrada y proveedores de estado
│   ├── models/                      # Modelos de datos (User, Group, Game, etc.)
│   ├── services/                    # Lógica de negocio (Auth, Game, Group)
│   └── screens/                     # Pantallas de la aplicación
├── assets/
│   ├── avatars/                     # Imágenes para avatares de perfil
│   └── data/
│       └── questions.json           # Base de datos local de palabras
└── pubspec.yaml                     # Dependencias y configuración de assets
```

---

## ⚙️ Cómo Empezar

### 1. Prerrequisitos
- Tener Flutter 3.0 o superior instalado.
- Un emulador de Android o un dispositivo físico.

### 2. Instalación

```bash
# Clona el repositorio (o usa el código proporcionado)
git clone https://github.com/Lizeth2222/eduJuegos.git
cd edujuegos

# Instala las dependencias
flutter pub get
```

### 3. Ejecutar la Aplicación

```bash
# Asegúrate de tener un dispositivo conectado y ejecuta
flutter run
```

---

## 🧑‍💻 Usuarios de Demostración

Para facilitar las pruebas, se han creado dos usuarios por defecto:

**Estudiante:**
- **Usuario:** `ana123`
- **Contraseña:** `12345`

**Docente:**
- **Usuario:** `profe`
- **Contraseña:** `profe123`

---

¡He disfrutado mucho mejorando EduJuegos! Si tienes alguna otra pregunta o necesitas más funcionalidades, no dudes en consultarme.
