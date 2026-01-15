import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forui/forui.dart';

import '../core/env_validator.dart';

/// Debug screen to check environment variable configuration
///
/// Shows which env vars are loaded and helps diagnose .env issues
class EnvDebugScreen extends StatelessWidget {
  const EnvDebugScreen({super.key});

  String _maskValue(String? value) {
    if (value == null || value.isEmpty) return '❌ NOT SET';
    if (value.contains('your-') || value.contains('placeholder')) {
      return '⚠️  PLACEHOLDER VALUE';
    }
    // Show first 20 chars + ...
    if (value.length > 20) {
      return '✅ ${value.substring(0, 20)}...';
    }
    return '✅ $value';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final chatApiUrl = dotenv.env['CHAT_API_URL'];
    final jwtSecret = dotenv.env['JWT_SECRET'];
    final catApiKey = dotenv.env['THE_CAT_API_KEY'];

    final isReady = EnvValidator.isProductionReady();

    return FScaffold(
      header: FHeader(
        title: const Text('Environment Config'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isReady ? Colors.green.shade900 : Colors.orange.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isReady ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isReady
                          ? 'Environment is configured correctly! ✅'
                          : 'Environment needs configuration ⚠️',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Environment Variables
            Text(
              'Environment Variables',
              style: theme.typography.xl.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildEnvVar(
              theme,
              'CHAT_API_URL',
              _maskValue(chatApiUrl),
              'Required for AI chat feature',
            ),
            const SizedBox(height: 12),

            _buildEnvVar(
              theme,
              'JWT_SECRET',
              _maskValue(jwtSecret),
              'Required for chat authentication',
            ),
            const SizedBox(height: 12),

            _buildEnvVar(
              theme,
              'THE_CAT_API_KEY',
              _maskValue(catApiKey),
              'Optional: Enables cat images and breeds',
            ),
            const SizedBox(height: 24),

            // All Loaded Variables
            Text(
              'All Loaded Variables',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${dotenv.env.keys.length} variables loaded',
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),

            if (dotenv.env.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '❌ No environment variables loaded!\n\nMake sure .env file exists in pawsight/ folder.',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              ...dotenv.env.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          key,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _maskValue(dotenv.env[key]),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 24),

            // Help Section
            if (!isReady) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Fix',
                      style: theme.typography.base
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Find .env.example in pawsight/ folder\n'
                      '2. Copy it to .env in the same folder\n'
                      '3. Edit .env and replace placeholder values\n'
                      '4. Restart the app completely\n'
                      '5. Come back to this screen to verify',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              FButton(
                onPress: () {
                  Clipboard.setData(
                    const ClipboardData(text: 'pawsight/.env'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Path copied to clipboard')),
                  );
                },
                child: const Text('Copy .env Path'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnvVar(
    FThemeData theme,
    String name,
    String value,
    String description,
  ) {
    final isOk = value.startsWith('✅');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isOk ? Colors.green.shade700 : Colors.orange.shade700,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isOk ? Colors.green.shade300 : Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.typography.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
