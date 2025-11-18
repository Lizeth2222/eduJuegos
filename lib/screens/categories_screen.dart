// ==================== categories_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'game_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameService = context.watch<GameService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige una Categoría 📚'),
      ),
      body: gameService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: gameService.categoryNames.length,
          itemBuilder: (context, index) {
            final category = gameService.categoryNames[index];
            final emoji = _getCategoryEmoji(category);

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameScreen(category: category),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getCategoryColor(index),
                        _getCategoryColor(index).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    final emojis = {
      'Animales': '🐾',
      'Frutas': '🍎',
      'Historia del Perú': '🏛️',
      'Cultura General': '🌍',
      'DPCC': '❤️',
      'Matemática': '🔢',
      'Comunicación': '📖',
    };
    return emojis[category] ?? '📚';
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.purple,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}