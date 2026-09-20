import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 100, color: Colors.brown),
            const SizedBox(height: 20),
            const Text(
              'ChessLive',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.read<AuthProvider>().signInAnonymously(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Play Anonymously'),
            ),
          ],
        ),
      ),
    );
  }
}
