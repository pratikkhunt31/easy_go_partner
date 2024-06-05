import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../consts/firebase_consts.dart';

class DriverController extends GetxController {
  ValueNotifier<String?> selectedVehicleNotifier = ValueNotifier<String?>(null);
  TextEditingController nameController = TextEditingController();
  // TextEditingController numController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController bNameController = TextEditingController();
  TextEditingController accNumController = TextEditingController();
  TextEditingController cAccNumController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController rcNumController = TextEditingController();
  TextEditingController vNumController = TextEditingController();
  TextEditingController dLController = TextEditingController();

  File? rcBookImg;
  File? passBookImg;
  List<File> vehicleImages = [];
  File? licenseImg;
  final picker = ImagePicker();

  Future<String> uploadFile(File file) async {
    String fileName = basename(file.path);
    var destination = 'images/${currentUser!.uid}/$fileName';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(destination);
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> registerUser(String phoneNumber) async {
    try {
      String rcBookImageUrl = '';
      String licenseImageUrl = '';
      String passBookImageUrl = '';
      List<String> vehicleImageUrls = [];

      if (rcBookImg != null) {
        rcBookImageUrl = await uploadFile(rcBookImg!);
      }

      if (licenseImg != null) {
        licenseImageUrl = await uploadFile(licenseImg!);
      }

      if (passBookImg != null) {
        passBookImageUrl = await uploadFile(passBookImg!);
      }

      for (File image in vehicleImages) {
        vehicleImageUrls.add(await uploadFile(image));
      }

      Map<String, dynamic> driverData = {
        'name': nameController.text.trim(),
        'phoneNumber': phoneNumber.trim(),
        'email': emailController.text.trim(),
        'street': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'postal_code': pinCodeController.text.trim(),
        'country': "IN",
        'PAN_number': panController.text.trim(),
        'bank_name': bNameController.text.trim(),
        'acc_number': accNumController.text.trim(),
        'confirm_accNumber': cAccNumController.text.trim(),
        'IFSC_code': ifscController.text.trim(),
        'rcNumber': rcNumController.text.trim(),
        'vehicleType': selectedVehicleNotifier.value,
        'is_verified': false,
        'is_online': true,
        'd_id': currentUser!.uid,
        'passBookImage': passBookImageUrl,
        'rcBookImage': rcBookImageUrl,
        'vehicleImages': vehicleImageUrls,
        'licenseImage': licenseImageUrl,
      };

      DatabaseReference database = FirebaseDatabase.instance.ref();
      await database.child('drivers').child(currentUser!.uid).set(driverData);

      successSnackBar("User registered successfully!");
      clearControllers();

    } catch (e) {
      error("Error registering user", e);
    }
  }

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    bNameController.clear();
    accNumController.clear();
    cAccNumController.clear();
    ifscController.clear();
    panController.clear();
    addressController.clear();
    cityController.clear();
    stateController.clear();
    pinCodeController.clear();
    rcNumController.clear();
    vNumController.clear();
    dLController.clear();
    selectedVehicleNotifier.value = null;
    rcBookImg = null;
    passBookImg = null;
    vehicleImages.clear();
    licenseImg = null;
  }

  var rideRequests = [].obs;

