import 'dart:io';

import 'package:equus/models/horse.dart';
import 'package:equus/models/veterinarian.dart';
import 'package:flutter/material.dart';

class CreateAppointment extends StatefulWidget {
  final Horse horse;

  const CreateAppointment({super.key, required this.horse});

  @override
  State<StatefulWidget> createState() {
    return CreateAppointmentState();
  }
}

class CreateAppointmentState extends State<CreateAppointment> {
  //Para iniciar um Veterinário enquanto não há lógica do Login ------------------------------
  Veterinarian? vetObject;

  Future<void> fetchVeterinarian(int id) async {
    Veterinarian? vet = await Veterinarian.fromId(id);

    if (vet != null) {
      vetObject = vet;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVeterinarian(2);
  }

  //------------------------------------------------------------------------------------------

  //Apoointment Data
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("New Appointment"),
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
