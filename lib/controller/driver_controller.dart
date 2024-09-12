import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../consts/firebase_consts.dart';
import '../screens/home/home_view.dart';

class DriverController extends GetxController {

  ValueNotifier<String?> selectedVehicleNotifier = ValueNotifier<String?>(null);
  TextEditingController nameController = TextEditingController();
  // TextEditingController numController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
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

  Future<void> registerDriver(String phoneNumber, String accountId) async {
    try {
      if (currentUser != null) {
        String rcBookImageUrl = '';
        String licenseImageUrl = '';
        String passBookImageUrl = '';
        List<String> vehicleImageUrls = [];
        FirebaseMessaging fMessaging = FirebaseMessaging.instance;

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

        final fCMToken = await fMessaging.getToken();

        Map driverData = {
          'account_id': accountId,
          'name': nameController.text.trim(),
          'phoneNumber': phoneNumber.trim(),
          'email': emailController.text.trim(),
          'street': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'postal_code': pinCodeController.text.trim(),
          'country': "IN",
          'PAN_number': panController.text.trim(),
          'beneficiary_name': beneficiaryNameController.text.trim(),
          'acc_number': accNumController.text.trim(),
          'confirm_accNumber': cAccNumController.text.trim(),
          'IFSC_code': ifscController.text.trim(),
          'rcNumber': rcNumController.text.trim(),
          'dl_number': dLController.text.trim(),
          'vehicleType': selectedVehicleNotifier.value,
          'is_verified': false,
          'is_online': true,
          'd_id': currentUser!.uid,
          'admin_token': 'chMbnNrgSgue9ePUstPOA6:APA91bESjX_uYCd-Bikruo4d3Qmmg1LjQLPaKWEwA92LR8GPGt00VXiw4bm63bjYFsiKwFl1ZntsnDO1lKd-aVkwfDjs6LzigAGvBkEbYatZVW74cl9BIuM6ItR1DVNMZGbZYbjZNa39',
          'driver_token': fCMToken,
          'passBookImage': passBookImageUrl,
          'rcBookImage': rcBookImageUrl,
          'vehicleImages': vehicleImageUrls,
          'licenseImage': licenseImageUrl,
        };

        DatabaseReference database = FirebaseDatabase.instance.ref();
        await database.child('drivers').child(currentUser!.uid).set(driverData);

        successSnackBar("User registered successfully!");
        Get.offAll(() =>  HomeView());

        clearControllers();

      } else {
        // Navigator.pop(context); // Close the dialog
        validSnackBar("Account has not been created");
      }

    } catch (e) {
      error("Error registering user", e);
    }
  }

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    beneficiaryNameController.clear();
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
    rcBookImg = null;
    passBookImg = null;
    vehicleImages.clear();
    licenseImg = null;
  }

  var rideRequests = [].obs;

  void getRideRequests(String? vehicleType) {
    DatabaseReference rideRequestsRef = FirebaseDatabase.instance.ref().child('Ride Request');
    rideRequestsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> allRideRequests = event.snapshot.value as Map<dynamic, dynamic>;

        var filteredRequests = allRideRequests.entries.where((entry) {
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
      } else {
        rideRequests.clear();
      }
    }).onError((error) {
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
