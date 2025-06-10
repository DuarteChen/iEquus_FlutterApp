import 'dart:convert';
import 'package:equus/providers/horse_provider.dart';
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

  Future<bool> login(
      String email, String password, BuildContext context) async {
    if (_isLoading) return false;

    _setLoading(true);
    _setError('');

    final client = http.Client();
    try {
      final url = Uri.parse('https://iequus.craveirochen.pt/login');

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

  /// Performs the logout process.
  Future<void> logout(BuildContext context) async {
    _setLoading(true); // Indicate activity
    try {
      await storage.delete(key: 'jwt');
      // Clear VeterinarianProvider data
      // Ensure context is still valid if this method involves async operations before this line.
      if (context.mounted) {
        Provider.of<VeterinarianProvider>(context, listen: false).clear();
        Provider.of<HorseProvider>(context, listen: false).clear();
      }
      _setError(''); // Clear any previous errors
    } catch (e) {
      debugPrint('Logout error: $e');
      _setError('An error occurred during logout.'); // Optionally inform user
    } finally {
      _setLoading(false);
    }
  }
}
