import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/unlock_screen.dart';
import 'package:flutter_application_1/services/car_control_service.dart';

class ControlScreen extends StatefulWidget {
  final CarControlService service;
  const ControlScreen({super.key, required this.service});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  @override
  Widget build(BuildContext context) {
    print('Building ControlScreen'); // Debug print
    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.service.getCarState(), // Use real Firebase stream
      builder: (context, snapshot) {
        print(
          'StreamBuilder state: hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, error=${snapshot.error}',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 4.0,
            ),
          );
        }
        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No data available from Firebase',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        final data = snapshot.data!;
        final engineStarted = data['engine'] == 'on';
        final doorsClosed = data['right_door'] == 'locked';
        final leftDoorClosed = data['left_door'] == 'locked';
        final trunkClosed = data['trunk'] == 'closed';
        final climateOn = data['ac'] == 'on';

        return Container(
          color: const Color(0xFF0A1622),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Porsche',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '718 Cayman GT4',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
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
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/ctrl_Img.jpg',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Image load error: $error');
                        return Container(color: Colors.red, height: 200);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Controls',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildControlTile(
                          title: 'Engine',
                          subtitle: engineStarted ? 'Started' : 'Stopped',
                          isActive: engineStarted,
                          icon: Icons.power_settings_new,
                          onChanged: (value) async {
                            await widget.service.toggleEngine(value);
                            setState(
                              () {},
                            ); // Force rebuild to reflect Firebase update
                          },
                        ),
                        _buildControlTile(
                          title: 'Right Door',
                          subtitle: doorsClosed ? 'Closed' : 'Open',
                          isActive: doorsClosed,
                          icon: Icons.lock,
                          onChanged: (value) async {
                            await widget.service.toggleDoors(value);
                            setState(
                              () {},
                            ); // Force rebuild to reflect Firebase update
                          },
                        ),
                        _buildControlTile(
                          title: 'Trunk',
                          subtitle: trunkClosed ? 'Closed' : 'Open',
                          isActive: trunkClosed,
                          icon: Icons.work,
                          onChanged: (value) async {
                            await widget.service.toggleTrunk(value);
                            setState(
                              () {},
                            ); // Force rebuild to reflect Firebase update
                          },
                        ),
                        _buildControlTile(
                          title: 'Left Door',
                          subtitle: leftDoorClosed ? 'On' : 'Off',
                          isActive: leftDoorClosed,
                          icon: Icons.ac_unit,
                          onChanged: (value) async {
                            await widget.service.toggleLeftDoor(value);
                            setState(
                              () {},
                            ); // Force rebuild to reflect Firebase update
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlTile({
    required String title,
    required String subtitle,
    required bool isActive,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(15),
      color:
          isActive
              ? Theme.of(context).primaryColor
              : Colors.black.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          onChanged(!isActive); // Toggle the state on tap
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isActive,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.4),
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
