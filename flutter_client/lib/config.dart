/// Central configuration for the LG Flutter Starter Kit.
///
/// All connection defaults, rig geometry, and app-wide settings live here.
/// Students should modify these values to match their LG rig setup.
class Config {
  // ─── LG Rig Connection ───────────────────────────────────────────────
  /// Default SSH host for the LG master machine.
  /// Override at build time: `--dart-define=LG_HOST=10.0.0.1`
  static const String lgHost = String.fromEnvironment(
    'LG_HOST',
    defaultValue: '192.168.56.101',
  );

  /// Default SSH port.
  static const int lgPort = int.fromEnvironment(
    'LG_PORT',
    defaultValue: 22,
  );

  /// Default SSH username.
  static const String lgUser = String.fromEnvironment(
    'LG_USER',
    defaultValue: 'lg',
  );

  /// Default SSH password.
  static const String lgPassword = String.fromEnvironment(
    'LG_PASSWORD',
    defaultValue: 'lg',
  );

  // ─── LG Rig Geometry ─────────────────────────────────────────────────
  /// Total number of screens in the LG rig.
  static const int totalScreens = 3;

  /// The master screen number (always 1 in a standard LG setup).
  static const int masterScreen = 1;

  /// Left-most screen number.
  static int get leftScreen {
    // In a 3-screen rig: lg3 = left, lg1 = center, lg2 = right
    return totalScreens;
  }

  /// Right-most screen number.
  static int get rightScreen {
    // Screen 2 is always to the right of master
    return 2;
  }

  // ─── Home City ────────────────────────────────────────────────────────
  /// Home city latitude (used by flyToHomeCity).
  /// Default: Lleida, Spain (LG Lab headquarters).
  static const double homeCityLat = 41.6176;

  /// Home city longitude.
  static const double homeCityLng = 0.6200;

  /// Home city name for display.
  static const String homeCityName = 'Lleida';

  // ─── App Settings ────────────────────────────────────────────────────
  /// Application name displayed in UI.
  static const String appName = 'LG Flutter Starter Kit';

  /// Application version.
  static const String appVersion = '1.0.0';

  /// Node.js server URL (for optional server integration).
  static const String serverUrl = 'http://localhost:3000';

  /// Connection timeout in seconds.
  static const int connectionTimeout = 10;

  /// KML refresh interval in seconds.
  static const int kmlRefreshInterval = 2;
}
