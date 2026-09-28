// ============================================================================
// Section: External Library & Provider Imports
// Imports Flutter Material UI components and AuthProvider for anonymous sign in.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/auth_provider.dart';

// ============================================================================
// Section: Login Screen Widget (`LoginScreen`)
// StatefulWidget providing anonymous user authentication UI.
// ============================================================================
class LoginScreen extends StatefulWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Constructor
  // Standard const constructor with optional widget key parameter.
  // --------------------------------------------------------------------------
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ============================================================================
// Section: Login Screen State & Actions (`_LoginScreenState`)
// Manages signing-in progress state, error message updates, and UI rendering.
// ============================================================================
class _LoginScreenState extends State<LoginScreen> {
  // --------------------------------------------------------------------------
  // Sub-Block: State Flags
  // Tracks active sign-in progress boolean and error notification string.
  // --------------------------------------------------------------------------
  bool _isSigningIn = false;
  String? _error;

  // --------------------------------------------------------------------------
  // Sub-Block: Anonymous Sign-In Handler (`_signIn`)
  // Triggers AuthProvider anonymous authentication and handles potential error reporting.
  // --------------------------------------------------------------------------
  Future<void> _signIn() async {
    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      await context.read<AuthProvider>().signInAnonymously();
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Sign-in failed. Enable Anonymous sign-in in Firebase Authentication and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Main Screen UI Builder (`build`)
  // Renders logo icon, app header text, action button, loading spinner, and error banner.
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ----------------------------------------------------------------
            // Sub-Block: App Branding Header
            // Displays brown casino/chess icon and "ChessLive" title text.
            // ----------------------------------------------------------------
            const Icon(Icons.casino, size: 100, color: Colors.brown),
            const SizedBox(height: 20),
            const Text(
              'ChessLive',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // ----------------------------------------------------------------
            // Sub-Block: Action Button & Spinner
            // Elevated button executing `_signIn` action or displaying CircularProgressIndicator when active.
            // ----------------------------------------------------------------
            ElevatedButton(
              onPressed: _isSigningIn ? null : _signIn,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: _isSigningIn
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Play Anonymously'),
            ),

            // ----------------------------------------------------------------
            // Sub-Block: Error Message Display
            // Conditionally displays red error text when authentication fails.
            // ----------------------------------------------------------------
            if (_error != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
