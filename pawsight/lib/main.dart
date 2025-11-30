import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'providers/library_provider.dart';
import 'services/database_helper.dart';

// Placeholder screens (will be moved to separate files later)
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LibraryProvider())],
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
      // Forui Theme Setup
      builder: (context, child) => FTheme(
        data: FThemes.zinc.light, // Modern Zinc theme
        child: child!,
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
