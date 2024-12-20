import 'dart:io';
import 'dart:convert';
import 'package:easy_go_partner/screens/login/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  void validate() async {
    if (driverController.panController.text.isEmpty) {
      authController.validSnackBar("PAN Number cannot be empty");
    } else if (driverController.beneficiaryNameController.text.isEmpty) {
      authController.validSnackBar("Bank Name cannot be empty");
    } else if (driverController.ifscController.text.isEmpty) {
      authController.validSnackBar("IFSC Number cannot be empty");
    } else if (driverController.accNumController.text.isEmpty) {
      authController.validSnackBar("Account Number cannot be empty");
    } else if (driverController.cAccNumController.text.isEmpty) {
      authController.validSnackBar("Re-enter Account Number");
    } else if (driverController.accNumController.text !=
        driverController.cAccNumController.text) {
      authController.validSnackBar("Account numbers do not match");
    } else if (driverController.passBookImg == null) {
      authController.validSnackBar("Upload Passbook image");
    } else {
      await createAccount();
    }
  }

  Future<void> createAccount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Processing, Please wait...");
        },
      );

      final url =
          Uri.parse('https://easygoapi-eieu6qudpq-uc.a.run.app/accounts');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "beneficiary_name": driverController.beneficiaryNameController.text,
          "email": driverController.emailController.text,
          "bank_account_number": driverController.accNumController.text,
          "ifsc_code": driverController.ifscController.text,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accountId = responseData['account_id'];

        await Get.to(() =>
            OtpScreen(widget.countryCode + widget.phoneNumber, accountId));
      } else {
        authController
            .validSnackBar("Failed to create account: ${response.body}");
      }
    } catch (e) {
      Navigator.pop(context);
      authController.validSnackBar("An error occurred: $e");
    }
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Register as a Driver"),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: ListView(
          children: [
            SizedBox(height: height * 0.01),
            Text(
              "Fill your Bank Details",
              style: TextStyle(
                  fontSize: width * 0.05, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: height * 0.02),
            formField(
              controller: driverController.panController,
              "PAN Number",
              Icons.credit_card_outlined,
              capital: true,
            ),
            SizedBox(height: height * 0.02),
            formField(
              controller: driverController.beneficiaryNameController,
              "Your Name As Per Bank Account",
              Icons.account_balance_outlined,
            ),
            SizedBox(height: height * 0.02),
            formField(
              controller: driverController.ifscController,
              "IFSC Code",
              Icons.numbers,
              capital: true,
            ),
            SizedBox(height: height * 0.02),
            formField(
              controller: driverController.accNumController,
              "Enter Account Number",
              Icons.account_box_outlined,
              obscure: true,
              isNum: true,
            ),
            SizedBox(height: height * 0.02),
            formField(
              controller: driverController.cAccNumController,
              "Re-Enter Account Number",
              Icons.repeat_outlined,
              isNum: true,
            ),
            SizedBox(height: height * 0.02),
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
                  EdgeInsets.symmetric(vertical: height * 0.018),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "*Make sure that Account Number is clearly visible",
                style: TextStyle(color: Colors.grey, fontSize: height * 0.015),
              ),
            ),
            SizedBox(height: height * 0.01),
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
                      // SizedBox(height: height * 0.02),
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
            SizedBox(height: height * 0.018),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                hint: "Continue",
                onPress: () async {
                  validate();
                },
                borderRadius: BorderRadius.circular(5.0),
                color: const Color(0xFF0000FF),
              ),
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
