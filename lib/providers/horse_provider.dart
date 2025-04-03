import 'dart:io';

import 'package:equus/models/client.dart';
import 'package:flutter/material.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/services/horse_service.dart';
import 'package:http/http.dart' as http;

class HorseProvider extends ChangeNotifier {
  final HorseService _horseService = HorseService();
  List<Horse> _horses = [];
  List<Horse> _filteredHorses = [];
  String _searchQuery = '';

  List<Horse> get horses => _filteredHorses;

  HorseProvider() {
    loadHorses();
  }

  List<Client> _horseClients = [];
  List<Client> _horseOwners = [];
  Horse? _currentHorse;
  ImageProvider<Object>? _profileImageProvider;

  List<Client> get horseClients => _horseClients;
  List<Client> get horseOwners => _horseOwners;
  Horse? get currentHorse => _currentHorse;
  ImageProvider<Object>? get profileImageProvider => _profileImageProvider;

  Future<void> loadHorseData(int horseId) async {
    try {
      _currentHorse = await _horseService.fetchHorse(horseId);
      _profileImageProvider = _currentHorse?.profilePicturePath != null
          ? NetworkImage(_currentHorse!.profilePicturePath!)
          : null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading horse data: $e');
    }
  }

  Future<void> loadHorseClients(int horseId) async {
    try {
      final clients = await _horseService.fetchHorseClients(horseId);
      _horseOwners = clients.where((client) => client.isOwner).toList();
      _horseClients = clients.where((client) => !client.isOwner).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading horse clients: $e');
    }
  }

  Future<void> updateHorsePhoto(int horseId, File imageFile) async {
    try {
      final newProfileUrl =
          await _horseService.uploadHorsePhoto(horseId, imageFile);
      _profileImageProvider = NetworkImage(newProfileUrl);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating horse photo: $e');
    }
  }

  Future<void> loadHorses() async {
    try {
      _horses = await _horseService.fetchHorses();
      _filteredHorses = _horses;
      notifyListeners();
    } catch (error) {
      print("Error fetching horses: $error");
    }
  }

  void filterHorses(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredHorses = _horses;
    } else {
      _filteredHorses = _horses
          .where(
              (horse) => horse.name.toLowerCase().contains(query.toLowerCase()))
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
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:9090/horses'),
    );

    request.fields['name'] = name;
    if (birthDate != null) {
      request.fields['birthDate'] =
          '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';
    }

    // Attach images if they exist
    if (profilePicture != null) {
      request.files
          .add(await http.MultipartFile.fromPath('photo', profilePicture.path));
    }
    if (leftFront != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'pictureLeftFront', leftFront.path));
    }
    if (rightFront != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'pictureRightFront', rightFront.path));
    }
    if (leftHind != null) {
      request.files.add(
          await http.MultipartFile.fromPath('pictureLeftHind', leftHind.path));
    }
    if (rightHind != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'pictureRightHind', rightHind.path));
    }

    var response = await request.send();

    if (response.statusCode == 201) {
      _horses.add(Horse(idHorse: 0, name: name, birthDate: birthDate));
      notifyListeners();
    } else {
      throw Exception("Failed to add horse");
    }
  }
}
