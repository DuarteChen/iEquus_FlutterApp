class Hospital {
  final int id;
  final String name;
  final String? logoPath;
  int veterinarianAdminId;

  Hospital(
      {required this.id,
      required this.name,
      this.logoPath,
      required this.veterinarianAdminId});

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'],
      name: map['name'],
      logoPath: map['logoPath'],
      veterinarianAdminId: map['admin']['idVeterinarian'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
      'admin': veterinarianAdminId,
    };
  }
}
