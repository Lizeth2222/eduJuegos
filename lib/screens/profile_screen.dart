// ==================== profile_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final gameService = context.watch<GameService>();
    final user = authService.currentUser!;
    final stats = gameService.getStatistics(user.gameHistory);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar y nombre
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                user.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${user.username}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Chip(
              label: Text(user.role == 'estudiante' ? '👨‍🎓 Estudiante' : '👨‍🏫 Docente'),
            ),
            const SizedBox(height: 24),

            // Puntos
            Card(
              color: Colors.orange,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars, size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      '${user.points} Puntos',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas 📊',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _StatRow('Juegos totales', '${stats['totalGames']}'),
                    _StatRow('Juegos ganados', '${stats['gamesWon']} 🏆'),
                    _StatRow('Juegos perdidos', '${stats['gamesLost']}'),
                    _StatRow('Tasa de victoria', '${stats['winRate']}%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Historial reciente
            if (user.gameHistory.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimos juegos 🎮',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      ...user.gameHistory.reversed.take(5).map((game) {
                        return ListTile(
                          leading: Icon(
                            game.completed ? Icons.check_circle : Icons.cancel,
                            color: game.completed ? Colors.green : Colors.red,
                          ),
                          title: Text(game.word),
                          subtitle: Text(game.category),
                          trailing: Text(
                            '+${game.pointsEarned} ⭐',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}