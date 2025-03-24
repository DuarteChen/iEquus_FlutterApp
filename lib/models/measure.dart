import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Measure {
  int id;
  String picturePath;
  final List<Offset> coordinates;
  final DateTime date;
  final int horseId;

  int? algorithmBW;
  int? algorithmBCS;

  int? userBW;
  int? userBCS;
  bool? favorite;
  int? veterinarianId;
  int? appointmentId;

  Measure({
    required this.id,
    this.userBW,
    this.algorithmBW,
    this.userBCS,
    this.algorithmBCS,
    required this.date,
    required this.coordinates,
    required this.picturePath,
    this.favorite,
    required this.horseId,
    this.veterinarianId,
    this.appointmentId,
  });

  factory Measure.fromJson(Map<String, dynamic> json) {
    return Measure(
      id: json['idMeasure'],
      userBW: json['userBW'],
      algorithmBW: json['algorithmBW'],
      userBCS: json['userBCS'],
      algorithmBCS: json['algorithmBCS'],
      date: DateTime.parse(json['date']),
      coordinates: json['coordinates'],
      picturePath: json['picturePath'],
      favorite: json['favorite'],
      horseId: json['horseId'],
      veterinarianId: json['veterinarianId'],
      appointmentId: json['appointmentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeasure': id,
      'userBW': userBW,
      'algorithmBW': algorithmBW,
      'userBCS': userBCS,
      'algorithmBCS': algorithmBCS,
      'date': date.toIso8601String(),
      'coordinates': coordinates,
      'picturePath': picturePath,
      'favorite': favorite,
      'horseId': horseId,
      'veterinarianId': veterinarianId,
      'appointmentId': appointmentId,
    };
  }

  String convertOffsetsToJson(List<Offset> coordinates) {
    final List<Map<String, double>> mappedCoordinates =
        coordinates.map((offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();

    return jsonEncode(mappedCoordinates);
  }

  List<Offset> convertJsonToOffsets(String jsonString) {
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((point) {
      return Offset(point['x'], point['y']);
    }).toList();
  }

  Future<bool> uploadToServer() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:9090/measures'),
    );
    request.fields['date'] = date.toString();
    request.fields['coordinates'] = convertOffsetsToJson(coordinates);
    request.fields['horseId'] = horseId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('picturePath', picturePath),
    );

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      id = (jsonResponse['measureID'] as int?) ?? 0;
      picturePath = jsonResponse['picturePath'];
      algorithmBCS = (jsonResponse['algorithmBCS'] as int?) ?? 0;
      algorithmBW = (jsonResponse['algorithmBW'] as int?) ?? 0;
      return true;
    }
    return false;
  }

  Future<bool> editBW(int number) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://10.0.2.2:9090/measures/$id'),
    );
    request.fields['userBW'] = number.toString();

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      userBW = (jsonResponse['userBW'] as int?) ?? 0;

      return true;
    }
    return false;
  }

  Future<bool> editBCS(int number) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://10.0.2.2:9090/measures/$id'),
    );
    request.fields['userBCS'] = number.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);

      userBW = (jsonResponse['userBCS'] as int?) ?? 0;

      return true;
    }
    return false;
  }
}
