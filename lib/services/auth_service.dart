import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Servicio de autenticación LOCAL
/// Maneja registro, login y gestión de usuarios sin internet
class AuthService extends ChangeNotifier {
  UserModel? _currentUser; // Usuario actualmente logueado
  List<UserModel> _allUsers = []; // Todos los usuarios registrados
  bool _isLoading = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  List<UserModel> get allUsers => _allUsers;

  /// Inicializar el servicio - cargar usuarios del almacenamiento local
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUsers();
    } catch (e) {
      debugPrint('Error inicializando AuthService: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cargar usuarios desde SharedPreferences
  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');

    if (usersJson != null) {
      final List<dynamic> usersList = jsonDecode(usersJson);
      _allUsers = usersList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      // Si no hay usuarios, crear usuario demo
      _allUsers = _createDemoUsers();
      await _saveUsers();
    }
  }

  /// Guardar usuarios en SharedPreferences
  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson =
    jsonEncode(_allUsers.map((user) => user.toJson()).toList());
    await prefs.setString('users', usersJson);
  }

  /// Crear usuarios de demostración
  List<UserModel> _createDemoUsers() {
    return [
      UserModel(
        id: 'demo_student_1',
        fullName: 'Ana García',
        username: 'ana123',
        password: '12345',
        role: 'estudiante',
        avatar: 'assets/avatars/avatar1.png',
        points: 150,
      ),
      UserModel(
        id: 'demo_teacher_1',
        fullName: 'Prof. Juan Pérez',
        username: 'profe',
        password: 'profe123',
        role: 'docente',
        avatar: 'assets/avatars/teacher.png',
        points: 500,
      ),
    ];
  }

  /// Registrar nuevo usuario
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
      // Validar que el username no exista
      if (_allUsers.any((user) => user.username == username)) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'El nombre de usuario ya existe 😢',
        };
      }

      // Validar campos
      if (fullName.isEmpty || username.isEmpty || password.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'Por favor completa todos los campos 📝',
        };
      }

      if (password.length < 4) {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': 'La contraseña debe tener al menos 4 caracteres 🔒',
        };
      }

      // Crear nuevo usuario
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        username: username,
        password: password,
        role: role,
        avatar: avatar ?? 'assets/avatars/default.png',
      );

      // Agregar a la lista y guardar
      _allUsers.add(newUser);
      await _saveUsers();

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': '¡Cuenta creada exitosamente! 🎉',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error al crear cuenta: $e',
      };
    }
  }

  /// Iniciar sesión
  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Buscar usuario
      final user = _allUsers.firstWhere(
            (u) => u.username == username && u.password == password,
        orElse: () => throw Exception('Usuario no encontrado'),
      );

      // Actualizar último login
      user.lastLogin = DateTime.now();
      await _saveUsers();

      // Establecer usuario actual
      _currentUser = user;

      _isLoading = false;
      notifyListeners();

      return {
        'success': true,
        'message': '¡Bienvenido ${user.fullName}! 👋',
      };
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Usuario o contraseña incorrectos 🔐',
      };
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Actualizar perfil del usuario actual
  Future<void> updateProfile({String? fullName, String? avatar}) async {
    if (_currentUser == null) return;

    if (fullName != null) {
      _currentUser!.fullName = fullName;
    }
    if (avatar != null) {
      _currentUser!.avatar = avatar;
    }

    // Actualizar en la lista de usuarios
    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }

    await _saveUsers();
    notifyListeners();
  }

  /// Agregar puntos al usuario actual
  Future<void> addPointsToCurrentUser(int points) async {
    if (_currentUser == null) return;

    _currentUser!.addPoints(points);

    // Actualizar en la lista de usuarios
    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }

    await _saveUsers();
    notifyListeners();
  }

  /// Agregar historial de juego al usuario actual
  Future<void> addGameHistoryToCurrentUser(GameHistory history) async {
    if (_currentUser == null) return;

    _currentUser!.addGameHistory(history);

    // Actualizar en la lista de usuarios
    final index = _allUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      _allUsers[index] = _currentUser!;
    }

    await _saveUsers();
    notifyListeners();
  }

  /// Obtener usuario por ID
  UserModel? getUserById(String userId) {
    try {
      return _allUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Obtener ranking de usuarios (ordenados por puntos)
  List<UserModel> getRanking({String? role}) {
    var users = List<UserModel>.from(_allUsers);

    // Filtrar por rol si se especifica
    if (role != null) {
      users = users.where((u) => u.role == role).toList();
    }

    // Ordenar por puntos descendente
    users.sort((a, b) => b.points.compareTo(a.points));

    return users;
  }
}