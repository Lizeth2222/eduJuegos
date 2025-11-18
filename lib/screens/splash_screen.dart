// ==================== splash_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/game_service.dart';
import '../services/group_service.dart';
import 'login_screen.dart';

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
// Inicializar todos los servicios
await Future.wait([
context.read<AuthService>().initialize(),
context.read<GameService>().initialize(),
context.read<GroupService>().initialize(),
]);

// Esperar 2 segundos para mostrar splash
await Future.delayed(const Duration(seconds: 2));

if (mounted) {
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
children: [
// Logo animado
Icon(
Icons.school_rounded,
size: 120,
color: Colors.white,
),
const SizedBox(height: 24),
const Text(
'📚 EduJuegos',
style: TextStyle(
fontSize: 48,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
const SizedBox(height: 8),
const Text(
'UNICLAS - APP Educativa',
style: TextStyle(
fontSize: 18,
color: Colors.white70,
),
),
const SizedBox(height: 48),
const CircularProgressIndicator(
color: Colors.white,
),
],
),
),
),
);
}
}
