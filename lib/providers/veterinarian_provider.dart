import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:equus/models/veterinarian.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  static Future<Veterinarian?> fromId(String token) async {
    final url = Uri.parse('https://iequus.craveirochen.pt/veterinarian');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Veterinarian.fromMap(data);
      } else {
        print('Failed to load veterinarian: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching veterinarian: $e');
      return null;
    }
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

      final fetchedVeterinarian = await VeterinarianProvider.fromId(token);
      if (fetchedVeterinarian != null) {
        setVeterinarian(fetchedVeterinarian);
      } else {
        throw Exception("Veterinarian data could not be retrieved.");
      }
    } catch (e) {
      debugPrint("Error loading veterinarian data: $e");
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
