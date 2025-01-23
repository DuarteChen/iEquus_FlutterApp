class Horse {
  final int idHorse;
  final String name;
  final String? profilePicturePath;
  final String birthDate;
  final String? pictureRightFrontPath;
  final String? pictureLeftFrontPath;
  final String? pictureRightHindPath;
  final String? pictureLeftHindPath;

  Horse({
    required this.idHorse,
    required this.name,
    this.profilePicturePath,
    required this.birthDate,
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
      birthDate: json['birthDate'],
      pictureRightFrontPath: json['pictureRightFrontPath'],
      pictureLeftFrontPath: json['pictureLeftFrontPath'],
      pictureRightHindPath: json['pictureRightHindPath'],
      pictureLeftHindPath: json['pictureLeftHindPath'],
    );
  }
}
