class Hospital {
  final int id;
  final String name;
  final String streetName;
  final String streetNumber;
  final String postalCode;
  final String city;
  final String country;
  final String? optionalAddressField;

  Hospital({
    required this.id,
    required this.name,
    required this.streetName,
    required this.streetNumber,
    required this.postalCode,
    required this.city,
    required this.country,
    this.optionalAddressField,
  });

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'],
      name: map['name'],
      streetName: map['streetName'],
      streetNumber: map['streetNumber'],
      postalCode: map['postalCode'],
      city: map['city'],
      country: map['country'],
      optionalAddressField: map['optionalAddressField'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'streetName': streetName,
      'streetNumber': streetNumber,
      'postalCode': postalCode,
      'city': city,
      'country': country,
      'optionalAddressField': optionalAddressField,
    };
  }
}
