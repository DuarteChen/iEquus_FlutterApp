import 'package:flutter/material.dart';

class AppointmentMainInfo extends StatefulWidget {
  final DateTime appointmentDate;

  final int? lamenessLeftFront;
  final int? lamenessRightFront;
  final int? lamenessLeftHind;
  final int? lamenessRightHind;

  const AppointmentMainInfo(
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
          ],
        ),
      ),
    );
  }
}
