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

  Future<bool> connect() async {
    _isConnected = await _sshService.connect(
      Config.defaultHost,
      Config.defaultPort,
      Config.defaultUsername,
      Config.defaultPassword,
    );
    notifyListeners();
    return _isConnected;
  }

  Future<void> disconnect() async {
    await _sshService.disconnect();
    _isConnected = false;
    notifyListeners();
  }

  Future<void> sendHome() async {
    if (!_isConnected) return;
    
    // B) Generate first...
    final kml = _kmlService.generateLookAt(
      28.6139, 
      77.2090, 
      1000, 
      45, 
      0
    ); // New Delhi (Home)

    // A) ...then Execute
    await _sshService.execute('echo "flytoview=$kml" > /tmp/query.txt');
  }

  Future<void> sendOrbit() async {
    if (!_isConnected) return;

    final kml = _kmlService.generateOrbit(28.6139, 77.2090, 1000);
    // Note: Orbits are complex tours, usually saved as a file first.
    // For simplicity in Task 2, we might just write to query.txt or upload a file.
    // Let's assume uploading for robust orbits.
    await _sshService.execute('echo "$kml" > /var/www/html/orbit.kml');
    await _sshService.execute('echo "http://localhost:81/orbit.kml" > /var/www/html/kmls.txt');
    await _sshService.execute('echo "playtour=Orbit" > /tmp/query.txt');
  }

  Future<void> cleanLogos() async {
    if (!_isConnected) return;
    
    // Clear the left screen overlay
    final emptyKml = '<kml></kml>';
    await _sshService.execute('echo "$emptyKml" > /var/www/html/kml/slave_3.kml');
  }
}
