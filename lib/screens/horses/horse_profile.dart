import 'dart:io';
import 'package:equus/api_services/measure_service.dart';
import 'package:equus/models/client.dart';
import 'package:equus/models/horse.dart';
import 'package:equus/models/measure.dart';
import 'package:equus/providers/horse_provider.dart';
import 'package:equus/screens/appointment/create_appointment.dart';
import 'package:equus/screens/measure/create_measure_screen.dart';
import 'package:equus/screens/xray/xray_creation_screen.dart';
import 'package:equus/widgets/profile_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HorseProfile extends StatefulWidget {
  const HorseProfile({super.key, required this.horse});

  final Horse horse;

  @override
  HorseProfileState createState() => HorseProfileState();
}

class HorseProfileState extends State<HorseProfile>
    with SingleTickerProviderStateMixin {
  File? _profilePictureFile;
  late Future<void> _initializationFuture;
  bool _isUpdatingPhoto = false;

  // --- FAB state and animation ---
  bool _isFabMenuOpen = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabButtonsAnimation;

  @override
  void initState() {
    super.initState();

    _initializationFuture = _initializeScreen();

    // --- Initialize animation controller ---
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabButtonsAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initializeScreen() async {
    try {
      final horseProvider = Provider.of<HorseProvider>(context, listen: false);

      await Future.wait([
        horseProvider.loadHorseData(widget.horse.idHorse),
        horseProvider.loadHorseClients(widget.horse.idHorse),
        horseProvider.loadHorseMeasures(widget.horse.idHorse),
      ]);
    } catch (e) {
      debugPrint("Error initializing Horse Profile: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading!')),
        );
        Navigator.pop(context);
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
      if (_isFabMenuOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  // Handles picking an image from the specified source
  Future<void> pickImage(ImageSource source) async {
    // Prevent picking a new image while an update is in progress
    if (_isUpdatingPhoto) return;

    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      _profilePictureFile = File(pickedImage.path);

      await _updateHorsePhoto();
    }
  }

  Future<void> _updateHorsePhoto() async {
    if (_profilePictureFile == null) return;

    setState(() {
      _isUpdatingPhoto = true;
    });

    final horseProvider = Provider.of<HorseProvider>(context, listen: false);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await horseProvider.updateHorsePhoto(
        widget.horse.idHorse,
        _profilePictureFile!,
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Horse photo updated successfully!'),
        ),
      );
    } catch (e) {
      debugPrint("Error in _updateHorsePhoto UI: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update horse photo'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // --- Loading State ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // --- Error State ---
        else if (snapshot.hasError) {
          return Scaffold(
            // Provide Scaffold on error
            body: Center(
              child: Padding(
                // Add padding for error message
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error initializing Horse Profile: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          );
        }
        // --- Success State ---
        else {
          final horseProvider = Provider.of<HorseProvider>(context);

          final currentHorse = horseProvider.currentHorse ?? widget.horse;

          return Scaffold(
            floatingActionButton: _buildFloatingActionButton(),
            body: Scrollbar(
              interactive: true,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Stretch children horizontally
                  children: [
                    // Profile Image Section
                    ProfileImagePreview(
                      horse: widget.horse,
                      profileImageProvider: horseProvider.profileImageProvider,
                      onImageSourceSelected: pickImage,
                      //isLoading: _isUpdatingPhoto, // Pass loading state
                    ),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.horse.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Horse Info Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Horizontal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Basic Info Section ---
                          Text(
                            'Basic Info',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: Icon(
                                  Icons.cake_outlined,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              title: Text(
                                currentHorse.dateNameBirthDateToString() ??
                                    'Not specified',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: const Text("Birthday"),
                            ),
                          ),

                          const Divider(height: 32),

                          // --- Owners Section ---
                          Text(
                            'Owners',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildClientList(
                            context,
                            horseProvider.horseOwners,
                            "Owner",
                            Icons.people_alt,
                          ),
                          const SizedBox(height: 16),

                          // --- Care Takers Section ---
                          Text(
                            'Care Takers',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildClientList(
                            context,
                            horseProvider.horseClients,
                            "Care Taker",
                            Icons.people_alt_outlined,
                          ),
                          const Divider(height: 32),

                          // --- Measures Graphs Section ---
                          if (horseProvider.horseMeasures.isNotEmpty) ...[
                            Text(
                              'Measures Trends',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildMeasuresGraphs(horseProvider.horseMeasures),
                            const Divider(height: 32),
                            Text(
                              'All Measures',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            _buildMeasuresList(horseProvider.horseMeasures),
                            const SizedBox(
                                height: 16), // Add some space at the bottom
                            // This divider is already present after the graphs,
                            // so we might not need an extra one here.
                            const Divider(height: 32),
                          ] else ...[
                            const SizedBox(height: 16),
                            Text(
                              'Measures Trends',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                'No measures data available for this horse.'),
                            const Divider(height: 32),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMeasuresGraphs(List<Measure> measures) {
    // Filter measures that have at least one of algorithmBW or userBW
    final List<Measure> bwMeasures = measures
        .where((m) => m.algorithmBW != null || m.userBW != null)
        .toList();

    // Filter measures that have at least one of algorithmBCS or userBCS
    final List<Measure> bcsMeasures = measures
        .where((m) => m.algorithmBCS != null || m.userBCS != null)
        .toList();

    // Sort measures by date for chronological display
    bwMeasures.sort((a, b) => a.date.compareTo(b.date));
    bcsMeasures.sort((a, b) => a.date.compareTo(b.date));

    return Column(
      children: [
        _buildGraphPlaceholder('Body Weight (BW) Trend', bwMeasures, 'BW'),
        const SizedBox(height: 16),
        _buildGraphPlaceholder(
            'Body Condition Score (BCS) Trend', bcsMeasures, 'BCS'),
      ],
    );
  }

  Widget _buildGraphPlaceholder(String title, List<Measure> data, String type) {
    if (data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          title: Text(title),
          subtitle: Text('No data available for $type trend.'),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Adjust height as needed
              child: _buildLineChart(data, type),
            ),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Measure> data, String type) {
    // Prepare the data for the chart
    List<FlSpot> algoSpots = [];
    List<FlSpot> userSpots = [];

    for (var i = 0; i < data.length; i++) {
      final measure = data[i];
      final xValue = measure.date.millisecondsSinceEpoch
          .toDouble(); // Use millisecondsSinceEpoch for x-axis

      if (type == 'BW') {
        if (measure.algorithmBW != null) {
          algoSpots.add(FlSpot(xValue, measure.algorithmBW!.toDouble()));
        }
        if (measure.userBW != null) {
          userSpots.add(FlSpot(xValue, measure.userBW!.toDouble()));
        }
      } else if (type == 'BCS') {
        if (measure.algorithmBCS != null) {
          algoSpots.add(FlSpot(xValue, measure.algorithmBCS!.toDouble()));
        }
        if (measure.userBCS != null) {
          userSpots.add(FlSpot(xValue, measure.userBCS!.toDouble()));
        }
      }
    }

    // Determine min and max Y values for dynamic axis scaling
    double minY = 0;
    double maxY = type == 'BW' ? 800 : 9; // Default max values

    final allYValues = [
      ...algoSpots.map((e) => e.y),
      ...userSpots.map((e) => e.y)
    ];

    if (allYValues.isNotEmpty) {
      allYValues.sort();
      minY = (allYValues.first * 0.8).floorToDouble(); // 20% buffer at bottom
      maxY = (allYValues.last * 1.2).ceilToDouble(); // 20% buffer at top
    }

    // Ensure min/max are not the same if there's only one point
    if (minY == maxY) {
      minY = minY > 10 ? minY - 10 : 0;
      maxY = maxY + 10;
    }

    // Create LineChart widget
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              strokeWidth: 0.5,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Convert millisecondsSinceEpoch back to DateTime
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Format date as desired, e.g., 'MM/dd'
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  child: Text(
                    '${date.month}/${date.day}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              // Adjust interval dynamically to show around 4 labels
              interval: data.length > 1
                  ? (data.last.date.millisecondsSinceEpoch.toDouble() -
                          data.first.date.millisecondsSinceEpoch.toDouble()) /
                      3
                  : null,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 8.0,
                  child: Text(
                    value.toInt().toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
              interval: type == 'BW' ? 100 : 1, // Example intervals
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.8),
            width: 1,
          ),
        ),
        minX: data.isNotEmpty
            ? data.first.date.millisecondsSinceEpoch.toDouble()
            : 0,
        maxX: data.isNotEmpty
            ? data.last.date.millisecondsSinceEpoch.toDouble()
            : 1,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (LineBarSpot spot) =>
                Theme.of(context).primaryColor.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                // Find the original measure based on the x-value (timestamp)
                final measure = data.firstWhere((m) =>
                    m.date.millisecondsSinceEpoch.toDouble() == touchedSpot.x);
                final date = measure.date.toLocal();
                final value = touchedSpot.y;
                final label =
                    touchedSpot.bar.color == Theme.of(context).primaryColor
                        ? 'Algorithm'
                        : 'User';

                return LineTooltipItem(
                  '$label: ${value.toStringAsFixed(1)}\n${date.month}/${date.day}/${date.year}',
                  TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          if (algoSpots.isNotEmpty)
            LineChartBarData(
              spots: algoSpots,
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
          if (userSpots.isNotEmpty)
            LineChartBarData(
              spots: userSpots,
              isCurved: true,
              color: Theme.of(context)
                  .colorScheme
                  .secondary, // Use secondary color for user data
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.secondary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            color: Theme.of(context).primaryColor,
            label: 'Algorithm Data',
          ),
          const SizedBox(width: 20),
          _buildLegendItem(
            color: Theme.of(context).colorScheme.secondary,
            label: 'User Data',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMeasuresList(List<Measure> measures) {
    if (measures.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          title: Text('No individual measures recorded.'),
        ),
      );
    }

    // Sort measures by date in descending order (most recent first)
    final sortedMeasures = List<Measure>.from(measures)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: sortedMeasures.map(
        (measure) {
          // Use a unique key for each Dismissible widget
          return Dismissible(
            key: ObjectKey(
                measure), // Use ObjectKey for unique Measure instances
            direction: DismissDirection.endToStart, // Swipe from right to left
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content: Text(
                        "Are you sure you want to delete the measure from ${measure.date.toLocal().toIso8601String().split('T')[0]}?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                // Call the delete method on the Measure object
                await measure.deleteMeasure();

                // Refresh the entire screen data after successful deletion
                setState(() {
                  _initializationFuture = _initializeScreen();
                });

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                      content: Text(
                          'Measure from ${measure.date.toLocal().toIso8601String().split('T')[0]} deleted.')),
                );
              } catch (e) {
                debugPrint("Error deleting measure: $e");
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                      content: Text(
                          'Failed to delete measure from ${measure.date.toLocal().toIso8601String().split('T')[0]}.')),
                );
                // If deletion fails, rebuild to show the item again
                if (mounted) {
                  setState(() {
                    _initializationFuture =
                        _initializeScreen(); // Re-fetch to restore if failed
                  });
                }
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (measure.algorithmBW != null || measure.userBW != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.monitor_weight_outlined,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'BW: Algorithm: ${measure.algorithmBW ?? 'N/A'} Kg - User: ${measure.userBW ?? 'N/A'} Kg',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (measure.algorithmBCS != null || measure.userBCS != null)
                      Row(
                        children: [
                          Icon(Icons.star_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'BCS: Algorithm: ${measure.algorithmBCS ?? 'N/A'}, User: ${measure.userBCS ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Measured on ${measure.date.toLocal().toIso8601String().split('T')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'View details for measure on ${measure.date.toLocal().toIso8601String().split('T')[0]}')),
                  );
                },
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // The expanding buttons
        IgnorePointer(
          ignoring: !_isFabMenuOpen,
          child: FadeTransition(
            opacity: _fabButtonsAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_fabButtonsAnimation),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildFabMenuItem(
                    label: 'Appointment',
                    icon: Icons.calendar_today,
                    onTap: () async {
                      _toggleFabMenu();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateAppointment(horse: widget.horse),
                        ),
                      );
                      // After returning from CreateAppointment, refresh data
                      setState(() {
                        _initializationFuture = _initializeScreen();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFabMenuItem(
                    label: 'X-Ray',
                    icon: Icons.medication_outlined,
                    onTap: () async {
                      _toggleFabMenu();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              XRayCreation(horse: widget.horse),
                        ),
                      );
                      // After returning from XRayCreation, refresh data
                      setState(() {
                        _initializationFuture = _initializeScreen();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildFabMenuItem(
                    label: 'Measure',
                    icon: Icons.stream,
                    onTap: () async {
                      _toggleFabMenu();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateMeasureScreen(horse: widget.horse),
                        ),
                      );
                      // After returning from CreateMeasureScreen, refresh data
                      setState(() {
                        _initializationFuture = _initializeScreen();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        // The main FAB
        FloatingActionButton(
          onPressed: _toggleFabMenu,
          shape: const CircleBorder(), // Explicitly ensure it's a circle
          child: AnimatedBuilder(
            animation: _fabAnimationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Plus icon (visible when menu is closed, rotates and fades out when opening)
                  RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.125).animate(
                      CurvedAnimation(
                        parent: _fabAnimationController,
                        curve: const Interval(0.0, 0.5,
                            curve: Curves
                                .easeOut), // Rotate and fade out in first half
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _fabAnimationController,
                          curve: const Interval(0.0, 0.5,
                              curve: Curves.easeOut), // Fade out in first half
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                  // Close icon (visible when menu is open, fades in when opening)
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _fabAnimationController,
                        curve: const Interval(0.5, 1.0,
                            curve: Curves.easeIn), // Fade in in second half
                      ),
                    ),
                    child: const Icon(Icons.close),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Keep existing color
            borderRadius:
                BorderRadius.circular(25), // Make it more rounded, like a pill
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(label,
              style: TextStyle(color: Theme.of(context).primaryColor)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label, // Unique heroTag for each FAB
          onPressed: onTap,
          shape: const CircleBorder(), // Explicitly ensure it's a circle
          child: Icon(icon),
        ),
      ],
    );
  }

  Widget _buildClientList(
      BuildContext context, List<Client> clients, String role, IconData icon) {
    if (clients.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.grey.shade600),
          ),
          title: Text('No ${role}s assigned'),
          dense: true,
        ),
      );
    }
    return Column(
      children: clients.map((client) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            title: Text(
              client.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            subtitle: Text(role),
            onTap: () {
              // TODO: Implement navigation to client profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Navigate to ${client.name}\'s profile (TODO)')),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
