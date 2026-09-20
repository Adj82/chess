# ChessLive Implementation Plan

Real-time 1v1 chess over Firebase, optimized for a 6-session teaching curriculum.

## User Review Required

> [!IMPORTANT]
> **State Management:** I've selected `provider` for its simplicity and readability, which fits well within the 6-hour teaching window.
> **Package Versions:** I will use the latest stable versions of `chess`, `flutter_stateless_chessboard`, and Firebase plugins.

## Proposed Changes

### Project Configuration

#### [MODIFY] [pubspec.yaml](file:///C:/chess/pubspec.yaml)
Add dependencies: `chess`, `flutter_stateless_chessboard`, `provider`, `firebase_core`, `cloud_firestore`, `firebase_auth`.

---

### Session 1: Board + Local Logic
Goal: A functional local pass-and-play chess game.

#### [NEW] [chess_provider.dart](file:///C:/chess/lib/providers/chess_provider.dart)
State management for the chess game using the `chess` package.

#### [MODIFY] [main.dart](file:///C:/chess/lib/main.dart)
Basic app setup and injection of the `ChessProvider`.

#### [NEW] [game_screen.dart](file:///C:/chess/lib/screens/game_screen.dart)
The UI containing the `StatelessChessBoard` and game info.

---

### Session 2: Firebase Setup & Auth
Goal: Connect to Firebase and enable anonymous sign-in.

#### [MODIFY] [main.dart](file:///C:/chess/lib/main.dart)
Initialize Firebase.

#### [NEW] [auth_provider.dart](file:///C:/chess/lib/providers/auth_provider.dart)
Handle Firebase Auth (anonymous sign-in).

#### [NEW] [login_screen.dart](file:///C:/chess/lib/screens/login_screen.dart)
Simple landing page to sign in.

---

### Session 3: Create & Join Game
Goal: Basic Firestore interaction for game initialization.

#### [NEW] [game_model.dart](file:///C:/chess/lib/models/game_model.dart)
Data class for the Firestore `games` document.

#### [NEW] [game_service.dart](file:///C:/chess/lib/services/game_service.dart)
Firestore CRUD operations (create game, join game).

#### [NEW] [lobby_screen.dart](file:///C:/chess/lib/screens/lobby_screen.dart)
UI for creating/joining games via code.

---

### Session 4: Real-time Move Sync
Goal: Sync moves between two players via Firestore streams.

#### [MODIFY] [chess_provider.dart](file:///C:/chess/lib/providers/chess_provider.dart)
Update to listen to Firestore snapshots and push move updates.

---

### Session 5: Game-end & Promotion
Goal: Handle checkmate, stalemate, and pawn promotion UI.

#### [MODIFY] [game_screen.dart](file:///C:/chess/lib/screens/game_screen.dart)
Add promotion dialog and game-over overlays.

---

### Session 6: Polish
Goal: Move history (PGN), turn indicator, and resign button.

#### [MODIFY] [game_screen.dart](file:///C:/chess/lib/screens/game_screen.dart)
UI enhancements and final cleanup.

## Verification Plan

### Manual Verification
- **Session 1:** Run the app and play a full game locally. Verify moves are validated correctly.
- **Session 4:** Run two instances of the app (or use Chrome + Mobile). Verify that a move on one screen updates the other instantly.
- **Session 5:** Test promotion by reaching the 8th rank. Test game over by achieving checkmate.
