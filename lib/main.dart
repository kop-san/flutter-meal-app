import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:meal_app/screens/login.dart';
import 'package:meal_app/screens/register.dart';
import 'package:meal_app/screens/tabs.dart';
import 'package:meal_app/screens/splash.dart';
import 'package:meal_app/screens/search.dart';
import 'screens/profile.dart';
import 'screens/my_recipes.dart';
import 'screens/add_recipe.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF4E342E),
    primary: const Color(0xFFFF9800),
    onPrimary: Colors.black,
    secondary: const Color(0xFF80CBC4),
    onSecondary: Colors.black,
    surface: const Color(0xFF2C2F33),
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF23272A),
  textTheme: GoogleFonts.latoTextTheme().copyWith(
    displayLarge: GoogleFonts.lato(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.lato(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.lato(
      fontSize: 18,
      color: Colors.white70,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      color: Colors.white70,
    ),
    labelLarge: GoogleFonts.lato(
      fontSize: 14,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orangeAccent),
    ),
    border: OutlineInputBorder(),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF9800),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const TabsScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/my-recipes': (ctx) => const MyRecipesScreen(),
        '/add-recipe': (ctx) => const AddRecipeScreen(),
        '/search': (ctx) => const SearchScreen(),
      },
    );
  }
}
