import 'dart:convert';
import 'dart:math';
import 'package:edujuegos/services/auth_service.dart';
import 'package:edujuegos/services/group_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class GameService extends ChangeNotifier {
  final AuthService _authService;
  final GroupService _groupService;

  Map<String, List<WordQuestion>> _categories = {};
  Map<String, List<WordQuestion>> _customWords = {};

  WordQuestion? _currentWord;
  Set<String> _guessedLetters = {};
  int _attempts = 0;
  final int _maxAttempts = 6;
  bool _isLoading = false;
  bool _isGameFinished = false;

  Map<String, List<WordQuestion>> get categories => _categories;
  List<String> get categoryNames => _categories.keys.toList();
  WordQuestion? get currentWord => _currentWord;
  Set<String> get guessedLetters => _guessedLetters;
  int get attempts => _attempts;
  int get maxAttempts => _maxAttempts;
  bool get isLoading => _isLoading;
  bool get isGameFinished => _isGameFinished;

  GameService(this._authService, this._groupService);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadWords();
    } catch (e) {
      debugPrint('Error inicializando GameService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadWords() async {
    await _loadCustomWords();
    await _loadBaseWords();
  }

  Future<void> _loadBaseWords() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/questions.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      _categories.clear();
      jsonData.forEach((category, words) {
        _categories[category] = (words as List)
            .map((w) => WordQuestion.fromJson(w, category))
            .toList();
      });

      _customWords.forEach((category, customWordList) {
        _categories.putIfAbsent(category, () => []).addAll(customWordList);
      });
    } catch (e) {
      debugPrint('Error cargando categorías base: $e');
      if (_categories.isEmpty) _createDefaultCategories();
    }
  }

  Future<void> _loadCustomWords() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString('custom_words');
    _customWords.clear();

    if (customJson != null) {
      final customData = jsonDecode(customJson) as Map<String, dynamic>;
      customData.forEach((category, words) {
        _customWords[category] = (words as List)
            .map((w) => WordQuestion.fromJson(w, category))
            .toList();
      });
    }
  }

  void _createDefaultCategories() {
    _categories = {
      'Animales': [WordQuestion(word: 'GATO', hint: 'Mascota felina', category: 'Animales')],
      'Frutas': [WordQuestion(word: 'MANZANA', hint: 'Roja o verde', category: 'Frutas')],
    };
  }

  void startGame(String category) {
    if (!_categories.containsKey(category) || _categories[category]!.isEmpty) {
      debugPrint('Categoría no válida o vacía: $category');
      return;
    }

    final random = Random();
    final words = _categories[category]!;
    _currentWord = words[random.nextInt(words.length)];

    _guessedLetters.clear();
    _attempts = 0;
    _isGameFinished = false;
    notifyListeners();
  }

  void guessLetter(String letter) {
    if (_currentWord == null || _isGameFinished) return;

    letter = letter.toUpperCase();
    if (_guessedLetters.contains(letter)) return;

    _guessedLetters.add(letter);

    if (!_currentWord!.word.contains(letter)) {
      _attempts++;
    }

    final bool won = isGameWon();
    final bool lost = isGameLost();

    if (won || lost) {
      endGame(won: won);
    }

    notifyListeners();
  }

  Future<void> endGame({required bool won}) async {
    if (_currentWord == null || _authService.currentUser == null || _isGameFinished) return;

    _isGameFinished = true;

    int points = 0;
    if (won) {
      points = calculatePoints();
      await _authService.addPointsToCurrentUser(points);
    }

    final history = GameHistory(
      category: _currentWord!.category,
      word: _currentWord!.word,
      pointsEarned: points,
      completed: won,
    );

    await _authService.addGameHistoryToCurrentUser(history);
    // CORREGIDO: Llama a GroupService para actualizar los puntos del grupo
    await _groupService.updateUserPointsInGroups(_authService.currentUser!.id);

    notifyListeners();
  }

  bool isGameWon() {
    if (_currentWord == null) return false;
    return _currentWord!.word.split('').every((l) => l == ' ' || _guessedLetters.contains(l));
  }

  bool isGameLost() => _attempts >= _maxAttempts;

  String getDisplayWord() {
    if (_currentWord == null) return '';
    return _currentWord!.word.split('').map((l) {
      return l == ' ' ? '  ' : _guessedLetters.contains(l) ? l : '_';
    }).join(' ');
  }

  int calculatePoints() {
    if (_currentWord == null) return 0;
    int basePoints = _currentWord!.word.replaceAll(' ', '').length * 10;
    int attemptBonus = (_maxAttempts - _attempts) * 5;
    int categoryBonus = 0;
    const hardCategories = ['Historia del Perú', 'Matemática'];
    if (hardCategories.contains(_currentWord!.category)) {
      categoryBonus = 20;
    }
    return basePoints + attemptBonus + categoryBonus;
  }

  Future<void> addCustomWord({
    required String category,
    required String word,
    required String hint,
  }) async {
    final newWord = WordQuestion(word: word.toUpperCase(), hint: hint, category: category);

    _categories.putIfAbsent(category, () => []).add(newWord);
    _customWords.putIfAbsent(category, () => []).add(newWord);

    await _saveCustomWords();
    notifyListeners();
  }

  Future<void> _saveCustomWords() async {
    final prefs = await SharedPreferences.getInstance();
    final customData = <String, dynamic>{};
    _customWords.forEach((category, words) {
      customData[category] = words.map((w) => w.toJson()).toList();
    });
    await prefs.setString('custom_words', jsonEncode(customData));
  }

  void resetGame() {
    _currentWord = null;
    _guessedLetters.clear();
    _attempts = 0;
    _isGameFinished = false;
    notifyListeners();
  }

  Map<String, int> getStatistics(List<GameHistory> history) {
    int totalGames = history.length;
    int gamesWon = history.where((h) => h.completed).length;
    int totalPoints = history.fold(0, (sum, h) => sum + h.pointsEarned);
    return {
      'totalGames': totalGames,
      'gamesWon': gamesWon,
      'gamesLost': totalGames - gamesWon,
      'totalPoints': totalPoints,
      'winRate': totalGames > 0 ? (gamesWon / totalGames * 100).round() : 0,
    };
  }
}