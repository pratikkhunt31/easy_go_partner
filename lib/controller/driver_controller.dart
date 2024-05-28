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
  TextEditingController addressController = TextEditingController();
  TextEditingController rcNumController = TextEditingController();
  TextEditingController vNumController = TextEditingController();
  TextEditingController dLController = TextEditingController();


  File? rcBookImg;
  List<File> vehicleImages = [];
  File? licenseImg;
  final picker = ImagePicker();


  Future<String> uploadFile(File file) async {
    String fileName = basename(file.path);
    var destination = 'images/${currentUser!.uid}/$fileName';
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(destination);
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }


  Future<void> registerUser(String phoneNumber) async {
    try {
      String rcBookImageUrl = '';
      String licenseImageUrl = '';
      List<String> vehicleImageUrls = [];

      if (rcBookImg != null) {
        rcBookImageUrl = await uploadFile(rcBookImg!);
      }

      if (licenseImg != null) {
        licenseImageUrl = await uploadFile(licenseImg!);
      }

      for (File image in vehicleImages) {
        vehicleImageUrls.add(await uploadFile(image));
      }

      Map<String, dynamic> userData = {
        'name': nameController.text,
        'phoneNumber': phoneNumber,
        'email': emailController.text,
        'address': addressController.text,
        'rcNumber': rcNumController.text,
        'vehicleType': selectedVehicleNotifier.value,
        'is_verified': false,
        'd_id': currentUser!.uid,
        'rcBookImage': rcBookImageUrl,
        'vehicleImages': vehicleImageUrls,
        'licenseImage': licenseImageUrl,
      };

      DatabaseReference database = FirebaseDatabase.instance.ref();
      await database.child('drivers').child(currentUser!.uid).set(userData);

      successSnackBar("User registered successfully!");
    } catch (e) {
      error("Error registering user", e);
    }
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