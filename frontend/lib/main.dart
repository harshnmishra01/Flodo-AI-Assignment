import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Add to pubspec.yaml
import 'providers/task_provider.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Defined the Flodo Color Palette
    const Color flodoDarkBg = Color(0xFF0D0D0D);
    const Color flodoCardBg = Color(0xFF1A1A1A);
    const Color flodoPurple = Color(0xFF6C5DD3);
    const Color flodoGreen = Color(0xFF2ECC71);

    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'Flodo Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: flodoDarkBg,
          
          // Deep dark color scheme with Flodo purple accents
          colorScheme: const ColorScheme.dark(
            primary: flodoPurple,
            secondary: flodoGreen,
            surface: flodoCardBg,
            onSurface: Colors.white,
            background: flodoDarkBg,
          ),

          // Using Poppins to match the clean, geometric brand font
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

          // Polishing the Cards to match the dashboard in the screenshot
          cardTheme: CardThemeData(
            color: flodoCardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Modern input styling for the Search and Form screens
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF141414),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          // Consistent button styling
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: flodoPurple,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          // Floating Action Button to match the "Book a call" purple
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: flodoPurple,
            foregroundColor: Colors.white,
          ),
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}