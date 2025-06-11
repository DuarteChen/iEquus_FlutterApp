import 'package:equus/api_services/hospital_service.dart';
import 'package:equus/api_services/veterinarian_service.dart'; // Import VeterinarianService
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:equus/models/hospital.dart';
import 'package:equus/models/veterinarian.dart';
import 'dart:developer' as developer; // For logging

class VeterinarianProvider with ChangeNotifier {
  Veterinarian? _veterinarian;
  bool _isLoading = false;
  String? _error;

  Veterinarian? get veterinarian => _veterinarian;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasVeterinarian => _veterinarian != null;
  final VeterinarianService _veterinarianService = VeterinarianService();
  final HospitalService _hospitalService = HospitalService();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void setVeterinarian(Veterinarian veterinarian) {
    _veterinarian = veterinarian;
    _setError(null);
    _setLoading(false);
    if (veterinarian.hospital != null) {
      //TODO
    }
    notifyListeners();
  }

  void clear() {
    _veterinarian = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVeterinarianData() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    const storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) throw Exception("Authentication token not found.");

      if (JwtDecoder.isExpired(token)) {
        await storage.delete(key: 'jwt');
        throw Exception("Authentication token expired.");
      }

      final fetchedVeterinarian =
          await _veterinarianService.fetchCurrentVeterinarian();
      if (fetchedVeterinarian != null) {
        setVeterinarian(fetchedVeterinarian);
      } else {
        throw Exception("Veterinarian data could not be retrieved.");
      }
    } catch (e) {
      developer.log("Error loading veterinarian data in provider: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Hospital>> fetchHospitals() async {
    // No loading/error state management here as it's directly used by the screen
    // If global state for hospitals was needed, you'd add it.
    try {
      return await _hospitalService.fetchHospitals();
    } catch (e) {
      developer.log("Error in VeterinarianProvider.fetchHospitals: $e");
      rethrow; // Rethrow to be caught by the UI
    }
  }

  Future<void> registerVeterinarian({
    required String name,
    required String email,
    required String password,
    String? idCedulaProfissional,
    String? phoneNumber,
    String? phoneCountryCode,
    int? hospitalId,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _veterinarianService.registerVeterinarian(
        name: name,
        email: email,
        password: password,
        idCedulaProfissional: idCedulaProfissional,
        phoneNumber: phoneNumber,
        phoneCountryCode: phoneCountryCode,
        hospitalId: hospitalId,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow; // Rethrow to allow UI to handle specific error messages if needed
    } finally {
      _setLoading(false);
    }
  }
}
