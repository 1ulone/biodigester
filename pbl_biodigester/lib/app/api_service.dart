// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
    final String _baseUrl = "http://127.0.0.1:8000";

    Future<Map<String, dynamic>> fetchRawSensorData() async {
        final response = await http.get(Uri.parse('$_baseUrl/status'));
        if (response.statusCode == 200) {
            return json.decode(response.body);
        }
        throw Exception("Status Error");
    }

    Future<double> fetchFuelStatus() async {
        final response = await http.get(Uri.parse('$_baseUrl/status'));
        if (response.statusCode == 200) {
            final data = json.decode(response.body);
            return (data['fuel_left'] as num?)?.toDouble() ?? 0.0;
        }
        throw Exception("Status Error");
    }

    Future<Map<String, dynamic>> fetchAiAnalysis() async {
        final response = await http.post(Uri.parse('$_baseUrl/analyze'));
        if (response.statusCode == 200) {
            return json.decode(response.body);
        }
        throw Exception("AI Error");
    }

}
