import 'dart:io';

import 'package:equus/models/client.dart';
import 'package:flutter/material.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/services/horse_service.dart';

class HorseProvider extends ChangeNotifier {
  final HorseService _horseService = HorseService();
  List<Horse> _horses = [];
  List<Horse> _filteredHorses = [];

  List<Horse> get horses => _filteredHorses;

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
    try {
      _currentHorse = await _horseService.fetchHorse(horseId);
      // Update image provider based on fetched data
      _updateProfileImageProvider(_currentHorse?.profilePicturePath);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading horse data in provider: $e');
      // Rethrow or handle error appropriately for the UI layer
      rethrow;
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
    try {
      final clients = await _horseService.fetchHorseClients(horseId);
      // Clear previous lists before adding new ones
      _horseOwners.clear();
      _horseClients.clear();
      // Separate clients based on the isOwner flag
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
      // Rethrow or handle error appropriately for the UI layer
      rethrow;
    }
  }

  Future<void> updateHorsePhoto(int horseId, File imageFile) async {
    try {
      // Service method handles JWT
      final newProfileUrl =
          await _horseService.uploadHorsePhoto(horseId, imageFile);

      // Update the current horse model if it's loaded
      if (_currentHorse?.idHorse == horseId) {
        // Create a new Horse instance with the updated path
        // Assuming Horse is immutable or has a copyWith method
        // If not, you might need to fetch the horse again or handle differently
        _currentHorse = Horse(
          idHorse: _currentHorse!.idHorse,
          name: _currentHorse!.name,
          birthDate: _currentHorse!.birthDate,
          profilePicturePath: newProfileUrl, // Update path
          pictureLeftFrontPath: _currentHorse!.pictureLeftFrontPath,
          pictureRightFrontPath: _currentHorse!.pictureRightFrontPath,
          pictureLeftHindPath: _currentHorse!.pictureLeftHindPath,
          pictureRightHindPath: _currentHorse!.pictureRightHindPath,
        );
      }

      // Update the image provider for the UI
      _updateProfileImageProvider(newProfileUrl);
      notifyListeners(); // Notify UI of changes
      await refreshHorses();
    } catch (e) {
      debugPrint('Error updating horse photo in provider: $e');
      // Rethrow or handle error appropriately for the UI layer
      rethrow;
    }
  }

  Future<void> loadHorses() async {
    try {
      // Service method handles JWT
      _horses = await _horseService.fetchHorses();
      _filteredHorses = List.from(_horses);
      notifyListeners();
    } catch (error) {
      debugPrint("Error loading horses in provider: $error");
      // Rethrow or handle error appropriately for the UI layer
      rethrow;
    }
  }

  // --- Local Operations ---

  void filterHorses(String query) {
    if (query.isEmpty) {
      _filteredHorses = List.from(_horses); // Reset to full list
    } else {
      final lowerCaseQuery = query.toLowerCase();
      _filteredHorses = _horses
          .where((horse) => horse.name.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }
    notifyListeners();
  }

  // --- Methods Delegating to Service ---

  Future<void> refreshHorses() async {
    // Simply call loadHorses again
    await loadHorses();
  }

  Future<void> addHorse(
      String name,
      DateTime? birthDate,
      File? profilePicture,
      File? leftFront,
      File? rightFront,
      File? leftHind,
      File? rightHind) async {
    try {
      // Delegate the API call entirely to the service
      // Service method handles JWT
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
        // If successful, refresh the list to get the new horse with its ID
        // Avoids adding a placeholder horse with incorrect ID
        await refreshHorses();
        // notifyListeners() is called within refreshHorses -> loadHorses
      } else {
        // The service returned false, indicating failure without an exception
        // This case might need refinement based on service's error handling
        throw Exception("Failed to add horse (service returned false)");
      }
    } catch (e) {
      debugPrint("Error adding horse in provider: $e");
      // Rethrow the exception so the UI layer can handle it (e.g., show error message)
      rethrow;
    }
  }

  // --- Helper Methods ---

  // Helper to update the image provider consistently
  void _updateProfileImageProvider(String? path) {
    if (path != null && path.isNotEmpty) {
      // Add a cache buster (timestamp) to force reload if URL is the same but content changed
      _profileImageProvider =
          NetworkImage("$path?t=${DateTime.now().millisecondsSinceEpoch}");
    } else {
      // Set to null or a default placeholder image provider
      _profileImageProvider =
          null; // Or AssetImage('assets/default_horse.png');
    }
  }
}
