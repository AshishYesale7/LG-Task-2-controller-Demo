import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> fetchWeather(String apiKey, String city) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key is missing. Please set it in Settings.');
    }
    
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }
}
