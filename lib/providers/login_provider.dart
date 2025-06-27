import 'package:equus/api_services/login_service.dart'; // Import LoginService
import 'package:equus/api_services/veterinarian_service.dart'; // Ensure this is imported
import 'package:equus/providers/horse_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:equus/providers/veterinarian_provider.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService();
  final VeterinarianService _veterinarianService =
      VeterinarianService(); // Instantiate VeterinarianService

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

    try {
      // Call the LoginService
      final data = await _loginService.login(email, password);

      // Check if login was successful based on service's outcome (it throws on failure)
      if (data.containsKey('access_token')) {
        final token = data['access_token'];
        await storage.write(key: 'jwt', value: token);

        // Fetch veterinarian data using the instance method which relies on stored token
        final veterinarian =
            await _veterinarianService.fetchCurrentVeterinarian();

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
      }
      // Should not be reached if service throws, but as a fallback:
      _setError('Login failed: Unexpected response from server.');
      return false;
    } catch (e) {
      debugPrint('Login error: $e'); // Use debugPrint for errors
      _setError('An error occurred: ${e.toString()}');
      return false;
    } finally {
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
