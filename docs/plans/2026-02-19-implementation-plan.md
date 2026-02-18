# LG Controller Implementation Plan

**Goal:** Build a Flutter remote control for Liquid Galaxy (Task 2) that manages 3 screens, sends KML visualizations (Logo, Pyramid, Orbit), and handles SSH communication.
**Architecture:** Controller-to-Rig over SSH (Layered: Screens → Services → SSH/KML).
**Tech Stack:** Dart, Flutter, Provider, dartssh2, google_maps_flutter.

**Educational Objectives:**
1.  **Service Pattern**: Separating UI from business logic.
2.  **SSH Lifecycle**: Managing connection states and errors.
3.  **KML composition**: Generating XML for Google Earth.

## Proposed Changes

### Task 1: SSH Service Implementation
**Files:** `lib/services/ssh_service.dart`
**Step 1**: Implement `connect(host, port, user, pass)` using `dartssh2`.
**Step 2**: Implement `execute(command)` for running shell commands.
**Step 3**: Implement `upload(content, filename)` using SFTP.
**Step 4**: error handling logic (try/catch).
**Verification**: Unit test connection logic (mocked) or manual test with real rig.

### Task 2: KML Service Implementation
**Files:** `lib/services/kml_service.dart`
**Step 1**: Implement pure functions to generate XML strings.
**Step 2**: `generateLookAt(lat, lon, alt, tilt, heading)` → Returns Camera KML.
**Step 3**: `generateOrbit(lat, lon, alt)` → Returns `<gx:Tour>` KML.
**Step 4**: `screenOverlayImage(imageUrl)` → Returns Logo KML for the slave screen.
**Verification**: Unit tests — verify output strings match expected XML. No rig needed!

### Task 3: LG Service (The Orchestrator)
**Files:** `lib/services/lg_service.dart`
**Step 1**: Combine `SSHService` and `KMLService`.
**Step 2**: Implement high-level methods: `sendHome()`, `sendLogo()`, `sendOrbit()`.
**Step 3**: State management: `bool isConnected` (notify listeners).
**Verification**: Integration test — Call `sendHome()` and verify `SSHService.execute()` was called with correct string.

### Task 4: UI Implementation
**Files:** `screens/connection_screen.dart`, `screens/home_screen.dart`
**Step 1**: Build `ConnectionScreen` with settings form (IP, User, Pass).
**Step 2**: Build `HomeScreen` with grid of buttons (Logo, Pyramid, Orbit).
**Step 3**: Use `Consumer<LGService>` to disable buttons when disconnected.
**Verification**: Run on emulator -> Ensure "Connect" works before buttons are enabled.
