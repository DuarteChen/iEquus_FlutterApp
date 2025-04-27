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
    }
  }

  Future<void> updateHorsePhoto(int horseId, File imageFile) async {
    try {
      final newProfileUrl =
          await _horseService.uploadHorsePhoto(horseId, imageFile);

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

      await refreshHorses();
    } catch (e) {
      debugPrint('Error updating horse photo in provider: $e');

      rethrow;
    }
  }

  Future<void> loadHorses() async {
    try {
      _horses = await _horseService.fetchHorses();
      _filteredHorses = List.from(_horses);
      notifyListeners();
    } catch (error) {
      debugPrint("Error loading horses in provider: $error");

      rethrow;
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

  Future<void> refreshHorses() async {
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
        await refreshHorses();
      } else {
        throw Exception("Failed to add horse (service returned false)");
      }
    } catch (e) {
      debugPrint("Error adding horse in provider: $e");

      rethrow;
    }
  }

  // --- Helper Methods ---

  void _updateProfileImageProvider(String? path) {
    if (path != null && path.isNotEmpty) {
      _profileImageProvider =
          NetworkImage("$path?t=${DateTime.now().millisecondsSinceEpoch}");
    } else {
      _profileImageProvider = null;
    }
  }
}
