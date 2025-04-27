import 'package:intl/intl.dart';

class Horse {
  final int idHorse;
  final String name;
  final String? profilePicturePath;
  final DateTime? birthDate;
  final String? pictureRightFrontPath;
  final String? pictureLeftFrontPath;
  final String? pictureRightHindPath;
  final String? pictureLeftHindPath;

  //Contructor
  Horse({
    required this.idHorse,
    required this.name,
    this.profilePicturePath,
    this.birthDate,
    this.pictureRightFrontPath,
    this.pictureLeftFrontPath,
    this.pictureRightHindPath,
    this.pictureLeftHindPath,
  });

  factory Horse.fromJson(Map<String, dynamic> json) {
    return Horse(
      idHorse: json['idHorse'],
      name: json['name'],
      profilePicturePath: json['profilePicturePath'],
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : null,
      pictureRightFrontPath: json['pictureRightFrontPath'],
      pictureLeftFrontPath: json['pictureLeftFrontPath'],
      pictureRightHindPath: json['pictureRightHindPath'],
      pictureLeftHindPath: json['pictureLeftHindPath'],
    );
  }

  String? birthDateToString() {
    if (birthDate == null) {
      return 'No birthday date';
    } else {
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(birthDate!);
    }
  }

  String? dateName_birthDateToString() {
    if (birthDate == null) {
      return 'No birthday date';
    } else {
      final formatter = DateFormat('d MMMM, yyyy');
      return formatter.format(birthDate!);
    }
  }
}
