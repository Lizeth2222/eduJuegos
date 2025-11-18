// ==================== groups_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupService = context.read<GroupService>();
    final authService = context.read<AuthService>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Grupo'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del grupo',
            hintText: 'Ej: Los Genios',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _groupNameController.text),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final response = await groupService.createGroup(
        name: result,
        creatorId: authService.currentUser!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        _groupNameController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupService = context.watch<GroupService>();
    final authService = context.watch<AuthService>();
    final userId = authService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos 👥'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createGroup,
          ),
        ],
      ),
      body: groupService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupService.groups.length,
        itemBuilder: (context, index) {
          final group = groupService.groups[index];
          final isMember = group.memberIds.contains(userId);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6C63FF),
                child: Text('${group.memberIds.length}'),
              ),
              title: Text(group.name),
              subtitle: Text(
                '${group.memberIds.length}/10 miembros • ${group.totalPoints} puntos',
              ),
              trailing: isMember
                  ? const Chip(label: Text('Miembro'))
                  : ElevatedButton(
                onPressed: group.isFull
                    ? null
                    : () async {
                  final result = await groupService.joinGroup(
                    group.id,
                    userId,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'])),
                    );
                  }
                },
                child: const Text('Unirse'),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetailScreen(groupId: group.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}