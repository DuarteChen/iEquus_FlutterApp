import 'package:equus/models/human.dart';

class Client extends Human {
  bool isOwner;

  Client({
    required super.idHuman,
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
    required this.isOwner,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      idHuman: json['idClient'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      phoneCountryCode: json['phoneCountryCode'],
      isOwner: json['isOwner'],
    );
  }
}
