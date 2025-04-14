import 'package:equus/models/veterinarian.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import storage
import 'package:jwt_decoder/jwt_decoder.dart'; // Import decoder

class VeterinarianProvider with ChangeNotifier {
  Veterinarian? _veterinarian;
  bool _isLoading = false; // Optional: Add loading state
  String? _error; // Optional: Add error state

  Veterinarian? get veterinarian => _veterinarian;
  bool get isLoading => _isLoading; // Getter for loading state
  String? get error => _error; // Getter for error state

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool get hasVeterinarian => _veterinarian != null;

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setVeterinarian(Veterinarian veterinarian) {
    _veterinarian = veterinarian;
    _error = null; // Clear error on success
    _isLoading = false; // Ensure loading is false
    notifyListeners();
  }

  void clearVeterinarian() {
    _veterinarian = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVeterinarianData() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null); // Clear previous errors

    const storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      // Check if token is expired before decoding (optional but good practice)
      if (JwtDecoder.isExpired(token)) {
        await storage.delete(key: 'jwt'); // Clear expired token
        throw Exception('Authentication token expired. Please login again.');
      }

      // Decode the token to get the veterinarian ID
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      // --- IMPORTANT: Adjust 'sub' if your JWT uses a different claim key for the user ID ---
      final idClaim = decodedToken['sub'];
      int? vetId;

      if (idClaim is int) {
        vetId = idClaim;
      } else if (idClaim is String) {
        vetId = int.tryParse(idClaim);
      }

      if (vetId == null) {
        throw Exception(
            "Could not extract veterinarian ID ('sub') from token.");
      }

      // Fetch veterinarian data using the static method from the model
      // This method already includes the Authorization header logic
      final fetchedVeterinarian = await Veterinarian.fromId(token);

      if (fetchedVeterinarian != null) {
        // Use the existing setVeterinarian method which handles notifyListeners
        setVeterinarian(fetchedVeterinarian);
      } else {
        // Handle case where API call succeeded but returned null/empty data
        throw Exception('Failed to retrieve veterinarian details from server.');
      }
    } catch (e) {
      debugPrint("Error loading veterinarian data: $e");
      _setError(e.toString()); // Store error message
      // Optionally clear veterinarian data on error
      _veterinarian = null;
    } finally {
      _setLoading(false); // Ensure loading is set to false
    }
  }
}
