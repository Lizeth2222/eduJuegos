/// Modelo de Usuario para EduJuegos
/// Representa un estudiante o docente en la aplicación
class UserModel {
  final String id; // ID único del usuario
  String fullName; // Nombre completo
  final String username; // Nombre de usuario único
  final String passwordHash; // Contraseña hasheada/ofuscada
  final String role; // "estudiante" o "docente"
  String avatar; // Ruta del avatar local
  int points; // Puntos acumulados
  List<GameHistory> gameHistory; // Historial de juegos
  DateTime createdAt; // Fecha de creación
  DateTime lastLogin; // Último inicio de sesión

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.passwordHash,
    required this.role,
    this.avatar = 'assets/avatars/default.png',
    this.points = 0,
    List<GameHistory>? gameHistory,
    DateTime? createdAt,
    DateTime? lastLogin,
  })  : gameHistory = gameHistory ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastLogin = lastLogin ?? DateTime.now();

  /// Convertir usuario a JSON para guardar localmente
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'passwordHash': passwordHash, // Guardamos el hash
      'role': role,
      'avatar': avatar,
      'points': points,
      'gameHistory': gameHistory.map((g) => g.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  /// Crear usuario desde JSON (cargar desde archivo local)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      // Por retrocompatibilidad, si 'password' existe, lo usamos.
      passwordHash: json['passwordHash'] ?? json['password'] ?? '',
      role: json['role'],
      avatar: json['avatar'] ?? 'assets/avatars/default.png',
      points: json['points'] ?? 0,
      gameHistory: (json['gameHistory'] as List?)
          ?.map((g) => GameHistory.fromJson(g))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  /// Agregar puntos al usuario
  void addPoints(int newPoints) {
    points += newPoints;
  }

  /// Agregar juego al historial
  void addGameHistory(GameHistory game) {
    gameHistory.add(game);
  }

  /// Verificar si es docente
  bool get isTeacher => role == 'docente';

  /// Verificar si es estudiante
  bool get isStudent => role == 'estudiante';
}

/// Historial de juego
class GameHistory {
  final String category; // Categoría jugada
  final String word; // Palabra completada
  final int pointsEarned; // Puntos ganados
  final DateTime playedAt; // Fecha de juego
  final bool completed; // Si completó la palabra

  GameHistory({
    required this.category,
    required this.word,
    required this.pointsEarned,
    required this.completed,
    DateTime? playedAt,
  }) : playedAt = playedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'word': word,
      'pointsEarned': pointsEarned,
      'playedAt': playedAt.toIso8601String(),
      'completed': completed,
    };
  }

  factory GameHistory.fromJson(Map<String, dynamic> json) {
    return GameHistory(
      category: json['category'],
      word: json['word'],
      pointsEarned: json['pointsEarned'],
      completed: json['completed'] ?? false,
      playedAt: DateTime.parse(json['playedAt']),
    );
  }
}

/// Modelo de Grupo
class GroupModel {
  final String id; // ID único del grupo
  String name; // Nombre del grupo
  List<String> memberIds; // IDs de usuarios miembros
  int totalPoints; // Puntos totales del grupo
  DateTime createdAt; // Fecha de creación
  String createdBy; // ID del creador

  GroupModel({
    required this.id,
    required this.name,
    List<String>? memberIds,
    this.totalPoints = 0,
    DateTime? createdAt,
    required this.createdBy,
  })  : memberIds = memberIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'totalPoints': totalPoints,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      totalPoints: json['totalPoints'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }

  /// Agregar miembro al grupo
  void addMember(String userId) {
    if (!memberIds.contains(userId) && memberIds.length < 10) {
      memberIds.add(userId);
    }
  }

  /// Remover miembro del grupo
  void removeMember(String userId) {
    memberIds.remove(userId);
  }

  /// Verificar si está lleno (máximo 10 miembros)
  bool get isFull => memberIds.length >= 10;
}

/// Mensaje de chat local
class ChatMessage {
  final String id;
  final String groupId;
  final String userId;
  final String username;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.username,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      username: json['username'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Palabra/Pregunta del juego
class WordQuestion {
  final String word; // Palabra a adivinar (en mayúsculas)
  final String hint; // Pista para ayudar
  final String category; // Categoría

  WordQuestion({
    required this.word,
    required this.hint,
    required this.category,
  });

  factory WordQuestion.fromJson(Map<String, dynamic> json, String category) {
    return WordQuestion(
      word: json['word'].toString().toUpperCase(),
      hint: json['hint'],
      category: category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'hint': hint,
    };
  }
}
