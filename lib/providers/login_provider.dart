import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final storage = const FlutterSecureStorage();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  /// Performs the login process.
  /// Returns true if login and data fetch were successful, false otherwise.
  Future<bool> login(
      String email, String password, BuildContext context) async {
    if (_isLoading) return false;

    _setLoading(true);
    _setError('');

    final client = http.Client();
    try {
      final url = Uri.parse('http://10.0.2.2:9090/login');

      var request = http.MultipartRequest('POST', url);

      request.fields['email'] = email;
      request.fields['password'] = password;

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['access_token'];
        await storage.write(key: 'jwt', value: token);

        // Fetch veterinarian data using the token
        final veterinarian = await VeterinarianProvider.fromId(token);

        if (veterinarian != null) {
          if (context.mounted) {
            Provider.of<VeterinarianProvider>(context, listen: false)
                .setVeterinarian(veterinarian);
          }
          // Success
          return true;
        } else {
          // Handle case where token is received but vet data fetch fails
          _setError('Login successful, but failed to load user data.');
          await storage.delete(key: 'jwt'); // Clear token if data fetch fails
          return false;
        }
      } else {
        // Login failed based on status code
        _setError(
            data['msg'] ?? 'Login failed. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      debugPrint('Login error: $e'); // Use debugPrint for errors
      _setError('An error occurred: ${e.toString()}');
      return false;
    } finally {
      client.close();
      _setLoading(false);
    }
  }

  // Optional: Add a method to check initial login status using stored token
  // This could be in VeterinarianProvider as well, depending on app flow.
}
