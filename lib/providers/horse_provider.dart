import 'dart:io';

import 'package:equus/models/client.dart';
import 'package:flutter/material.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/api_services/horse_service.dart';

class HorseProvider extends ChangeNotifier {
  final HorseService _horseService = HorseService();
  List<Horse> _horses = [];
  List<Horse> _filteredHorses = [];
  bool _isLoading = false;

  List<Horse> get horses => _filteredHorses;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  HorseProvider() {
    loadHorses();
  }

  final List<Client> _horseClients = [];
  final List<Client> _horseOwners = [];
  Horse? _currentHorse;
  ImageProvider<Object>? _profileImageProvider;

  List<Client> get horseClients => _horseClients;
  List<Client> get horseOwners => _horseOwners;
  Horse? get currentHorse => _currentHorse;
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
      rethrow;
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
      rethrow;
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
      rethrow;
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
      //TODO Login again
      rethrow;
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
      rethrow;
    } finally {
      _setLoading(false);
    }
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
    notifyListeners(); // Notify if the image provider changes
  }
}
