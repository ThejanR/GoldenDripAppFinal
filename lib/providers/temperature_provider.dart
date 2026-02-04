import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Temperature provider that uses device sensor when available
class TemperatureProvider extends ChangeNotifier {
  double? _currentTemperature;
  Timer? _temperatureTimer;
  int _lastManualUpdate = 0;

  double? get currentTemperature => _currentTemperature;

  String get temperatureRecommendation {
    if (_currentTemperature == null) {
      return 'Temperature sensor not available';
    }

    if (_currentTemperature! >= 25) {
      return 'Cold beverages recommended';
    } else {
      return 'Hot beverages recommended';
    }
  }

  List<String> getRecommendedCategories() {
    if (_currentTemperature == null) {
      // Default to showing all categories if temperature is not available
      return ['Hot Coffee', 'Cold Coffee'];
    }

    if (_currentTemperature! >= 25) {
      // Warm weather - recommend cold beverages
      return ['Cold Coffee'];
    } else {
      // Cold weather - recommend hot beverages
      return ['Hot Coffee'];
    }
  }

  Future<void> startTemperatureMonitoring() async {
    // Initialize with default temperature only once
    if (_currentTemperature == null) {
      _currentTemperature = 22.0;
      notifyListeners();
    }

    // Start simulated temperature with longer intervals to reduce glitching
    _startSimulatedTemperature();
  }

  void _startSimulatedTemperature() {
    // Cancel any existing timer first
    _temperatureTimer?.cancel();

    // Start simulating temperature reading every 60 seconds to minimize glitching
    _temperatureTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      // Only update if no manual temperature has been set recently
      if (_currentTemperature == null ||
          (_currentTemperature == 22.0 &&
              DateTime.now().millisecondsSinceEpoch - _lastManualUpdate >
                  30000)) {
        // Simulate a temperature reading (rotating between cold and warm)
        int cycle = (DateTime.now().millisecondsSinceEpoch ~/ 60000) % 4;
        double simulatedTemp;

        switch (cycle) {
          case 0:
            simulatedTemp = 18.0; // Cold temperature
            break;
          case 1:
            simulatedTemp = 22.0; // Moderate temperature
            break;
          case 2:
            simulatedTemp = 28.0; // Warm temperature
            break;
          case 3:
            simulatedTemp = 16.0; // Cold temperature
            break;
          default:
            simulatedTemp = 22.0;
        }

        _currentTemperature = simulatedTemp;
        notifyListeners();
      }
    });
  }

  // Method to manually set temperature for testing
  void setTestTemperature(double temperature) {
    _currentTemperature = temperature;
    _lastManualUpdate = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  // Method to be called when emulator sensor changes
  void updateFromEmulatorSensor(double temperature) {
    _currentTemperature = temperature;
    _lastManualUpdate = DateTime.now().millisecondsSinceEpoch;
    // Disable auto simulation when manual control is used
    disableAutoSimulation();
    notifyListeners();
  }

  // Method to simulate receiving temperature from Android emulator
  void simulateEmulatorTemperatureChange(double temperature) {
    updateFromEmulatorSensor(temperature);
  }

  // Method to disable automatic simulation when manually controlling
  void disableAutoSimulation() {
    _temperatureTimer?.cancel();
    _temperatureTimer = null;
  }

  // Method to enable automatic simulation
  void enableAutoSimulation() {
    if (_temperatureTimer == null) {
      _startSimulatedTemperature();
    }
  }

  void stopTemperatureMonitoring() {
    _temperatureTimer?.cancel();
    _temperatureTimer = null;
  }

  @override
  void dispose() {
    stopTemperatureMonitoring();
    super.dispose();
  }
}
