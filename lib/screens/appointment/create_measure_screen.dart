import 'package:flutter/material.dart';

class CreateMeasureScreen extends StatefulWidget {
  const CreateMeasureScreen(
      {super.key,
      required this.horseID,
      this.appointmentID,
      this.veterinarianID});

  final int horseID;
  final int? appointmentID;
  final int? veterinarianID;

  @override
  CreateMeasureScreenState createState() => CreateMeasureScreenState();
}

class CreateMeasureScreenState extends State<CreateMeasureScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(children: []);
  }
}
