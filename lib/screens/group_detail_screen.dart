import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final groupService = context.read<GroupService>();
    final authService = context.read<AuthService>();
    final user = authService.currentUser!;

    await groupService.sendMessage(
      groupId: widget.groupId,
      userId: user.id,
      username: user.fullName,
      message: _messageController.text.trim(),
    );

    _messageController.clear();

    // Scroll al final
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupService = context.watch<GroupService>();
    final authService = context.watch<AuthService>();
    final group = groupService.getGroupById(widget.groupId);
    final messages = groupService.getGroupMessages(widget.groupId);
    final currentUser = authService.currentUser!;

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grupo')),
        body: const Center(child: Text('Grupo no encontrado')),
      );
    }

    // Obtener miembros del grupo
    final members = group.memberIds
        .map((id) => authService.getUserById(id))
        .where((u) => u != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          // Botón de información del grupo
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información del Grupo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      Text('Nombre: ${group.name}'),
                      Text('Miembros: ${group.memberIds.length}/10'),
                      Text('Puntos totales: ${group.totalPoints} ⭐'),
                      const SizedBox(height: 16),
                      const Text(
                        'Miembros:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...members.map((member) => ListTile(
                        leading: CircleAvatar(
                          child: Text(member!.fullName[0].toUpperCase()),
                        ),
                        title: Text(member.fullName),
                        subtitle: Text('${member.points} puntos'),
                      )),
                      const SizedBox(height: 16),
                      if (group.memberIds.contains(currentUser.id))
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await groupService.leaveGroup(
                                group.id,
                                currentUser.id,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Salir del Grupo'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Text(
                'No hay mensajes aún.\n¡Sé el primero en escribir! 💬',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.userId == currentUser.id;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            message.username,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        Text(
                          message.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Campo de entrada de mensaje
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6C63FF),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}