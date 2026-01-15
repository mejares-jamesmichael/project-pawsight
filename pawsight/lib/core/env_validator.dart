import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variable validator and diagnostics
///
/// Helps debug .env loading issues and provides clear error messages
class EnvValidator {
  /// Validate that all required environment variables are set
  static void validate() {
    final issues = <String>[];

    // Check CHAT_API_URL
    final chatApiUrl = dotenv.env['CHAT_API_URL'];
    if (chatApiUrl == null || chatApiUrl.isEmpty) {
      issues.add('❌ CHAT_API_URL is not set');
    } else if (chatApiUrl.contains('your-backend-service')) {
      issues.add('⚠️  CHAT_API_URL contains placeholder value');
    } else {
      debugPrint('✅ CHAT_API_URL is configured');
    }

    // Check JWT_SECRET
    final jwtSecret = dotenv.env['JWT_SECRET'];
    if (jwtSecret == null || jwtSecret.isEmpty) {
      issues.add('❌ JWT_SECRET is not set');
    } else if (jwtSecret.contains('your-64-byte')) {
      issues.add('⚠️  JWT_SECRET contains placeholder value');
    } else {
      debugPrint('✅ JWT_SECRET is configured');
    }

    // Check THE_CAT_API_KEY (optional but recommended)
    final catApiKey = dotenv.env['THE_CAT_API_KEY'];
    if (catApiKey == null || catApiKey.isEmpty) {
      issues.add('⚠️  THE_CAT_API_KEY is not set (API will work with limitations)');
    } else if (catApiKey.contains('your-thecatapi-key')) {
      issues.add('⚠️  THE_CAT_API_KEY contains placeholder value');
    } else {
      debugPrint('✅ THE_CAT_API_KEY is configured');
    }

    // Print summary
    if (issues.isEmpty) {
      debugPrint('✅ All environment variables are properly configured!');
    } else {
      debugPrint('\n========================================');
      debugPrint('🚨 ENVIRONMENT CONFIGURATION ISSUES 🚨');
      debugPrint('========================================');
      for (final issue in issues) {
        debugPrint(issue);
      }
      debugPrint('\n📝 To fix these issues:');
      debugPrint('1. Copy .env.example to .env in the pawsight/ folder');
      debugPrint('2. Edit .env and replace placeholder values with real ones');
      debugPrint('3. Restart the app');
      debugPrint('========================================\n');
    }
  }

  /// Check if environment is properly configured for production use
  static bool isProductionReady() {
    final chatApiUrl = dotenv.env['CHAT_API_URL'];
    final jwtSecret = dotenv.env['JWT_SECRET'];

    return chatApiUrl != null &&
        chatApiUrl.isNotEmpty &&
        !chatApiUrl.contains('your-backend-service') &&
        jwtSecret != null &&
        jwtSecret.isNotEmpty &&
        !jwtSecret.contains('your-64-byte');
  }

  /// Get user-friendly error message for missing configuration
  static String getMissingConfigMessage() {
    return '''
🔧 Setup Required

The app needs configuration to enable AI chat and cat APIs.

Please follow these steps:
1. Find the .env.example file in the pawsight folder
2. Copy it and rename to .env
3. Edit .env and add your API credentials
4. Restart the app

For more information, see the README.md file.
''';
  }
}
