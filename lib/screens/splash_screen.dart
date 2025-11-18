import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../services/group_service.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // Importar HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Usar el contexto de forma segura
    final authService = context.read<AuthService>();
    final groupService = context.read<GroupService>();
    final gameService = context.read<GameService>();

    // 1. Inicializar AuthService (sin dependencias)
    await authService.initialize();

    // 2. Inicializar GroupService (depende de AuthService)
    await groupService.initialize();

    // 3. Inicializar GameService (depende de AuthService y GroupService)
    await gameService.initialize();

    // Pequeña demora para la experiencia de usuario
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Comprobar si el usuario ya ha iniciado sesión
    if (authService.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF9D8EFF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.school_rounded,
                size: 120,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                '📚 EduJuegos',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'UNICLAS - APP Educativa',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
