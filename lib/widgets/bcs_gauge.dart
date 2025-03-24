import 'package:flutter/material.dart';
import 'dart:math';

class BCSGauge extends StatefulWidget {
  int bcsValue;

  BCSGauge({
    super.key,
    required this.bcsValue,
  });

  @override
  State<BCSGauge> createState() => _BCSGaugeState();
}

class _BCSGaugeState extends State<BCSGauge> {
  void popUpBCS(
      BuildContext context, Function(int) onBCSSelected, int initialBCS) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedBCS =
            initialBCS == 0 ? 1 : initialBCS; // Use the initial value properly

        return StatefulBuilder(
          // Allows state changes inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Body Condition Score'),
              content: Wrap(
                spacing: 8.0, // Horizontal spacing
                runSpacing: 8.0, // Vertical spacing when wrapping
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  int value = index + 1;
                  return SizedBox(
                    width: 40,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedBCS = value; // Update selected value
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove internal padding
                        minimumSize: const Size(40, 40), // Ensure size is set
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4), // Square shape
                        ),
                        side: BorderSide(
                          color: selectedBCS == value
                              ? Theme.of(context).primaryColor
                              : Colors.grey, // Border color
                        ),
                        backgroundColor: selectedBCS == value
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors
                                .transparent, // Light background for selection
                      ),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 16, // Adjust text size
                          color: selectedBCS == value
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onBCSSelected(selectedBCS);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double bcsValue = widget.bcsValue.toDouble();
    return Expanded(
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "BCS",
                    style: TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: () => popUpBCS(
                      context,
                      (newBCS) {
                        setState(() {
                          widget.bcsValue = newBCS;
                        });
                      },
                      widget.bcsValue,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Center(
                child: CustomPaint(
                  size: Size(110, 80),
                  painter: GaugePainter(bcsValue),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double bcsValue;

  GaugePainter(this.bcsValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height / 4);
    final radius = size.width / 2;

    final fullSweepAngle = pi;
    const startAngle = -pi;

    final clampedBCS = bcsValue.clamp(1, 5);
    final sweepAngle = (clampedBCS) * (fullSweepAngle / 5);

    // Background arc (full scale)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweepAngle,
      false,
      backgroundPaint,
    );

    // Foreground arc (BCS value)
    final arcPaint = Paint()
      ..color = Color.fromARGB(255, 46, 95, 138)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw BCS value at the center
    final textSpan = TextSpan(
      text: clampedBCS.toInt().toString(),
      style: const TextStyle(
        color: Color.fromARGB(255, 46, 95, 138),
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2 - 10, // Adjust position slightly
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GaugePainter) {
      return oldDelegate.bcsValue != bcsValue;
    }
    return false;
  }
}
