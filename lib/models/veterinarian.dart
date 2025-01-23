import 'package:equus/models/human.dart';

class Veterinarian extends Human {
  String idCedulaProfissional;

  Veterinarian({
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
    required this.idCedulaProfissional,
  });

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map['idCedulaProfissional'] = idCedulaProfissional;
    return map;
  }
}
