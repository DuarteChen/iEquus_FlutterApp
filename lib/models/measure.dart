import 'dart:convert';

import 'package:flutter/material.dart';

class Measure {
  int id;
  final String? picturePath;
  final List<Offset> coordinates;
  final DateTime date;
  int? userBW;
  int? algorithmBW;
  int? userBCS;
  int? algorithmBCS;
  bool? favorite;
  final int horseId;
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
    this.picturePath,
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
}
