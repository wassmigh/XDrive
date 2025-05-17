import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/unlock_screen.dart';
import 'package:flutter_application_1/services/car_control_service.dart';
import '../widgets/temperature_arc_painter.dart';

class ClimateScreen extends StatefulWidget {
  final CarControlService service;
  const ClimateScreen({super.key, required this.service});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  double temperature =
      21; // Controlled by gesture, updates 'climate' in Firebase
  String activeMode = 'Auto';
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    // Initialize temperature from Firebase 'climate' value
    widget.service.getCarState().first.then((data) {
      setState(() {
        temperature = (data['climate'] ?? 21).toDouble();
      });
    });
  }

  // Debounce function to limit Firebase updates
  void debounce(
    void Function() action, [
    Duration delay = const Duration(milliseconds: 300),
  ]) {
    final now = DateTime.now();
    if (_lastUpdate == null || now.difference(_lastUpdate!) > delay) {
      _lastUpdate = now;
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1622), Color(0xFF051018)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          'Climate',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UnlockScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_open,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModeButton('Auto', Icons.auto_mode),
                    _buildModeButton('Cool', Icons.ac_unit),
                    _buildModeButton('Fan', Icons.wind_power),
                    _buildModeButton('Heat', Icons.whatshot),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 30,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: TemperatureArcPainter(
                              progress: (temperature - 15) / 15,
                              progressColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${temperature.toInt()}°C',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onPanUpdate: (details) {
                            final RenderBox box =
                                context.findRenderObject() as RenderBox;
                            final center = box.size.center(Offset.zero);
                            final position = details.localPosition;
                            final angle = (position - center).direction;

                            if (angle > -2.35 && angle < 2.35) {
                              double newTemp = 15 + ((angle + 2.35) / 4.7) * 15;
                              newTemp = newTemp.clamp(15, 30);
                              setState(() {
                                temperature = double.parse(
                                  newTemp.toStringAsFixed(1),
                                );
                              });
                              debounce(() {
                                widget.service
                                    .setClimate(temperature)
                                    .catchError((e) {
                                      print('Failed to set climate: $e');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to set climate: $e',
                                          ),
                                        ),
                                      );
                                    });
                              });
                            }
                          },
                          child: Container(
                            width: 280,
                            height: 280,
                            color: Colors.transparent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Separate StreamBuilder for Firebase data
                StreamBuilder<Map<String, dynamic>>(
                  stream: widget.service.getCarState(),
                  builder: (context, snapshot) {
                    print(
                      'ClimateScreen StreamBuilder: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, error=${snapshot.error}',
                    );
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // Avoid showing loading indicator
                    }
                    if (snapshot.hasError) {
                      print(
                        'ClimateScreen StreamBuilder error: ${snapshot.error}',
                      );
                      return const Text(
                        'Error fetching data',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                        'No data available from Firebase',
                        style: TextStyle(color: Colors.white),
                      );
                    }

                    final data = snapshot.data!;
                    final acOn = data['ac'] == 'on';
                    final temp = (data['temp'] ?? 21).toDouble();

                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AC is ON',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Currently ${temp.toInt()}°C',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: acOn,
                            onChanged: (value) async {
                              try {
                                await widget.service.toggleClimate(value);
                              } catch (e) {
                                print('Failed to toggle climate: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to toggle climate: $e',
                                    ),
                                  ),
                                );
                              }
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon) {
    final isActive = activeMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeMode = mode;
        });
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  isActive
                      ? Theme.of(context).primaryColor
                      : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            mode,
            style: TextStyle(
              fontSize: 14,
              color:
                  isActive
                      ? Theme.of(context).primaryColor
                      : Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
