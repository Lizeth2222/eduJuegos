import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  List<UserModel> get allUsers => _allUsers;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return base64.encode(bytes);
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _loadUsers();
    } catch (e) {
      debugPrint('Error inicializando AuthService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');

    if (usersJson != null) {
      final List<dynamic> usersList = jsonDecode(usersJson);
      _allUsers = usersList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      _allUsers = _createDemoUsers();
      await _saveUsers();
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = jsonEncode(_allUsers.map((user) => user.toJson()).toList());
    await prefs.setString('users', usersJson);
  }

  List<UserModel> _createDemoUsers() {
    return [
      UserModel(
        id: 'demo_student_1',
        fullName: 'Ana García',
        username: 'ana123',
        passwordHash: _hashPassword('12345'),
        role: 'estudiante',
        avatar: 'assets/avatars/avatar1.png',
        points: 150,
      ),
      UserModel(
        id: 'demo_teacher_1',
        fullName: 'Prof. Juan Pérez',
        username: 'profe',
        passwordHash: _hashPassword('profe123'),
        role: 'docente',
        avatar: 'assets/avatars/teacher.png',
        points: 500,
      ),
    ];
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String password,
    required String role,
    String? avatar,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_allUsers.any((user) => user.username == username)) {
        return {'success': false, 'message': 'El nombre de usuario ya existe 😢'};
      }
      if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Por favor completa todos los campos 📝'};
      }
      if (password.length < 4) {
        return {'success': false, 'message': 'La contraseña debe tener al menos 4 caracteres 🔒'};
      }

      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        username: username,
        passwordHash: _hashPassword(password),
        role: role,
        avatar: avatar ?? 'assets/avatars/default.png',
      );

      _allUsers.add(newUser);
      await _saveUsers();

      return {'success': true, 'message': '¡Cuenta creada exitosamente! 🎉'};
    } catch (e) {
      return {'success': false, 'message': 'Error al crear cuenta: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final passwordHash = _hashPassword(password);
      final user = _allUsers.firstWhere(
        (u) => u.username == username && u.passwordHash == passwordHash,
        orElse: () => throw Exception('Usuario o contraseña incorrectos 🔐'),
      );

      user.lastLogin = DateTime.now();
      _currentUser = user;
      await _saveUsers();

      return {'success': true, 'message': '¡Bienvenido ${user.fullName}! 👋'};
    } catch (e) {
      return {'success': false, 'message': (e as Exception).toString().substring(11)};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? fullName, String? avatar}) async {
    if (_currentUser == null) return;

    if (fullName != null) _currentUser!.fullName = fullName;
    if (avatar != null) _currentUser!.avatar = avatar;

    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }

    await _saveUsers();
    notifyListeners();
  }

  Future<void> addPointsToCurrentUser(int points) async {
    if (_currentUser == null) return;
    _currentUser!.addPoints(points);
    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }
    await _saveUsers();
    notifyListeners();
  }

  Future<void> addGameHistoryToCurrentUser(GameHistory history) async {
    if (_currentUser == null) return;
    _currentUser!.addGameHistory(history);
    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }
    await _saveUsers();
    notifyListeners();
  }

  UserModel? getUserById(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Devuelve una lista de todos los usuarios con el rol de 'estudiante'
  List<UserModel> getStudents() {
    return _allUsers.where((user) => user.isStudent).toList();
  }

  List<UserModel> getRanking({String? role}) {
    var users = List<UserModel>.from(_allUsers);
    if (role != null) {
      users = users.where((u) => u.role == role).toList();
    }
    users.sort((a, b) => b.points.compareTo(a.points));
    return users;
  }
}