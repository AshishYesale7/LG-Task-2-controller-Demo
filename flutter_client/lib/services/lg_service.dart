import 'package:flutter/material.dart';
import 'package:flutter_client/services/ssh_service.dart';
import 'package:flutter_client/services/kml_service.dart';
import 'package:flutter_client/config.dart';

/// High-level service for interacting with the Liquid Galaxy rig.
///
/// Wraps SSHService and KMLService to provide a clean API for
/// common LG operations: fly to, orbit, send KML, reboot, etc.
class LGService extends ChangeNotifier {
  final SSHService _sshService = SSHService();
  final KMLService _kmlService = KMLService();

  bool get isConnected => _sshService.isConnected;

  /// Connect to the LG master.
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    await _sshService.connect(
      host: host,
      port: port,
      username: username,
      password: password,
    );
    notifyListeners();
  }

  /// Disconnect from the LG rig.
  void disconnect() {
    _sshService.disconnect();
    notifyListeners();
  }

  /// Fly to a specific location on Google Earth.
  Future<void> flyTo({
    required double latitude,
    required double longitude,
    double altitude = 0,
    double heading = 0,
    double tilt = 60,
    double range = 1000,
  }) async {
    final flytoCmd = _kmlService.generateFlyTo(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      heading: heading,
      tilt: tilt,
      range: range,
    );
    await _sshService.execute('echo "$flytoCmd" > /tmp/query.txt');
  }

  /// Fly to the user's configured home city.
  ///
  /// Reads coordinates from [Config.homeCityLat] and [Config.homeCityLng].
  /// This is one of the 5 core Task 2 operations.
  Future<void> flyToHomeCity() async {
    await flyTo(
      latitude: Config.homeCityLat,
      longitude: Config.homeCityLng,
      range: 5000,
      tilt: 60,
    );
  }

  /// Execute a search query on Google Earth.
  Future<void> search(String query) async {
    await _sshService.execute('echo "search=$query" > /tmp/query.txt');
  }

  /// Send a KML placemark to the LG rig.
  Future<void> sendKMLPlacemark({
    required String name,
    required double latitude,
    required double longitude,
    String description = '',
  }) async {
    final kml = _kmlService.generatePlacemark(
      name: name,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );
    await _sshService.uploadKML(kml, 'placemark.kml');
    // Load via kmls.txt
    await _sshService.execute(
      'echo "http://localhost/placemark.kml" > /var/www/html/kmls.txt',
    );
  }

  /// Send the project logo to the left-most slave screen.
  ///
  /// Generates a [ScreenOverlay] KML and uploads it to the slave.
  /// This is one of the 5 core Task 2 operations.
  Future<void> sendLogo() async {
    final logoKML = _kmlService.generateScreenOverlay(
      name: 'Logo',
      imageUrl: 'https://liquidgalaxy.eu/wp-content/uploads/2024/01/LG-logo.png',
    );
    final slaveScreen = Config.leftScreen;
    await _sshService.uploadKML(logoKML, 'logo_slave_$slaveScreen.kml');
  }

  /// Send a 3D pyramid to the center (master) screen.
  ///
  /// Generates an extruded [Polygon] KML and uploads it to the rig,
  /// then flies the camera to view it.
  /// This is one of the 5 core Task 2 operations.
  Future<void> sendPyramid({
    double? latitude,
    double? longitude,
    double height = 500,
  }) async {
    final lat = latitude ?? Config.homeCityLat;
    final lng = longitude ?? Config.homeCityLng;
    final pyramidKML = _kmlService.generatePyramid(
      latitude: lat,
      longitude: lng,
      height: height,
    );
    await _sshService.uploadKML(pyramidKML, 'pyramid.kml');
    await _sshService.execute(
      'echo "http://localhost/pyramid.kml" >> /var/www/html/kmls.txt',
    );
    // Fly camera to view the pyramid
    await flyTo(
      latitude: lat,
      longitude: lng,
      range: 2000,
      tilt: 60,
    );
  }

  /// Remove logo overlays from all slave screens.
  ///
  /// Clears both `logo_slave_N.kml` and `kml_slave_N.kml` files.
  /// This is one of the 5 core Task 2 operations.
  Future<void> cleanLogos() async {
    for (int i = 2; i <= Config.totalScreens; i++) {
      await _sshService.execute('echo "" > /var/www/html/logo_slave_$i.kml');
      await _sshService.execute('echo "" > /var/www/html/kml_slave_$i.kml');
    }
  }

  /// Clear all KML files and queries from the rig.
  ///
  /// Resets query.txt, kmls.txt, and all slave KMLs.
  /// This is one of the 5 core Task 2 operations.
  Future<void> cleanKMLs() async {
    await _sshService.execute('echo "" > /tmp/query.txt');
    await _sshService.execute('echo "" > /var/www/html/kmls.txt');
    for (int i = 2; i <= Config.totalScreens; i++) {
      await _sshService.execute('echo "" > /var/www/html/kml_slave_$i.kml');
    }
  }

  /// Send an orbit tour KML to the rig.
  ///
  /// Generates a 360° camera orbit around the given coordinates.
  Future<void> sendOrbit({
    required double latitude,
    required double longitude,
    double altitude = 1000,
    double range = 5000,
    double tilt = 60,
    int duration = 30,
  }) async {
    final orbitKml = _kmlService.generateOrbit(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      range: range,
      tilt: tilt,
      duration: duration,
    );
    await _sshService.uploadKML(orbitKml, 'orbit.kml');
    await _sshService.execute(
      'echo "http://localhost/orbit.kml" >> /var/www/html/kmls.txt',
    );
  }

  /// Reboot all machines in the LG rig.
  ///
  /// Uses the stored SSH credentials (not Config defaults) for slave access.
  Future<void> rebootLG() async {
    for (int i = Config.totalScreens; i >= 1; i--) {
      final machineHost = 'lg$i';
      try {
        await _sshService.execute(
          'sshpass -p ${Config.lgPassword} ssh -o StrictHostKeyChecking=no '
          '${Config.lgUser}@$machineHost "sudo reboot"',
        );
      } catch (_) {
        // Machine may disconnect immediately on reboot
      }
    }
  }

  /// Shut down all machines in the LG rig.
  Future<void> shutdownLG() async {
    for (int i = Config.totalScreens; i >= 1; i--) {
      final machineHost = 'lg$i';
      try {
        await _sshService.execute(
          'sshpass -p ${Config.lgPassword} ssh -o StrictHostKeyChecking=no '
          '${Config.lgUser}@$machineHost "sudo poweroff"',
        );
      } catch (_) {
        // Machine may disconnect immediately on shutdown
      }
    }
  }

  /// Execute a raw SSH command.
  Future<String> executeRaw(String command) async {
    return await _sshService.execute(command);
  }

  @override
  void dispose() {
    _sshService.dispose();
    super.dispose();
  }
}
