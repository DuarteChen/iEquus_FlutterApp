import 'dart:convert';
import 'package:equus/config/api_constants.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final http.Client _client;

  LoginService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/login');

    var request = http.MultipartRequest('POST', url);
    request.fields['email'] = email;
    request.fields['password'] = password;

    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['access_token'] == null) {
          throw Exception('Login successful, but no access token received.');
        }
        return data;
      } else {
        throw Exception(
            data['msg'] ?? 'Login failed. Status code: ${response.statusCode}');
      }
    } finally {}
  }
}
