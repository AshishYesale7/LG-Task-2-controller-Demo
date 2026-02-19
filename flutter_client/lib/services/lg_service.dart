import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:lg_task2_demo/config.dart';
import 'package:lg_task2_demo/services/kml_service.dart';
import 'package:lg_task2_demo/services/ssh_service.dart';
import 'package:lg_task2_demo/services/weather_service.dart';

class LGService extends ChangeNotifier {
  final SSHService _sshService = SSHService();
  final KMLService _kmlService = KMLService();
  final WeatherService _weatherService = WeatherService();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Error handling
  final _errorController = StreamController<String>.broadcast();
  Stream<String> get onError => _errorController.stream;

  LGService();

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }

  /// Connect to the LG rig.
  Future<bool> connect({
    String? host,
    int? port,
    String? username,
    String? password,
  }) async {
    try {
      _isConnected = await _sshService.connect(
        host ?? Config.defaultHost,
        port ?? Config.defaultPort,
        username ?? Config.defaultUsername,
        password ?? Config.defaultPassword,
      );
      print('LGService: Connected (Optimistic) to $host');
    } catch (e) {
      print('Connection Error: $e');
      _errorController.add('Connection failed: $e');
      _isConnected = false;
      rethrow;
    }
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
    
    try {
      // Inline LookAt construction (Reference Logic)
      // Lleida coordinates (from Reference)
      final double latitude = 41.6176;
      final double longitude = 0.6200;
      final double altitude = 1000;
      final double heading = 0;
      final double tilt = 60;
      final double range = 1000;

      final flytoCmd =
          'echo "flytoview=<LookAt>'
          '<longitude>$longitude</longitude>'
          '<latitude>$latitude</latitude>'
          '<altitude>$altitude</altitude>'
          '<heading>$heading</heading>'
          '<tilt>$tilt</tilt>'
          '<range>$range</range>'
          '<altitudeMode>relativeToGround</altitudeMode>'
          '</LookAt>" > /tmp/query.txt';

      await _sshService.execute(flytoCmd);
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to fly home: $e');
      rethrow;
    }
  }

  Future<void> sendLogo() async {
    if (!_isConnected) return;

    try {
      // Load Local Asset
      final byteData = await rootBundle.load('assets/images/LIQUIDGALAXYLOGO.png');
      final bytes = byteData.buffer.asUint8List();
      
      // Upload image to Master
      await _sshService.uploadBytes(bytes, 'LIQUIDGALAXYLOGO.png');
      await _sshService.execute('chmod 644 /var/www/html/LIQUIDGALAXYLOGO.png');

      // Use Master IP Address for reliable internal networking
      final masterIP = _sshService.host;
      final imageUrl = 'http://$masterIP:81/LIQUIDGALAXYLOGO.png';

      final kmlContent = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
    <name>Logo</name>
    <ScreenOverlay>
        <name>Logo</name>
        <Icon>
          <href>$imageUrl</href>
        </Icon>
        <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
        <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
        <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
        <size x="300" y="300" xunits="pixels" yunits="pixels"/>
    </ScreenOverlay>
</Document>
</kml>
''';
      
      await _sshService.uploadKML(kmlContent, 'kml/slave_3.kml');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to send logo: $e');
      rethrow;
    }
  }

  Future<void> cleanLogos() async {
    if (!_isConnected) return;
    
    try {
      // Send a VALID but EMPTY KML to force Google Earth to clear the overlay
      // An empty file (echo "") is often ignored by GE as invalid XML.
      final String blankKml = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
  <Document>
    <name>Logo</name>
  </Document>
</kml>
''';
      await _sshService.uploadKML(blankKml, 'kml/slave_2.kml');
      await _sshService.uploadKML(blankKml, 'kml/slave_3.kml');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to clean logos: $e');
      rethrow;
    }
  }

  Future<void> cleanKMLs() async {
    if (!_isConnected) return;
    
    try {
      await _sshService.execute('echo "" > /tmp/query.txt'); 
      await _sshService.execute('echo "" > /var/www/html/kmls.txt');
      // Clean slaves
      await _sshService.execute('echo "" > /var/www/html/kml/slave_2.kml');
      await _sshService.execute('echo "" > /var/www/html/kml/slave_3.kml');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to clean KMLs: $e');
      rethrow;
    }
  }

  Future<void> cleanKMLAndLogos() async {
    if (!_isConnected) return;
    try {
      await cleanKMLs();
      await cleanLogos();
    } catch (e) {
      print('LG Service Error: $e');
      rethrow;
    }
  }

  Future<void> sendPyramid() async {
     if (!_isConnected) return;

    try {
      // 5000 meters = 5km wide/tall pyramid
      final kml = _kmlService.generatePyramid(41.6176, 0.6200, 0, 5000);
      
      await _sshService.uploadKML(kml, 'pyramid.kml');
      await _sshService.execute('echo "http://localhost:81/pyramid.kml" > /var/www/html/kmls.txt');
      
      // FlyTo view from 10km away to see the giant pyramid
       final lookAt = _kmlService.generateLookAt(41.6176, 0.6200, 10000, 45, 0);
       await _sshService.execute('echo "flytoview=$lookAt" > /tmp/query.txt');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to send pyramid: $e');
      rethrow;
    }
  }

  Future<void> sendWeather(String city, String apiKey) async {
    if (!_isConnected) return;

    try {
      final weatherData = await _weatherService.fetchWeather(apiKey, city);
      final temp = (weatherData['main']['temp'] as num).toDouble();
      final description = weatherData['weather'][0]['description'] as String;
      final lat = (weatherData['coord']['lat'] as num).toDouble();
      final lon = (weatherData['coord']['lon'] as num).toDouble();
      
      final kml = _kmlService.generateWeatherPlacemark(lat, lon, city, temp, description);
      
      await _sshService.uploadKML(kml, 'weather.kml');
      await _sshService.execute('echo "http://localhost:81/weather.kml" > /var/www/html/kmls.txt');
      
      final lookAt = _kmlService.generateLookAt(lat, lon, 5000, 45, 0);
      await _sshService.execute('echo "flytoview=$lookAt" > /tmp/query.txt');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to send weather: $e');
      rethrow;
    }
  }

  Future<void> rebootLG() async {
    if (!_isConnected) return;

    try {
      final password = Config.defaultPassword;
      // Loop through screens, assuming lgN nomenclature.
      // Reboot slaves first (lg3, lg2...) then Master (lg1)
      for (int i = Config.defaultTotalScreens; i >= 1; i--) {
        try {
          final host = 'lg$i';
          final command = 'echo $password | sudo -S reboot';
          
          if (i == 1) {
             // Master: Execute directly
             // Note: This will disconnect the session immediately
             await _sshService.execute(command);
          } else {
             // Slaves: SSH from Master to Slave
             await _sshService.execute('sshpass -p $password ssh -t $host "$command"');
          }
        } catch (e) {
          print('Error rebooting lg$i: $e');
          // Continue to next machine even if one fails
        }
      }
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to reboot LG: $e');
      rethrow;
    }
  }

  Future<void> sendKMLPlacemark({
    required String name,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    if (!_isConnected) return;
    
    try {
      final kml = _kmlService.generatePlacemark(latitude, longitude, name, description);
      
      await _sshService.uploadKML(kml, 'placemark.kml');
      await _sshService.execute('echo "http://localhost:81/placemark.kml" > /var/www/html/kmls.txt');
      
      final lookAt = _kmlService.generateLookAt(latitude, longitude, 1000, 45, 0);
      await _sshService.execute('echo "flytoview=$lookAt" > /tmp/query.txt');
    } catch (e) {
      print('LG Service Error: $e');
      _errorController.add('Failed to send placemark: $e');
      rethrow;
    }
  }
}
