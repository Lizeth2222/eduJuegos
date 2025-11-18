// ==================== teacher_panel_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';

class TeacherPanelScreen extends StatefulWidget {
  const TeacherPanelScreen({super.key});

  @override
  State<TeacherPanelScreen> createState() => _TeacherPanelScreenState();
}

class _TeacherPanelScreenState extends State<TeacherPanelScreen> {
  final _wordController = TextEditingController();
  final _hintController = TextEditingController();
  String _selectedCategory = 'Animales';

  @override
  void dispose() {
    _wordController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _addWord() async {
    if (_wordController.text.isEmpty || _hintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final gameService = context.read<GameService>();
    await gameService.addCustomWord(
      category: _selectedCategory,
      word: _wordController.text,
      hint: _hintController.text,
    );

    _wordController.clear();
    _hintController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palabra agregada ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final gameService = context.watch<GameService>();
    final allUsers = authService.allUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Docente 👨‍🏫')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agregar palabra
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Agregar Nueva Palabra',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: gameService.categoryNames
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wordController,
                      decoration: const InputDecoration(labelText: 'Palabra'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hintController,
                      decoration: const InputDecoration(labelText: 'Pista'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addWord,
                      child: const Text('Agregar Palabra'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estadísticas de estudiantes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estudiantes',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ...allUsers
                        .where((u) => u.isStudent)
                        .map((u) => ListTile(
                      title: Text(u.fullName),
                      subtitle: Text('${u.gameHistory.length} juegos'),
                      trailing: Text('${u.points} ⭐'),
                    ))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Nota: group_detail_screen.dart se puede crear siguiendo el mismo patrón