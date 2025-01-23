import 'package:equus/models/human.dart';

class Client extends Human {
  Client({
    required super.name,
    super.email,
    super.phoneNumber,
    super.phoneCountryCode,
  });
}
