import 'package:firebase_database/firebase_database.dart';

class CarControlService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(); // Root node

  // Stream to listen to real-time changes in car state
  Stream<Map<String, dynamic>> getCarState() {
    print('Fetching car state from Firebase'); // Debug print
    return _db.onValue
        .map((event) {
          final data = Map<String, dynamic>.from(
            event.snapshot.value as Map? ?? {},
          );
          print('Car state data: $data'); // Debug print
          return data.isNotEmpty
              ? data
              : {
                'engine': 'off',
                'right_door': 'locked',
                'trunk': 'closed',
                'ac': 'off',
                'climate': 21,
                'temp': 21,
                'left_door': 'locked',
              };
        })
        .handleError((error) {
          print('Car state stream error: $error'); // Debug print for errors
          return {
            'engine': 'off',
            'right_door': 'locked',
            'trunk': 'closed',
            'ac': 'off',
            'climate': 21,
            'temp': 21,
            'left_door': 'locked',
          }; // Fallback data
        })
        .timeout(
          const Duration(seconds: 5),
          onTimeout: (sink) {
            print('Stream timeout after 5 seconds');
            sink.add({
              'engine': 'off',
              'right_door': 'locked',
              'trunk': 'closed',
              'ac': 'off',
              'climate': 21,
              'temp': 21,
              'left_door': 'locked',
            }); // Default data on timeout
          },
        );
  }

  // Toggle engine state
  Future<void> toggleEngine(bool value) async {
    try {
      print('Toggling engine to: ${value ? 'on' : 'off'}'); // Debug print
      await _db.update({'engine': value ? 'on' : 'off'});
      print('Engine toggle successful');
    } catch (e) {
      print('Error toggling engine: $e');
      rethrow;
    }
  }

  // Toggle doors state
  Future<void> toggleDoors(bool value) async {
    try {
      print('Toggling doors to: ${value ? 'locked' : 'open'}'); // Debug print
      await _db.update({'right_door': value ? 'locked' : 'open'});
      print('Doors toggle successful');
    } catch (e) {
      print('Error toggling doors: $e');
      rethrow;
    }
  }

  // Toggle left_dooor state
  Future<void> toggleLeftDoor(bool value) async {
    try {
      print('Toggling doors to: ${value ? 'locked' : 'open'}'); // Debug print
      await _db.update({'left_door': value ? 'locked' : 'open'});
      print('Doors toggle successful');
    } catch (e) {
      print('Error toggling doors: $e');
      rethrow;
    }
  }

  // Toggle trunk state
  Future<void> toggleTrunk(bool value) async {
    try {
      print('Toggling trunk to: ${value ? 'closed' : 'open'}'); // Debug print
      await _db.update({'trunk': value ? 'closed' : 'open'});
      print('Trunk toggle successful');
    } catch (e) {
      print('Error toggling trunk: $e');
      rethrow;
    }
  }

  // Toggle climate control (on/off)
  Future<void> toggleClimate(bool value) async {
    try {
      print('Toggling climate to: ${value ? 'on' : 'off'}'); // Debug print
      await _db.update({'ac': value ? 'on' : 'off'});
      print('Climate toggle successful');
    } catch (e) {
      print('Error toggling climate: $e');
      rethrow;
    }
  }

  // Set climate temperature (updates 'climate' key)
  Future<void> setClimate(double temperature) async {
    try {
      print('Setting climate temperature to: $temperature'); // Debug print
      await _db.update({'climate': temperature});
      print('Climate temperature set successful');
    } catch (e) {
      print('Error setting climate temperature: $e');
      rethrow;
    }
  }
}
