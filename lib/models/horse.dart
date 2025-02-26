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
          ? DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
              .parse(json['birthDate']) // Custom parsing
          : null,
      pictureRightFrontPath: json['pictureRightFrontPath'],
      pictureLeftFrontPath: json['pictureLeftFrontPath'],
      pictureRightHindPath: json['pictureRightHindPath'],
      pictureLeftHindPath: json['pictureLeftHindPath'],
    );
  }

  // Custom function to format birthDate to String
  String? birthDateToString() {
    if (birthDate == null) {
      return 'Unknown'; // Or return null, or any placeholder you prefer
    } else {
      // Customize the date format here as you like
      final formatter = DateFormat('dd-MM-yyyy'); // Example: Day-Month-Year
      return formatter.format(birthDate!);
    }
  }
}
