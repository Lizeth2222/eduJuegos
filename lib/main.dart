import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'services/game_service.dart';
import 'services/group_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Crear instancias de los servicios en el orden de dependencia
  final authService = AuthService();
  final groupService = GroupService(authService);
  // Inyectar ambos servicios en GameService
  final gameService = GameService(authService, groupService);

  // 2. Ejecutar la app con los servicios provistos
  runApp(MultiProvider(
    providers: [
      // Usar .value para proveedores con instancias ya creadas
      ChangeNotifierProvider.value(value: authService),
      ChangeNotifierProvider.value(value: groupService),
      ChangeNotifierProvider.value(value: gameService),
    ],
    child: const EduJuegosApp(),
  ));
}

/// Aplicación principal EduJuegos
class EduJuegosApp extends StatelessWidget {
  const EduJuegosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduJuegos - UNICLAS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF5F5FF),
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        // CORRECCIÓN: Se debe usar CardThemeData
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFF6C63FF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // La pantalla inicial se encarga de inicializar los servicios
      home: const SplashScreen(),
    );
  }
}
