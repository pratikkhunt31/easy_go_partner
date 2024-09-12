import 'package:flutter/services.dart';

/// This is a Static Class, so no need to instantiate it
class LocationServicePlugin {
  LocationServicePlugin._();

  static const platform = MethodChannel('com.easy_go.partner/locationService');

  // Function to start location service
  static Future<void> startLocationService(String rideRequestId) async {
    try {
      final String result = await platform.invokeMethod('startService', {
        "rideRequestId": rideRequestId,
      });
      print(result); // Log the result
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  // Function to stop location service
  static Future<void> stopLocationService() async {
    try {
      final String result = await platform.invokeMethod('stopService');
      print(result); // Log the result
    } on PlatformException catch (e) {
      print("Failed to stop service: '${e.message}'.");
    }
  }

  // Function to check if the service is running
  static Future<bool> checkServiceRunning() async {
    try {
      final bool isRunning = await platform.invokeMethod('isServiceRunning');
      return isRunning;
    } on PlatformException catch (e) {
      print("Failed to check service: '${e.message}'.");
      return false;
    }
  }
}
