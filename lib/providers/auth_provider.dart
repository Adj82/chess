// ============================================================================
// Section: External Library Imports
// Import Firebase Authentication and Flutter Material state management packages.
// ============================================================================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ============================================================================
// Section: Authentication State Provider (`AuthProvider`)
// ChangeNotifier provider class managing user authentication lifecycle and Firebase session state.
// ============================================================================
class AuthProvider extends ChangeNotifier {
  // --------------------------------------------------------------------------
  // Sub-Block: Internal State Fields
  // Private instances for FirebaseAuth SDK and current User session reference.
  // --------------------------------------------------------------------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // --------------------------------------------------------------------------
  // Sub-Block: User State Getters
  // Public getters exposing active user instance and authentication status boolean.
  // --------------------------------------------------------------------------
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // --------------------------------------------------------------------------
  // Sub-Block: Provider Initialization & Auth Stream Listener
  // Listens continuously to Firebase authStateChanges stream to sync internal user state and notify listeners.
  // --------------------------------------------------------------------------
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Anonymous Sign-In Action (`signInAnonymously`)
  // Authenticates current user anonymously using Firebase Auth SDK.
  // --------------------------------------------------------------------------
  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Sub-Block: Sign-Out Action (`signOut`)
  // Signs out the currently authenticated user from Firebase Auth.
  // --------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
