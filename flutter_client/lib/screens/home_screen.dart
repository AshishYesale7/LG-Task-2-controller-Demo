import 'package:flutter/material.dart';

/// Legacy home screen — kept for backward compatibility.
///
/// The main entry flow now goes: Splash → Connection → MainScreen.
/// This file is retained for modules that may reference it.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Starter Kit'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text('Welcome to LG Starter Kit'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/connection'),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
