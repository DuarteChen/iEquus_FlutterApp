class Appointment {
  final int idAppointment;
  final int horseId;
  final int veterinarianId;
  final int? lamenessRightFront;
  final int? lamenessLeftFront;
  final int? lamenessRightHind;
  final int? lamenessLeftHind;
  final int? bpm;
  final String? muscleTensionFrequency;
  final String? muscleTensionStiffness;
  final String? muscleTensionR;
  final String? cbcPath;
  final String? comment;
  final DateTime date;
  final int? ecgTime;

  Appointment({
    required this.idAppointment,
    required this.horseId,
    required this.veterinarianId,
    this.lamenessRightFront,
    this.lamenessLeftFront,
    this.lamenessRightHind,
    this.lamenessLeftHind,
    this.bpm,
    this.muscleTensionFrequency,
    this.muscleTensionStiffness,
    this.muscleTensionR,
    this.cbcPath,
    this.comment,
    required this.date,
    this.ecgTime,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      idAppointment: json['idAppointment'] as int,
      horseId: json['horseId'] as int,
      veterinarianId: json['veterinarianId'] as int,
      lamenessRightFront: json['lamenessRightFront'] as int?,
      lamenessLeftFront: json['lamenessLeftFront'] as int?,
      lamenessRightHind: json['lamenessRightHind'] as int?,
      lamenessLeftHind: json['lamenessLeftHind'] as int?,
      bpm: json['BPM'] as int?,
      muscleTensionFrequency: json['muscleTensionFrequency'] as String?,
      muscleTensionStiffness: json['muscleTensionStiffness'] as String?,
      muscleTensionR: json['muscleTensionR'] as String?,
      cbcPath: json['CBCpath'] as String?,
      comment: json['comment'] as String?,
      date: DateTime.parse(json['date'] as String),
      ecgTime: json['ECGtime'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAppointment': idAppointment,
      'horseId': horseId,
      'veterinarianId': veterinarianId,
      'lamenessRightFront': lamenessRightFront,
      'lamenessLeftFront': lamenessLeftFront,
      'lamenessRightHind': lamenessRightHind,
      'lamenessLeftHind': lamenessLeftHind,
      'BPM': bpm,
      'muscleTensionFrequency': muscleTensionFrequency,
      'muscleTensionStiffness': muscleTensionStiffness,
      'muscleTensionR': muscleTensionR,
      'CBCpath': cbcPath,
      'comment': comment,
      'date': date.toIso8601String(),
      'ECGtime': ecgTime,
    };
  }

  @override
  String toString() {
    return 'Appointment{idAppointment: $idAppointment, horseId: $horseId, veterinarianId: $veterinarianId, date: $date}';
  }
}
