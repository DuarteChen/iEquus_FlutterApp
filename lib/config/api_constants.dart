//const String apiBaseUrl = 'https://iequus.craveirochen.pt';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiBaseUrl = 'http://10.0.2.2:9090';

class HttpClient {
  final _storage = const FlutterSecureStorage();

  // Helper function to get headers with JWT token
  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await _storage.read(key: 'jwt');
    final headers = <String, String>{};

    // Set Content-Type for JSON requests unless it's multipart
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    // Add Authorization header if token exists
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
