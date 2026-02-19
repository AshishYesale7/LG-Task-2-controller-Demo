import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static const String appName = 'LG Controller';
  static const int defaultTotalScreens = 3;
  static int get defaultPort => int.tryParse(dotenv.env['LG_PORT'] ?? '') ?? 22;
  static String get defaultUsername => dotenv.env['LG_USER'] ?? 'lg';
  static String get defaultPassword => dotenv.env['LG_PASSWORD'] ?? 'lg'; // Default LG password
  static String get defaultHost => dotenv.env['LG_HOST'] ?? '10.252.42.35'; // Default IP
  static String get defaultWeatherApiKey => dotenv.env['WEATHER_KEY'] ?? '52ac155e6c55a0cdd61bd08721f43267';
}
