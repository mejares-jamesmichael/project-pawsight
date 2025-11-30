import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('PawSight'),
        suffixes: [
          FHeaderAction(
            icon: Icon(FIcons.info),
            onPress: () {}, // TODO: Show About
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PawSight!'),
            const SizedBox(height: 20),
            FButton(
              onPress: () {
                // TODO: Navigate to Library
              },
              child: const Text('Browse Library'),
            ),
          ],
        ),
      ),
    );
  }
}
