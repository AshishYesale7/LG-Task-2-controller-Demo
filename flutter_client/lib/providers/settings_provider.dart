import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_client/config.dart';

/// Manages LG connection settings with persistence.
///
/// Non-sensitive settings (host, port, screen count) use [SharedPreferences].
/// Sensitive credentials (username, password) use [FlutterSecureStorage].
class SettingsProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _host = Config.lgHost;
  int _port = Config.lgPort;
  String _username = Config.lgUser;
  String _password = Config.lgPassword;
  int _totalScreens = Config.totalScreens;

  String get host => _host;
  int get port => _port;
  String get username => _username;
  String get password => _password;
  int get totalScreens => _totalScreens;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('lg_host') ?? Config.lgHost;
    _port = prefs.getInt('lg_port') ?? Config.lgPort;
    _totalScreens = prefs.getInt('lg_screens') ?? Config.totalScreens;

    // Load sensitive credentials from secure storage
    _username = await _secureStorage.read(key: 'lg_user') ?? Config.lgUser;
    _password = await _secureStorage.read(key: 'lg_password') ?? Config.lgPassword;

    notifyListeners();
  }

  Future<void> updateSettings({
    String? host,
    int? port,
    String? username,
    String? password,
    int? totalScreens,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (host != null) {
      _host = host;
      await prefs.setString('lg_host', host);
    }
    if (port != null) {
      _port = port;
      await prefs.setInt('lg_port', port);
    }
    if (totalScreens != null) {
      _totalScreens = totalScreens;
      await prefs.setInt('lg_screens', totalScreens);
    }

    // Store sensitive credentials in secure storage (encrypted)
    if (username != null) {
      _username = username;
      await _secureStorage.write(key: 'lg_user', value: username);
    }
    if (password != null) {
      _password = password;
      await _secureStorage.write(key: 'lg_password', value: password);
    }

    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lg_host');
    await prefs.remove('lg_port');
    await prefs.remove('lg_screens');

    // Clear secure storage
    await _secureStorage.delete(key: 'lg_user');
    await _secureStorage.delete(key: 'lg_password');

    _host = Config.lgHost;
    _port = Config.lgPort;
    _username = Config.lgUser;
    _password = Config.lgPassword;
    _totalScreens = Config.totalScreens;

    notifyListeners();
  }
}
