import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IpClient {
  String apiUrl = dotenv.env['API_CHECK_IP'] ?? 'https://default-api.com/ip';
  final Dio _dio;

  IpClient({String? apiUrl, Dio? dio})
      : apiUrl = apiUrl ??
            dotenv.env['API_CHECK_IP'] ??
            'https://default-api.com/ip',
        _dio = dio ?? Dio();

  Future<String> getIp() async {
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        return response.data['ip'];
      } else {
        throw Exception('Failed to load IP: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching IP: $e');
    }
  }
}