  void getRideRequests(String vehicleType) {
    DatabaseReference rideRequestsRef = FirebaseDatabase.instance.ref().child('Ride Request');
    rideRequestsRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        // Using Map<dynamic, dynamic> to handle potential type issues
        Map<dynamic, dynamic> allRideRequests = event.snapshot.value as Map<dynamic, dynamic>;

        var filteredRequests = allRideRequests.entries.where((entry) {
          // Ensuring that the value is of type Map
          if (entry.value is Map) {
            var rideRequest = Map<String, dynamic>.from(entry.value);
            return rideRequest['v_type'] == vehicleType && rideRequest['driver_id'] == 'waiting';
          }
          return false;
        }).map((entry) {
          var rideRequest = Map<String, dynamic>.from(entry.value);
          rideRequest['rideRequestId'] = entry.key;
          return rideRequest;
        }).toList();

        rideRequests.value = filteredRequests;
      }
    }).catchError((error) {
      print("Failed to load ride requests: $error");
    });
  }

  void startListeningForRideRequests(String driverId) {
    DatabaseReference driverRef =
    FirebaseDatabase.instance.ref().child('drivers').child(driverId).child('newRideRequests');

    driverRef.onChildAdded.listen((event) {
      String rideRequestId = event.snapshot.key!;
      // Handle the new ride request here
      fetchRideRequestDetails(rideRequestId);
    });
  }

  void fetchRideRequestDetails(String rideRequestId) {
    DatabaseReference rideRequestRef =
    FirebaseDatabase.instance.ref().child('Ride Request').child(rideRequestId);

    rideRequestRef.once().then((DatabaseEvent event) {
      Map<String, dynamic> rideRequestData =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      // Process the ride request data
      displayRideRequestToDriver(rideRequestData);
    });
  }

  void displayRideRequestToDriver(Map<String, dynamic> rideRequestData) {
    // Show a notification or update the UI with the ride request details
    print("New ride request received: $rideRequestData");
    // Here you can navigate to a screen or show a dialog with ride request details
  }

  void getRideRequests2() async {
    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child("Ride Request");

    try {
      DatabaseEvent event = await rideRequestRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        Map<dynamic, dynamic> rideRequests =
            snapshot.value as Map<dynamic, dynamic>;

        rideRequests.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> rideInfoMap = Map<String, dynamic>.from(value);

            if (rideInfoMap['v_type'] == 'tempo' &&
                rideInfoMap['is_online'] == true) {
              print("Ride Request ID: $key");
              print("Driver ID: ${rideInfoMap['driver_id']}");
              print("Payment Status: ${rideInfoMap['payment_status']}");
              print("Payout: ${rideInfoMap['payout']}");
              print("Vehicle Type: ${rideInfoMap['v_type']}");
              print("Pickup Location: ${rideInfoMap['pickUp']}");
              print("Dropoff Location: ${rideInfoMap['dropOff']}");
              print("Created At: ${rideInfoMap['created_at']}");
              print("Rider Name: ${rideInfoMap['rider_name']}");
              print("Rider Phone: ${rideInfoMap['rider_phone']}");
              print("Pickup Address: ${rideInfoMap['pickUp_address']}");
              print("Dropoff Address: ${rideInfoMap['dropOff_address']}");
            }
          } else {
            print("Unexpected data format for ride request ID $key: $value");
          }
        });
      } else {
        print("No ride requests found or invalid data format.");
      }
    } catch (e) {
      print("Failed to retrieve ride requests: $e");
    }
  }

  void acceptRequest() async {
    DatabaseReference driversRef =
        FirebaseDatabase.instance.ref().child('drivers');
    driversRef.once().then((DatabaseEvent event) {
      Map<String, dynamic> drivers =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      drivers.forEach((key, value) {
        if (value['vehicleType'] == 'Tempo' && value['is_online'] == true) {
          // Assuming driver ID is stored under key 'driverId' in the drivers database
          String driverId = currentUser!.uid;
          DatabaseReference rideRequestRef =
              FirebaseDatabase.instance.ref().child("Ride Request");
          rideRequestRef.update({'driver_id': driverId}).then((_) {
            print('Driver ID updated successfully.');
          }).catchError((error) {
            print('Failed to update driver ID: $error');
          });
        }
      });
    });
  }

  void listenForRideRequests() {
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid)
        .child('newRideRequests');
    driverRef.onChildAdded.listen((event) {
      String? rideRequestId = event.snapshot.key;
      // Notify driver of new ride request
      // You can show a dialog or notification here
      print("New ride request: $rideRequestId");
    });
  }

  successSnackBar(String message) {
    Get.snackbar(
      "Successfully Logged in",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2EC492),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
    );
  }

  error(String message, _) {
    Get.snackbar(
      "Error",
      "$message\n${_.message}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFD05045),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
    );
  }

  validSnackBar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFD05045),
      colorText: Colors.white,
      borderRadius: 10,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
    );
  }

// Future<void> saveFormData({
//   required String name,
//   required String phoneNumber,
//   required String email,
//   required String address,
//   required String rcNumber,
//   required String vehicleType,
//   required String rcBookImageUrl,
//   required List<String> vehicleImageUrls,
// }) async {
//   final DatabaseReference ref = FirebaseDatabase.instance.ref('drivers').push();
//   await ref.set({
//     'name': name,
//     'phoneNumber': phoneNumber,
//     'email': email,
//     'address': address,
//     'rcNumber': rcNumber,
//     'vehicleType': vehicleType,
//     'rcBookImageUrl': rcBookImageUrl,
//     'vehicleImageUrls': vehicleImageUrls,
//   });
// }
}
