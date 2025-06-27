import 'dart:io';
import 'package:equus/models/horse.dart';
import 'package:flutter/material.dart';

// Removed flutter_secure_storage import as it's no longer needed here

class CreateAppointment extends StatefulWidget {
  final Horse horse;

  const CreateAppointment({super.key, required this.horse});

  @override
  State<StatefulWidget> createState() {
    return CreateAppointmentState();
  }
}

class CreateAppointmentState extends State<CreateAppointment> {
  // --- Appointment Data --- (Keep these as they are specific to this screen's state)
  DateTime appointmentDate = DateTime.now();

  int? lamenessLeftFront;
  int? lamenessRightFront;
  int? lamenessLeftHind;
  int? lamenessRightHind;

  int? bpm;

  String? muscleTensionFrequency;
  String? muscleTensionStifness;
  String? muscleTensionR;

  File? cbc;
  String? comment;
  // ------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Appointment for ${widget.horse.name}"),
          centerTitle: true,
          bottom: const TabBar(tabs: [
            Tab(text: "Main Info", icon: Icon(Icons.medical_information)),
            Tab(text: "AI Measures", icon: Icon(Icons.stream)),
            Tab(text: "Comments", icon: Icon(Icons.comment)),
          ]),
        ),
      ),
    );
  }
}
