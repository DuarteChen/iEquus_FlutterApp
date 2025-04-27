class Human {
  int idHuman;
  String name;
  String? email;
  String? phoneNumber;
  String? phoneCountryCode;

  Human({
    required this.idHuman,
    required this.name,
    this.email,
    this.phoneNumber,
    this.phoneCountryCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'phoneCountryCode': phoneCountryCode,
    };
  }
}
