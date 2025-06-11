import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiBaseUrl = 'http://10.0.2.2:9090';

class HttpClient {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> getHeaders({bool isMultipart = false}) async {
    final token = await _storage.read(key: 'jwt');
    final headers = <String, String>{};

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
