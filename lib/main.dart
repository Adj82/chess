// ============================================================================
// Section: External Library & Application Module Imports
// Import Flutter UI components, Firebase Core, Provider state management,
// application providers, screen widgets, and Firebase options config.
// ============================================================================
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:chess_live/providers/chess_provider.dart';
import 'package:chess_live/providers/auth_provider.dart';
import 'package:chess_live/screens/lobby_screen.dart';
import 'package:chess_live/screens/login_screen.dart';
import 'package:chess_live/firebase_options.dart';

// ============================================================================
// Section: Application Entry Point (`main`)
// Ensures Flutter bindings are initialized before async execution.
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------------
  // Sub-Block: Firebase Core Initialization
  // Connects app instance to Firebase backend services using current platform configuration.
  // --------------------------------------------------------------------------
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --------------------------------------------------------------------------
  // Sub-Block: MultiProvider Tree Binding & App Launch
  // Injects AuthProvider and ChessProvider into the widget hierarchy and launches root MyApp.
  // --------------------------------------------------------------------------
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChessProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ============================================================================
// Section: Root Application Widget (`MyApp`)
// Configures root MaterialApp theme settings and dynamic screen routing.
// ============================================================================
class MyApp extends StatelessWidget {
  // --------------------------------------------------------------------------
  // Sub-Block: Constructor
  // Standard const constructor with optional widget key parameter.
  // --------------------------------------------------------------------------
  const MyApp({super.key});

  // --------------------------------------------------------------------------
  // Sub-Block: MaterialApp UI Builder & Auth Route Switcher
  // Builds MaterialApp with Material 3 brown color scheme and inspects AuthProvider
  // to route users to either LobbyScreen (authenticated) or LoginScreen (unauthenticated).
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessLive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const LobbyScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
