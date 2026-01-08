import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'providers/library_provider.dart';
import 'providers/hotline_provider.dart';
import 'services/database_helper.dart';

// Placeholder screens (will be moved to separate files later)
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => HotlineProvider()),
      ],
      child: const PawSightApp(),
    ),
  );
}

class PawSightApp extends StatelessWidget {
  const PawSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawSight',
      debugShowCheckedModeBanner: false,
      // Forui Dark Theme Setup with Toast support
      builder: (context, child) => FTheme(
        data: FThemes.zinc.dark, // Dark mode with Zinc theme
        child: FToaster(child: child!), // Add toast notification support
      ),
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF09090B), // Zinc-950
      ),
      home: const HomeScreen(),
    );
  }
}
