import 'package:flutter/material.dart';
import 'package:equus/models/hospital.dart';

class HospitalProvider with ChangeNotifier {
  Hospital? _hospital;
  bool _isLoading = false;
  String? _error;

  Hospital? get hospital => _hospital;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get hasHospital => _hospital != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void setHospital(Hospital hospital) {
    _hospital = hospital;
    _setError(null);
    _setLoading(false);
  }

  void clear() {
    _hospital = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
