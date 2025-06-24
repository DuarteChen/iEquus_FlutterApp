import 'dart:io';

import 'package:equus/models/client.dart';
import 'package:flutter/material.dart';
import 'package:equus/api_services/measure_service.dart'; // Import MeasureService
import 'package:equus/models/horse.dart';
import 'package:equus/api_services/horse_service.dart';
import 'package:equus/models/measure.dart'; // Import Measure model

class HorseProvider extends ChangeNotifier {
  final HorseService _horseService = HorseService();
  List<Horse> _horses = [];
  List<Horse> _filteredHorses = [];
  bool _isLoading = false;

  final MeasureService _measureService = MeasureService();

  List<Horse> get horses => _filteredHorses;
  bool get isLoading => _isLoading;
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  final List<Client> _horseClients = [];
  final List<Client> _horseOwners = [];
  Horse? _currentHorse;
  List<Measure> _horseMeasures = [];
  ImageProvider<Object>? _profileImageProvider;

  List<Client> get horseClients => _horseClients;
  List<Client> get horseOwners => _horseOwners;
  Horse? get currentHorse => _currentHorse;
  List<Measure> get horseMeasures => _horseMeasures;
  ImageProvider<Object>? get profileImageProvider => _profileImageProvider;

  // --- Methods using HorseService (JWT handled internally by service) ---

  Future<void> loadHorseData(int horseId) async {
    _setLoading(true);
    try {
      _currentHorse = await _horseService.fetchHorse(horseId);
      // Update image provider based on fetched data
      _updateProfileImageProvider(_currentHorse?.profilePicturePath);
    } catch (e) {
      debugPrint('Error loading horse data in provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  ImageProvider<Object>? profileImageProviderForHorse(Horse horse) {
    final path = horse.profilePicturePath;
    if (path != null && path.isNotEmpty) {
      return NetworkImage("$path?t=${DateTime.now().millisecondsSinceEpoch}");
    }
    return null;
  }

  Future<void> loadHorseMeasures(int horseId) async {
    _setLoading(true);
    try {
      _horseMeasures = await _measureService.fetchMeasuresForHorse(horseId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading horse measures in provider: $e');
      _horseMeasures = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHorseClients(int horseId) async {
    _setLoading(true);
    try {
      final clients = await _horseService.fetchHorseClients(horseId);

      _horseOwners.clear();
      _horseClients.clear();

      for (var client in clients) {
        if (client.isOwner) {
          _horseOwners.add(client);
        } else {
          _horseClients.add(client);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading horse clients in provider: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHorsePhoto(int horseId, File imageFile) async {
    // Consider if a specific loading state for photo upload is needed,
    // or if the general 'isLoading' for refreshHorses is sufficient.
    _setLoading(true); // Indicates general loading due to subsequent refresh
    try {
      final newProfileUrl =
          await _horseService.uploadHorseProfilePhoto(horseId, imageFile);

      if (_currentHorse?.idHorse == horseId) {
        _currentHorse = Horse(
          idHorse: _currentHorse!.idHorse,
          name: _currentHorse!.name,
          birthDate: _currentHorse!.birthDate,
          profilePicturePath: newProfileUrl,
          pictureLeftFrontPath: _currentHorse!.pictureLeftFrontPath,
          pictureRightFrontPath: _currentHorse!.pictureRightFrontPath,
          pictureLeftHindPath: _currentHorse!.pictureLeftHindPath,
          pictureRightHindPath: _currentHorse!.pictureRightHindPath,
        );
      }

      _updateProfileImageProvider(newProfileUrl);

      await loadHorses();
    } catch (e) {
      debugPrint('Error updating horse photo in provider: $e');
    } finally {
      _setLoading(
          false); // Ensure loading is false even if refreshHorses has its own
    }
  }

  Future<void> loadHorses() async {
    _setLoading(true);
    try {
      _horses = await _horseService.fetchHorses();
      _filteredHorses = List.from(_horses);
      notifyListeners();
    } catch (error) {
      debugPrint("Error loading horses in provider: $error");
      // Do not rethrow here, as it can crash the app if not handled by a FutureBuilder.
      // The UI will now show an empty list or a message, which is safer.
    } finally {
      _setLoading(false);
    }
  }

  // --- Local Operations ---

  void filterHorses(String query) {
    if (query.isEmpty) {
      _filteredHorses = List.from(_horses);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredHorses = _horses
          .where((horse) => horse.name.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }
    notifyListeners();
  }

  Future<void> addHorse(
      String name,
      DateTime? birthDate,
      File? profilePicture,
      File? leftFront,
      File? rightFront,
      File? leftHind,
      File? rightHind) async {
    _setLoading(true);
    try {
      final success = await _horseService.addHorse(
        name,
        birthDate,
        profilePicture,
        leftFront,
        rightFront,
        leftHind,
        rightHind,
      );

      if (success) {
        await loadHorses();
      } else {
        throw Exception("Failed to add horse (service returned false)");
      }
    } catch (e) {
      debugPrint("Error adding horse in provider: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHorse(int horseId) async {
    try {
      await _horseService.deleteHorse(horseId);
      // Remove the horse from the local lists for immediate UI update
      _horses.removeWhere((horse) => horse.idHorse == horseId);
      _filteredHorses.removeWhere((horse) => horse.idHorse == horseId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting horses in provider: $e");
    } finally {}
  }

  void clear() {
    _horses = [];
    _filteredHorses = [];
    _isLoading = false;
    notifyListeners();
  }

  // --- Helper Methods ---

  void _updateProfileImageProvider(String? path) {
    if (path != null && path.isNotEmpty) {
      _profileImageProvider =
          NetworkImage("$path?t=${DateTime.now().millisecondsSinceEpoch}");
    } else {
      _profileImageProvider = null;
    }
    notifyListeners();
  }
}
