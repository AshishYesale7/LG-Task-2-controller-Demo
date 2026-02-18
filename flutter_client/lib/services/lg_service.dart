import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lg_task2_demo/config.dart';
import 'package:lg_task2_demo/services/kml_service.dart';
import 'package:lg_task2_demo/services/ssh_service.dart';

class LGService extends ChangeNotifier {
  final SSHService _sshService = SSHService();
  final KMLService _kmlService = KMLService();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Connect to the LG rig.
  /// If parameters are provided, uses them. Otherwise uses defaults from Config.
  Future<bool> connect({
    String? host,
    int? port,
    String? username,
    String? password,
  }) async {
    _isConnected = await _sshService.connect(
      host ?? Config.defaultHost,
      port ?? Config.defaultPort,
      username ?? Config.defaultUsername,
      password ?? Config.defaultPassword,
    );
    notifyListeners();
    return _isConnected;
  }

  Future<void> disconnect() async {
    await _sshService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  Future<void> flyToHomeCity() async {
    if (!_isConnected) return;
    
    final kml = _kmlService.generateLookAt(
      28.6139, 
      77.2090, 
      1000, 
      45, 
      0
    ); // New Delhi (Home)

    await _sshService.execute('echo "flytoview=$kml" > /tmp/query.txt');
  }

  Future<void> sendLogo() async {
    if (!_isConnected) return;

    final logoKml = _kmlService.screenOverlayImage(
      'https://raw.githubusercontent.com/LiquidGalaxyLAB/Liquid-Galaxy-Project-Template/master/assets/img/LGLAB_logo_2018.png',
      0.0, 1.0, // overlayXY: top-left of image
      0.0, 1.0, // screenXY: top-left of screen
      0.3, 0.3  // size
    );
    
    // Write to slave 3 (Left screen)
    await _sshService.execute('echo "$logoKml" > /var/www/html/kml/slave_3.kml');
  }

  Future<void> cleanLogos() async {
    if (!_isConnected) return;
    
    final emptyKml = '<kml></kml>';
    await _sshService.execute('echo "$emptyKml" > /var/www/html/kml/slave_3.kml');
  }

  Future<void> cleanKMLs() async {
    if (!_isConnected) return;
    
    await _sshService.execute('echo "" > /tmp/query.txt'); // Stop flying
    await _sshService.execute('echo "" > /var/www/html/kmls.txt'); // Clear loaded KMLs
  }

  Future<void> sendPyramid() async {
     if (!_isConnected) return;

    final kml = _kmlService.generatePyramid(28.6139, 77.2090, 500, 200);
    
    // Upload as file to ensure it renders correctly
    await _sshService.execute('echo "$kml" > /var/www/html/pyramid.kml');
    await _sshService.execute('echo "http://localhost:81/pyramid.kml" > /var/www/html/kmls.txt');
  }

  Future<void> sendOrbit() async {
     if (!_isConnected) return;
     // ... (orbit implementation)
  }

  Future<void> rebootLG() async {
    if (!_isConnected) return;
    // Command to reboot the master? Or relaunch the earth?
    // Usually 'reboot' requires sudo. 'lg-relaunch' might be available.
    // For safety, we'll just try to restart the earth wrapper if possible, 
    // or just leave it empty with a log for now as 'reboot' is drastic.
    // Let's implement a safe 'relaunch' command if known, or just a placeholder print.
    if (kDebugMode) {
      print('Reboot requested (not implemented for safety)');
    }
  }

  Future<void> sendKMLPlacemark({
    required String name,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    if (!_isConnected) return;
    // Implementation placeholder for the MainScreen button
     if (kDebugMode) {
      print('Sending placemark: $name');
    }
  }
}
