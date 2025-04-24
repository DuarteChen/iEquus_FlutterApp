import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:equus/models/veterinarian.dart';
import 'package:equus/providers/hospital_provider.dart';

class VeterinarianProvider with ChangeNotifier {
  Veterinarian? _veterinarian;
  bool _isLoading = false;
  String? _error;

  Veterinarian? get veterinarian => _veterinarian;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasVeterinarian => _veterinarian != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void setVeterinarian(
      Veterinarian veterinarian, HospitalProvider hospitalProvider) {
    _veterinarian = veterinarian;
    _setError(null);
    _setLoading(false);
    hospitalProvider
        .setHospital(veterinarian.hospital); // Set hospital at same time
    notifyListeners();
  }

  void clear(HospitalProvider hospitalProvider) {
    _veterinarian = null;
    hospitalProvider.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVeterinarianData(HospitalProvider hospitalProvider) async {
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

      final fetchedVeterinarian = await Veterinarian.fromId(token);
      if (fetchedVeterinarian != null) {
        setVeterinarian(fetchedVeterinarian, hospitalProvider);
      } else {
        throw Exception("Veterinarian data could not be retrieved.");
      }
    } catch (e) {
      debugPrint("Error loading veterinarian data: $e");
      _setError(e.toString());
      clear(hospitalProvider);
    } finally {
      _setLoading(false);
    }
  }
}
