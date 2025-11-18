// ==================== game_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class GameScreen extends StatefulWidget {
  final String category;

  const GameScreen({super.key, required this.category});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Iniciar juego al cargar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameService>().startGame(widget.category);
    });
  }

  void _guessLetter(String letter) {
    final gameService = context.read<GameService>();
    final isCorrect = gameService.guessLetter(letter);

    // Verificar si ganó o perdió
    if (gameService.isGameWon()) {
      _showGameResult(true);
    } else if (gameService.isGameLost()) {
      _showGameResult(false);
    }
  }

  void _showGameResult(bool won) {
    final gameService = context.read<GameService>();
    final authService = context.read<AuthService>();
    final points = won ? gameService.calculatePoints() : 0;

    // Guardar historial y puntos
    if (won) {
      final history = GameHistory(
        category: widget.category,
        word: gameService.currentWord!.word,
        pointsEarned: points,
        completed: true,
      );
      authService.addGameHistoryToCurrentUser(history);
      authService.addPointsToCurrentUser(points);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '¡Ganaste! 🎉' : 'Perdiste 😢'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won
                  ? '¡Completaste la palabra!'
                  : 'La palabra era: ${gameService.currentWord!.word}',
              textAlign: TextAlign.center,
            ),
            if (won) ...[
              const SizedBox(height: 16),
              Text(
                'Ganaste $points puntos ⭐',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameService.startGame(widget.category);
            },
            child: const Text('Jugar de nuevo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al menú'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameService = context.watch<GameService>();
    final currentWord = gameService.currentWord;

    if (currentWord == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Column(
        children: [
          // Contador de intentos
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1 * gameService.attempts),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Intentos: ${gameService.attempts}/${gameService.maxAttempts}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '❌' * gameService.attempts,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pista
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentWord.hint,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Palabra con guiones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              gameService.getDisplayWord(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Color(0xFF6C63FF),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Teclado de letras
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _LetterKeyboard(
                guessedLetters: gameService.guessedLetters,
                onLetterPressed: _guessLetter,
                correctLetters: currentWord.word.split('').toSet(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterKeyboard extends StatelessWidget {
  final Set<String> guessedLetters;
  final Function(String) onLetterPressed;
  final Set<String> correctLetters;

  const _LetterKeyboard({
    required this.guessedLetters,
    required this.onLetterPressed,
    required this.correctLetters,
  });

  @override
  Widget build(BuildContext context) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rows = [
      'QWERTYUIOP',
      'ASDFGHJKLÑ',
      'ZXCVBNM',
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((letter) {
              final isGuessed = guessedLetters.contains(letter);
              final isCorrect = isGuessed && correctLetters.contains(letter);
              final isWrong = isGuessed && !correctLetters.contains(letter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  width: 32,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isGuessed ? null : () => onLetterPressed(letter),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isCorrect
                          ? Colors.green
                          : isWrong
                          ? Colors.red
                          : const Color(0xFF6C63FF),
                      disabledBackgroundColor:
                      isCorrect ? Colors.green : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}