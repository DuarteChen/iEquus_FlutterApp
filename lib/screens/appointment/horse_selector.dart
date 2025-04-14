import 'dart:io';

import 'package:equus/screens/measure/create_appointment.dart';
import 'package:equus/screens/measure/create_measure_screen.dart';
import 'package:equus/screens/xray/xray_creation_screen.dart';
import 'package:equus/widgets/horse_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HorseSelector extends StatefulWidget {
  final String selectorType;

  const HorseSelector({super.key, required this.selectorType});

  @override
  State<HorseSelector> createState() {
    return _HorseSelectorState();
  }
}

class _HorseSelectorState extends State<HorseSelector> {
  @override
  Widget build(BuildContext context) {
    return HorsesListWidget(
      widgetForSelectedScreen: (selectedHorse) {
        if (widget.selectorType == 'appointment') {
          return CreateAppointment(horse: selectedHorse);
        } else if (widget.selectorType == 'measure') {
          return CreateMeasureScreen(horse: selectedHorse);
        } else {
          return XRayCreation(horse: selectedHorse);
        }
      },
    );
  }
}
