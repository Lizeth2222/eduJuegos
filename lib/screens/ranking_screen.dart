// ==================== ranking_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/group_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final groupService = context.watch<GroupService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking 🏆')),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedTab = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 0
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[300],
                      foregroundColor:
                      _selectedTab == 0 ? Colors.white : Colors.black,
                    ),
                    child: const Text('Usuarios'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _selectedTab = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedTab == 1
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[300],
                      foregroundColor:
                      _selectedTab == 1 ? Colors.white : Colors.black,
                    ),
                    child: const Text('Grupos'),
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: _selectedTab == 0
                ? _buildUserRanking(authService)
                : _buildGroupRanking(groupService),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRanking(AuthService authService) {
    final ranking = authService.getRanking();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final user = ranking[index];
        final position = index + 1;
        final medal = position == 1
            ? '🥇'
            : position == 2
            ? '🥈'
            : position == 3
            ? '🥉'
            : '$position.';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                user.fullName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Row(
              children: [
                Text(
                  medal,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(user.fullName)),
              ],
            ),
            subtitle: Text(user.role),
            trailing: Text(
              '${user.points} ⭐',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupRanking(GroupService groupService) {
    final ranking = groupService.getGroupRanking();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final group = ranking[index];
        final position = index + 1;
        final medal = position == 1
            ? '🥇'
            : position == 2
            ? '🥈'
            : position == 3
            ? '🥉'
            : '$position.';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6C63FF),
              child: Text('${group.memberIds.length}'),
            ),
            title: Row(
              children: [
                Text(
                  medal,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(group.name)),
              ],
            ),
            subtitle: Text('${group.memberIds.length} miembros'),
            trailing: Text(
              '${group.totalPoints} ⭐',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        );
      },
    );
  }
}