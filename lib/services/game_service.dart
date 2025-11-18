import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Servicio del juego "Completar la Palabra"
/// Maneja la lógica del juego, palabras y puntuación
class GameService extends ChangeNotifier {
  Map<String, List<WordQuestion>> _categories = {};
  WordQuestion? _currentWord;
  Set<String> _guessedLetters = {};
  int _attempts = 0;
  int _maxAttempts = 6;
  bool _isLoading = false;

  // Getters
  Map<String, List<WordQuestion>> get categories => _categories;
  List<String> get categoryNames => _categories.keys.toList();
  WordQuestion? get currentWord => _currentWord;
  Set<String> get guessedLetters => _guessedLetters;
  int get attempts => _attempts;
  int get maxAttempts => _maxAttempts;
  bool get isLoading => _isLoading;

  /// Inicializar servicio - cargar categorías y palabras
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadCategories();
    } catch (e) {
      debugPrint('Error inicializando GameService: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cargar categorías desde archivo JSON o SharedPreferences
  Future<void> _loadCategories() async {
    try {
      // Intentar cargar desde assets
      final jsonString =
      await rootBundle.loadString('assets/data/questions.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      _categories.clear();

      jsonData.forEach((category, words) {
        final List<WordQuestion> wordList = (words as List)
            .map((w) => WordQuestion.fromJson(w, category))
            .toList();
        _categories[category] = wordList;
      });

      // También cargar palabras personalizadas del docente
      await _loadCustomWords();
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
      // Si falla, crear categorías por defecto
      _createDefaultCategories();
    }
  }

  /// Cargar palabras personalizadas guardadas por docentes
  Future<void> _loadCustomWords() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString('custom_words');

    if (customJson != null) {
      final Map<String, dynamic> customData = jsonDecode(customJson);

      customData.forEach((category, words) {
        final List<WordQuestion> wordList = (words as List)
            .map((w) => WordQuestion.fromJson(w, category))
            .toList();

        // Agregar a categoría existente o crear nueva
        if (_categories.containsKey(category)) {
          _categories[category]!.addAll(wordList);
        } else {
          _categories[category] = wordList;
        }
      });
    }
  }

  /// Crear categorías por defecto si no se puede cargar el JSON
  void _createDefaultCategories() {
    _categories = {
      'Animales': [
        WordQuestion(word: 'GATO', hint: 'Mascota felina', category: 'Animales'),
        WordQuestion(word: 'PERRO', hint: 'Mejor amigo del hombre', category: 'Animales'),
      ],
      'Frutas': [
        WordQuestion(word: 'MANZANA', hint: 'Roja o verde', category: 'Frutas'),
        WordQuestion(word: 'PLATANO', hint: 'Amarilla y alargada', category: 'Frutas'),
      ],
    };
  }

  /// Iniciar nuevo juego con una categoría
  void startGame(String category) {
    if (!_categories.containsKey(category) ||
        _categories[category]!.isEmpty) {
      debugPrint('Categoría no encontrada: $category');
      return;
    }

    // Seleccionar palabra aleatoria de la categoría
    final random = Random();
    final words = _categories[category]!;
    _currentWord = words[random.nextInt(words.length)];

    // Reiniciar estado del juego
    _guessedLetters.clear();
    _attempts = 0;

    notifyListeners();
  }

  /// Adivinar una letra
  bool guessLetter(String letter) {
    if (_currentWord == null) return false;

    letter = letter.toUpperCase();

    // Si ya fue adivinada, no hacer nada
    if (_guessedLetters.contains(letter)) {
      return false;
    }

    _guessedLetters.add(letter);

    // Si la letra no está en la palabra, aumentar intentos
    if (!_currentWord!.word.contains(letter)) {
      _attempts++;
    }

    notifyListeners();
    return _currentWord!.word.contains(letter);
  }

  /// Verificar si el juego está ganado
  bool isGameWon() {
    if (_currentWord == null) return false;

    // Verificar si todas las letras fueron adivinadas
    for (var letter in _currentWord!.word.split('')) {
      if (letter != ' ' && !_guessedLetters.contains(letter)) {
        return false;
      }
    }

    return true;
  }

  /// Verificar si el juego está perdido
  bool isGameLost() {
    return _attempts >= _maxAttempts;
  }

  /// Obtener palabra con guiones para mostrar
  String getDisplayWord() {
    if (_currentWord == null) return '';

    return _currentWord!.word.split('').map((letter) {
      if (letter == ' ') return '  '; // Espacio entre palabras
      return _guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }

  /// Calcular puntos ganados basado en dificultad
  int calculatePoints() {
    if (_currentWord == null) return 0;

    // Puntos base según longitud de palabra
    int basePoints = _currentWord!.word.replaceAll(' ', '').length * 10;

    // Bonus por pocos intentos
    int attemptBonus = (_maxAttempts - _attempts) * 5;

    // Bonus por categoría difícil
    int categoryBonus = 0;
    if (_currentWord!.category == 'Historia del Perú' ||
        _currentWord!.category == 'Matemática') {
      categoryBonus = 20;
    }

    return basePoints + attemptBonus + categoryBonus;
  }

  /// Agregar palabra personalizada (para docentes)
  Future<void> addCustomWord({
    required String category,
    required String word,
    required String hint,
  }) async {
    final newWord = WordQuestion(
      word: word.toUpperCase(),
      hint: hint,
      category: category,
    );

    // Agregar a categoría existente o crear nueva
    if (_categories.containsKey(category)) {
      _categories[category]!.add(newWord);
    } else {
      _categories[category] = [newWord];
    }

    // Guardar en SharedPreferences
    await _saveCustomWords();
    notifyListeners();
  }

  /// Guardar palabras personalizadas
  Future<void> _saveCustomWords() async {
    final prefs = await SharedPreferences.getInstance();

    // Filtrar solo palabras que no vengan del JSON original
    // (simplificado: guardar todas las palabras)
    final customData = <String, dynamic>{};

    _categories.forEach((category, words) {
      customData[category] = words.map((w) => w.toJson()).toList();
    });

    await prefs.setString('custom_words', jsonEncode(customData));
  }

  /// Reiniciar juego
  void resetGame() {
    _currentWord = null;
    _guessedLetters.clear();
    _attempts = 0;
    notifyListeners();
  }

  /// Obtener estadísticas de juego
  Map<String, int> getStatistics(List<GameHistory> history) {
    int totalGames = history.length;
    int gamesWon = history.where((h) => h.completed).length;
    int totalPoints = history.fold(0, (sum, h) => sum + h.pointsEarned);

    return {
      'totalGames': totalGames,
      'gamesWon': gamesWon,
      'gamesLost': totalGames - gamesWon,
      'totalPoints': totalPoints,
      'winRate': totalGames > 0 ? ((gamesWon / totalGames) * 100).round() : 0,
    };
  }
}