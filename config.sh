#!/bin/bash

# Script de inicialización para EduJuegos Flutter App
# Ejecutar desde la carpeta donde quieres crear el proyecto

echo "🎮 Iniciando proyecto EduJuegos..."

# Crear proyecto Flutter
flutter create edujuegos

# Entrar al directorio
cd edujuegos

# Agregar dependencias necesarias
echo "📦 Instalando dependencias..."
flutter pub add shared_preferences
flutter pub add sqflite
flutter pub add path_provider
flutter pub add provider
flutter pub add flutter_animate
flutter pub add google_fonts
flutter pub add lottie

# Crear estructura de carpetas
echo "📁 Creando estructura de carpetas..."
mkdir -p lib/models
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/services
mkdir -p lib/utils
mkdir -p assets/avatars
mkdir -p assets/data
mkdir -p assets/animations

# Crear archivo de preguntas por defecto
cat >assets/data/questions.json <<'EOF'
{
  "Animales": [
    {"word": "GATO", "hint": "Mascota felina que dice miau"},
    {"word": "PERRO", "hint": "El mejor amigo del hombre"},
    {"word": "ELEFANTE", "hint": "Animal grande con trompa"},
    {"word": "TIGRE", "hint": "Felino grande con rayas"},
    {"word": "DELFIN", "hint": "Mamífero marino inteligente"},
    {"word": "AGUILA", "hint": "Ave rapaz que vuela alto"},
    {"word": "MARIPOSA", "hint": "Insecto con alas coloridas"},
    {"word": "COCODRILO", "hint": "Reptil de ríos y pantanos"}
  ],
  "Frutas": [
    {"word": "MANZANA", "hint": "Fruta roja o verde, crujiente"},
    {"word": "PLATANO", "hint": "Fruta amarilla alargada"},
    {"word": "NARANJA", "hint": "Cítrico color naranja"},
    {"word": "SANDIA", "hint": "Fruta grande, roja por dentro"},
    {"word": "UVA", "hint": "Fruta pequeña que crece en racimos"},
    {"word": "FRESA", "hint": "Fruta roja con semillas por fuera"},
    {"word": "PIÑA", "hint": "Fruta tropical con corona"},
    {"word": "MANGO", "hint": "Fruta tropical dulce y jugosa"}
  ],
  "Historia del Perú": [
    {"word": "INCAS", "hint": "Imperio precolombino del Perú"},
    {"word": "MACHU PICCHU", "hint": "Ciudadela inca en Cusco"},
    {"word": "CUSCO", "hint": "Capital del Imperio Inca"},
    {"word": "PACHACUTEC", "hint": "Gran emperador inca"},
    {"word": "CHANCAS", "hint": "Enemigos de los incas"},
    {"word": "ATAHUALPA", "hint": "Último emperador inca"},
    {"word": "HUASCAR", "hint": "Hermano de Atahualpa"},
    {"word": "TUPAC AMARU", "hint": "Líder de la rebelión indígena"}
  ],
  "Cultura General": [
    {"word": "BIBLIOTECA", "hint": "Lugar con muchos libros"},
    {"word": "TELESCOPIO", "hint": "Instrumento para ver las estrellas"},
    {"word": "COMPUTADORA", "hint": "Máquina electrónica para trabajar"},
    {"word": "DEMOCRACIA", "hint": "Sistema de gobierno del pueblo"},
    {"word": "ECOLOGIA", "hint": "Ciencia que estudia el medio ambiente"},
    {"word": "ASTRONOMIA", "hint": "Ciencia que estudia el universo"},
    {"word": "GEOGRAFIA", "hint": "Ciencia que estudia la Tierra"},
    {"word": "LITERATURA", "hint": "Arte de la escritura creativa"}
  ],
  "DPCC": [
    {"word": "RESPETO", "hint": "Valor de tratar bien a los demás"},
    {"word": "TOLERANCIA", "hint": "Aceptar las diferencias"},
    {"word": "EMPATIA", "hint": "Ponerse en el lugar del otro"},
    {"word": "SOLIDARIDAD", "hint": "Ayudar a quien lo necesita"},
    {"word": "HONESTIDAD", "hint": "Decir siempre la verdad"},
    {"word": "RESPONSABILIDAD", "hint": "Cumplir con los deberes"},
    {"word": "JUSTICIA", "hint": "Dar a cada uno lo que le corresponde"},
    {"word": "LIBERTAD", "hint": "Derecho a decidir y actuar"}
  ],
  "Matemática": [
    {"word": "SUMA", "hint": "Operación de agregar números"},
    {"word": "RESTA", "hint": "Operación de quitar números"},
    {"word": "MULTIPLICACION", "hint": "Suma repetida"},
    {"word": "DIVISION", "hint": "Repartir en partes iguales"},
    {"word": "TRIANGULO", "hint": "Figura de tres lados"},
    {"word": "CIRCULO", "hint": "Figura redonda perfecta"},
    {"word": "CUADRADO", "hint": "Figura de cuatro lados iguales"},
    {"word": "FRACCION", "hint": "Parte de un entero"}
  ],
  "Comunicación": [
    {"word": "VERBO", "hint": "Palabra que expresa acción"},
    {"word": "SUSTANTIVO", "hint": "Palabra que nombra cosas"},
    {"word": "ADJETIVO", "hint": "Palabra que describe"},
    {"word": "ORACION", "hint": "Conjunto de palabras con sentido"},
    {"word": "SINONIMO", "hint": "Palabra con significado similar"},
    {"word": "ANTONIMO", "hint": "Palabra con significado opuesto"},
    {"word": "METAFORA", "hint": "Comparación implícita"},
    {"word": "CUENTO", "hint": "Narración breve de ficción"}
  ]
}
EOF

echo "✅ Estructura creada exitosamente!"
echo ""
echo "📝 Próximos pasos:"
echo "1. Copia los archivos de código que te proporcionaré"
echo "2. Agrega avatares en assets/avatars/ (imágenes PNG o JPG)"
echo "3. Actualiza pubspec.yaml para incluir los assets"
echo "4. Ejecuta: flutter pub get"
echo "5. Ejecuta: flutter run"
echo ""
echo "🎮 ¡Proyecto EduJuegos inicializado!"
