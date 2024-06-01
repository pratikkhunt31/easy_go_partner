import 'dart:io';

import 'package:easy_go_partner/screens/login/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/auth_controller.dart';
import '../../controller/driver_controller.dart';
import '../../widget/custom_widget.dart';

class BankDetails extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;

  const BankDetails(this.countryCode, this.phoneNumber, {super.key});

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  AuthController authController = Get.put(AuthController());
  DriverController driverController = Get.put(DriverController());

  validate() async {
    if (driverController.panController.text.isEmpty) {
      authController.validSnackBar("PAN Number is not empty");
    } else if (driverController.bNameController.text.isEmpty) {
      authController.validSnackBar("Bank Name is not empty");
    } else if (driverController.ifscController.text.isEmpty) {
      authController.validSnackBar("IFSC Number is not empty");
    } else if (driverController.accNumController.text.isEmpty) {
      authController.validSnackBar("Account Number is not empty");
    } else if (driverController.cAccNumController.text.isEmpty) {
      authController.validSnackBar("Account Number is not empty");
    } else if (driverController.accNumController.text !=
        driverController.cAccNumController.text) {
      authController.validSnackBar("Account numbers do not match");
    } else if (driverController.passBookImg == null) {
      authController.validSnackBar("Upload Passbook image");
    } else {
      routePage();
    }
  }

  routePage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return ProgressDialog(message: "Processing, Please wait...");
      },
    );
    // await driverController.registerUser(widget.phoneNumber);
    await Future.delayed(Duration());
    Navigator.pop(context);
    await Get.to(() => OtpScreen(widget.countryCode + widget.phoneNumber));
  }

  Future<void> getImage(ImageSource source, Function(File) onSelected) async {
    try {
      final pickedImage =
          await driverController.picker.pickImage(source: source);
      if (pickedImage == null) return;

      setState(() {
        onSelected(File(pickedImage.path));
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void showImagePickerOptions(Function(File) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  getImage(ImageSource.gallery, onSelected);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera, onSelected);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register as a Driver",
          // style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(right: 20.0, left: 20.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Fill your Bank Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.panController,
              "PAN Number",
              Icons.credit_card_outlined,
              capital: true,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.bNameController,
              "Enter Your Bank Name",
              Icons.account_balance_outlined,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.ifscController,
              "IFSC Number",
              Icons.numbers,
              capital: true,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.accNumController,
              "Enter Account Number",
              Icons.account_box_outlined,
              obscure: true,
              isNum: true,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.cAccNumController,
              "Re-Enter Account Number",
              Icons.repeat_outlined,
              isNum: true,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => showImagePickerOptions(
                  (file) => driverController.passBookImg = file),
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload Pass book Image',
                style: TextStyle(fontSize: 15),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade300),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.black87),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(color: Colors.grey.shade600),
                ),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "*Make sure that Account Number is clearly visible",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            driverController.passBookImg != null
                ? Column(
                    children: [
                      Container(
                        width: 150,
                        child: Image.file(
                          driverController.passBookImg!,
                          height: 150,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            driverController.passBookImg = null;
                          });
                        },
                        child: Text('Remove Image'),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                hint: "Continue",
                onPress: () {
                  validate();
                  // driverController
                  //     .registerUser(widget.countryCode + widget.phoneNumber);
                  // Get.to(
                  //   () => OtpScreen(
                  //     widget.countryCode + widget.phoneNumber,
                  //     driverController.nameController.text.trim(),
                  //     driverController.emailController.text.trim(),
                  //   ),
                  // );
                },
                borderRadius: BorderRadius.circular(25.0),
                color: const Color(0xFF0000FF),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
