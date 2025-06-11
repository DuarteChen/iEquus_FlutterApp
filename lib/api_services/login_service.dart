import 'dart:convert';
import 'package:equus/config/api_constants.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final http.Client _client;

  // Allow injecting an http.Client for easier testing
  LoginService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$apiBaseUrl/login');
    // Note: The original login used MultipartRequest.
    // If your backend /login endpoint expects 'application/x-www-form-urlencoded'
    // or JSON, adjust accordingly. Multipart is unusual for a simple login.
    // Assuming MultipartRequest is indeed required by your backend:
    var request = http.MultipartRequest('POST', url);
    request.fields['email'] = email;
    request.fields['password'] = password;

    // If your backend expects JSON:
    // final headers = await HttpClient().getHeaders(); // isMultipart defaults to false
    // final body = jsonEncode({'email': email, 'password': password});
    // final response = await _client.post(url, headers: headers, body: body);

    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['access_token'] == null) {
          throw Exception('Login successful, but no access token received.');
        }
        return data; // Contains 'access_token' and potentially other user info
      } else {
        throw Exception(
            data['msg'] ?? 'Login failed. Status code: ${response.statusCode}');
      }
    } finally {
      // If _client was provided externally, the caller should manage its lifecycle.
      // If _client is created internally, uncomment to close it.
      // _client.close(); // Only close if LoginService owns the client instance.
    }
  }
}
