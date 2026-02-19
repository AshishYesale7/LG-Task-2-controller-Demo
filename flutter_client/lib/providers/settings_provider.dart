import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lg_task2_demo/config.dart' as AppConfig;

/// Manages LG connection settings with persistence.
///
/// Non-sensitive settings (host, port, screen count) use [SharedPreferences].
/// Sensitive credentials (username, password) use [FlutterSecureStorage].
class SettingsProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _host = AppConfig.Config.defaultHost;
  int _port = AppConfig.Config.defaultPort;
  String _username = AppConfig.Config.defaultUsername;
  String _password = AppConfig.Config.defaultPassword;
  int _totalScreens = AppConfig.Config.defaultTotalScreens;
  String _weatherApiKey = AppConfig.Config.defaultWeatherApiKey;

  String get host => _host;
  int get port => _port;
  String get username => _username;
  String get password => _password;
  int get totalScreens => _totalScreens;
  String get weatherApiKey => _weatherApiKey;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('lg_host') ?? AppConfig.Config.defaultHost;
    _port = prefs.getInt('lg_port') ?? AppConfig.Config.defaultPort;
    _totalScreens = prefs.getInt('lg_screens') ?? AppConfig.Config.defaultTotalScreens;

    // Load sensitive credentials from secure storage
    _username = await _secureStorage.read(key: 'lg_user') ?? AppConfig.Config.defaultUsername;
    _password = await _secureStorage.read(key: 'lg_password') ?? AppConfig.Config.defaultPassword;
    _weatherApiKey = await _secureStorage.read(key: 'weather_api_key') ?? AppConfig.Config.defaultWeatherApiKey;

    notifyListeners();
  }

  Future<void> updateSettings({
    String? host,
    int? port,
    String? username,
    String? password,
    int? totalScreens,
    String? weatherApiKey,
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
    if (weatherApiKey != null) {
      _weatherApiKey = weatherApiKey;
      await _secureStorage.write(key: 'weather_api_key', value: weatherApiKey);
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
    await _secureStorage.delete(key: 'weather_api_key');

    _host = AppConfig.Config.defaultHost;
    _port = AppConfig.Config.defaultPort;
    _username = AppConfig.Config.defaultUsername;
    _password = AppConfig.Config.defaultPassword;
    _totalScreens = AppConfig.Config.defaultTotalScreens;
    _weatherApiKey = AppConfig.Config.defaultWeatherApiKey;

    notifyListeners();
  }
}
