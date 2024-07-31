import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.100.147:3000';

  static Future<String> getTimeframes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load timeframes');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to load timeframes');
    }
  }
}
