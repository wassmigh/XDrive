import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/control_screen.dart';
import 'package:flutter_application_1/screens/climate_screen.dart';
import 'package:flutter_application_1/services/car_control_service.dart';

class CarControlApp extends StatefulWidget {
  const CarControlApp({super.key});

  @override
  State<CarControlApp> createState() => _CarControlAppState();
}

class _CarControlAppState extends State<CarControlApp> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final CarControlService _service = CarControlService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          ControlScreen(service: _service),
          ClimateScreen(service: _service),
          Container(), // Placeholder for Location
          Container(), // Placeholder for Profile
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Controls',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Climate'),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: 'Location',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
