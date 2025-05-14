import 'package:equus/models/hospital.dart';

import 'package:equus/models/human.dart';

class Veterinarian extends Human {
  String idCedulaProfissional;
  Hospital? hospital;

  Veterinarian({
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
    required this.idCedulaProfissional,
    required super.idHuman,
    this.hospital,
  });

  factory Veterinarian.fromMap(Map<String, dynamic> map) {
    Hospital? hospital;
    if (map['hospital'] != null) {
      hospital = Hospital.fromMap(map['hospital']);
    }
    return Veterinarian(
      idHuman: map['idVeterinary'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      phoneCountryCode: map['phoneCountryCode'],
      idCedulaProfissional: map['idCedulaProfissional'],
      hospital: hospital,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['idCedulaProfissional'] = idCedulaProfissional;
    if (hospital != null) {
      map['hospital'] = hospital!.toMap();
    }
    return map;
  }
}
