import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'providers/library_provider.dart';
import 'providers/hotline_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/cat_api_provider.dart';
import 'services/database_helper.dart';
import 'services/user_session_service.dart';
import 'services/connectivity_service.dart';

// Placeholder screens (will be moved to separate files later)
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // Priority: .env (production) -> .env.example (CI/testing fallback)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Fallback to .env.example for CI builds where .env doesn't exist
    // Note: .env.example contains placeholder values - AI chat won't work
    debugPrint('Warning: .env not found, falling back to .env.example');
    await dotenv.load(fileName: '.env.example');
  }

  // Set system UI colors to match app theme (Zinc-950 dark theme)
  // This fixes the black panel above keyboard with button navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF09090B), // Zinc-950
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Database
  await DatabaseHelper.instance.database;

  // Initialize User Session (Lazy Authentication)
  await UserSessionService().initialize();

  // Initialize Connectivity Service
  await ConnectivityService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => HotlineProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CatApiProvider()),
        ChangeNotifierProvider.value(value: ConnectivityService()),
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
