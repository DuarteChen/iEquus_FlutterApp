import 'package:flutter/material.dart';

class AppointmentMainInfo extends StatefulWidget {
  DateTime appointmentDate;

  int? lamenessLeftFront;
  int? lamenessRightFront;
  int? lamenessLeftHind;
  int? lamenessRightHind;

  AppointmentMainInfo(
      {super.key,
      required this.appointmentDate,
      required this.lamenessLeftFront,
      required this.lamenessLeftHind,
      required this.lamenessRightFront,
      required this.lamenessRightHind});

  @override
  State<StatefulWidget> createState() {
    return AppointmentMainInfoState();
  }
}

class AppointmentMainInfoState extends State<AppointmentMainInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Main Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Appointment Date: ${widget.appointmentDate}'),
            // Add more widgets to display or edit the lameness information
          ],
        ),
      ),
    );
  }
}
