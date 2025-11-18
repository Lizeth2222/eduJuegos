import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Servicio de gestión de grupos
/// Maneja creación, membresía y chat local de grupos
class GroupService extends ChangeNotifier {
  List<GroupModel> _groups = [];
  Map<String, List<ChatMessage>> _groupMessages = {};
  bool _isLoading = false;

  // Getters
  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;

  /// Inicializar servicio
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadGroups();
      await _loadMessages();
    } catch (e) {
      debugPrint('Error inicializando GroupService: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cargar grupos desde SharedPreferences
  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getString('groups');

    if (groupsJson != null) {
      final List<dynamic> groupsList = jsonDecode(groupsJson);
      _groups = groupsList.map((json) => GroupModel.fromJson(json)).toList();
    } else {
      // Crear grupos demo
      _groups = _createDemoGroups();
      await _saveGroups();
    }
  }

  /// Guardar grupos
  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson =
    jsonEncode(_groups.map((group) => group.toJson()).toList());
    await prefs.setString('groups', groupsJson);
  }

  /// Cargar mensajes de chat
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('messages');

    if (messagesJson != null) {
      final Map<String, dynamic> messagesData = jsonDecode(messagesJson);
      _groupMessages.clear();

      messagesData.forEach((groupId, messages) {
        _groupMessages[groupId] = (messages as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      });
    }
  }

  /// Guardar mensajes
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesData = <String, dynamic>{};

    _groupMessages.forEach((groupId, messages) {
      messagesData[groupId] = messages.map((m) => m.toJson()).toList();
    });

    await prefs.setString('messages', jsonEncode(messagesData));
  }

  /// Crear grupos demo
  List<GroupModel> _createDemoGroups() {
    return [
      GroupModel(
        id: 'group_1',
        name: 'Los Exploradores 🔍',
        memberIds: ['demo_student_1'],
        totalPoints: 150,
        createdBy: 'demo_student_1',
      ),
      GroupModel(
        id: 'group_2',
        name: 'Equipo Genial 🌟',
        memberIds: [],
        totalPoints: 0,
        createdBy: 'demo_teacher_1',
      ),
    ];
  }

  /// Crear nuevo grupo
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String creatorId,
  }) async {
    if (name.trim().isEmpty) {
      return {
        'success': false,
        'message': 'El nombre del grupo no puede estar vacío 📝',
      };
    }

    // Verificar si ya existe un grupo con ese nombre
    if (_groups.any((g) => g.name.toLowerCase() == name.toLowerCase())) {
      return {
        'success': false,
        'message': 'Ya existe un grupo con ese nombre 😅',
      };
    }

    final newGroup = GroupModel(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      memberIds: [creatorId], // El creador es el primer miembro
      createdBy: creatorId,
    );

    _groups.add(newGroup);
    await _saveGroups();
    notifyListeners();

    return {
      'success': true,
      'message': '¡Grupo creado exitosamente! 🎉',
      'groupId': newGroup.id,
    };
  }

  /// Unirse a un grupo
  Future<Map<String, dynamic>> joinGroup(String groupId, String userId) async {
    final group = _groups.firstWhere(
          (g) => g.id == groupId,
      orElse: () => throw Exception('Grupo no encontrado'),
    );

    // Verificar si ya es miembro
    if (group.memberIds.contains(userId)) {
      return {
        'success': false,
        'message': 'Ya eres miembro de este grupo 😊',
      };
    }

    // Verificar si está lleno
    if (group.isFull) {
      return {
        'success': false,
        'message': 'El grupo está lleno (máximo 10 miembros) 😔',
      };
    }

    group.addMember(userId);
    await _saveGroups();
    notifyListeners();

    return {
      'success': true,
      'message': '¡Te has unido al grupo! 🎊',
    };
  }

  /// Salir de un grupo
  Future<void> leaveGroup(String groupId, String userId) async {
    final group = _groups.firstWhere((g) => g.id == groupId);
    group.removeMember(userId);

    // Si no quedan miembros, eliminar el grupo
    if (group.memberIds.isEmpty) {
      _groups.removeWhere((g) => g.id == groupId);
      _groupMessages.remove(groupId);
    }

    await _saveGroups();
    await _saveMessages();
    notifyListeners();
  }

  /// Obtener grupos de un usuario
  List<GroupModel> getUserGroups(String userId) {
    return _groups.where((g) => g.memberIds.contains(userId)).toList();
  }

  /// Enviar mensaje en un grupo
  Future<void> sendMessage({
    required String groupId,
    required String userId,
    required String username,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      userId: userId,
      username: username,
      message: message.trim(),
    );

    // Agregar mensaje a la lista del grupo
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }
    _groupMessages[groupId]!.add(newMessage);

    // Limitar a 100 mensajes por grupo
    if (_groupMessages[groupId]!.length > 100) {
      _groupMessages[groupId]!.removeAt(0);
    }

    await _saveMessages();
    notifyListeners();
  }

  /// Obtener mensajes de un grupo
  List<ChatMessage> getGroupMessages(String groupId) {
    return _groupMessages[groupId] ?? [];
  }

  /// Actualizar puntos totales de un grupo
  Future<void> updateGroupPoints(String groupId, List<UserModel> members) async {
    final group = _groups.firstWhere((g) => g.id == groupId);

    // Sumar puntos de todos los miembros
    group.totalPoints = members.fold(0, (sum, member) => sum + member.points);

    await _saveGroups();
    notifyListeners();
  }

  /// Obtener ranking de grupos
  List<GroupModel> getGroupRanking() {
    final rankedGroups = List<GroupModel>.from(_groups);
    rankedGroups.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return rankedGroups;
  }

  /// Eliminar grupo (solo para creador o docente)
  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((g) => g.id == groupId);
    _groupMessages.remove(groupId);

    await _saveGroups();
    await _saveMessages();
    notifyListeners();
  }

  /// Obtener grupo por ID
  GroupModel? getGroupById(String groupId) {
    try {
      return _groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }
}