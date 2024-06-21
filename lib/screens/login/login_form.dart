import 'dart:io';
import 'dart:async';
import 'package:easy_go_partner/controller/driver_controller.dart';
import 'package:easy_go_partner/model/address.dart';
import 'package:easy_go_partner/screens/home/home_view.dart';
import 'package:easy_go_partner/screens/login/bank_details.dart';
import 'package:easy_go_partner/screens/login/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/auth_controller.dart';
import '../../widget/custom_widget.dart';

class LoginForm extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;

  const LoginForm(this.countryCode, this.phoneNumber, {super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  AuthController authController = Get.put(AuthController());
  DriverController driverController = Get.put(DriverController());

  validate() async {
    if (driverController.nameController.text.isEmpty) {
      authController.validSnackBar("Name is not empty");
    } else if (driverController.emailController.text.isEmpty) {
      authController.validSnackBar("Email Address is not empty");
    } else if (!driverController.emailController.text.contains("@gmail.com")) {
      authController.validSnackBar("Email Address is not valid");
    } else if (driverController.addressController.text.isEmpty) {
      authController.validSnackBar("Address is not empty");
    } else if (driverController.selectedVehicleNotifier.value == null) {
      authController.validSnackBar("Vehicle-type is not empty");
    }
    // else if (driverController.rcNumController.text.isEmpty) {
    //   authController.validSnackBar("RC-Number is not empty");
    // } else if (driverController.rcBookImg == null) {
    //   authController.validSnackBar("Upload RC book image");
    // } else if (driverController.vNumController.text.isEmpty) {
    //   authController.validSnackBar("Vehicle Number is not empty");
    // } else if (driverController.vehicleImages.length < 2) {
    //   authController.validSnackBar("Upload vehicle images image");
    // } else if (driverController.dLController.text.isEmpty) {
    //   authController.validSnackBar("DL-Number is not empty");
    // } else if (driverController.licenseImg == null) {
    //   authController.validSnackBar("Upload License image");
    // }
    else {
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
    await Future.delayed(Duration(seconds: 2));
    // setState(() {
    //   vehicle.vName = driverController.selectedVehicleNotifier.value;
    // });
    Navigator.pop(context);
    await Get.to(
      () => BankDetails(widget.countryCode, widget.phoneNumber),
    );
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

  Future<void> getMultipleImages(ImageSource source) async {
    try {
      final List<XFile>? pickedFiles =
          await driverController.picker.pickMultiImage();
      if (pickedFiles == null || pickedFiles.length < 2) return;

      setState(() {
        driverController.vehicleImages =
            pickedFiles.map((file) => File(file.path)).toList().sublist(0, 2);
      });
    } catch (e) {
      print('Error picking images: $e');
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

  void showMultipleImagePickerOptions() {
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
                  getMultipleImages(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  getMultipleImages(ImageSource.camera);
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

    // print("${widget.countryCode}${widget.phoneNumber}");
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register as a Driver",
          // style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      // backgroundColor: Colors.transparent,
      body: Container(
        padding: EdgeInsets.only(right: 20.0, left: 20.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Text(
              "Let's create your account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.nameController,
              "Enter Your Name",
              Icons.person_outline_sharp,
            ),
            const SizedBox(height: 20),
            formField(
              "Mobile",
              Icons.phone,
              sufIcon: Icons.edit,
              read: true,
              hint: widget.phoneNumber,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.emailController,
              "Email",
              Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.addressController,
              "Address",
              Icons.home_outlined,
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.cityController,
              "City",
              Icons.location_city_outlined,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: formField(
                    controller: driverController.stateController,
                    "State",
                    Icons.map_outlined,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: formField(
                    controller: driverController.pinCodeController,
                    "Pin Code",
                    Icons.pin_drop_outlined,
                    isNum: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String?>(
              valueListenable: driverController.selectedVehicleNotifier,
              builder: (context, selectedVehicle, child) {
                return CustomDropdownFormField(
                  hint: "Vehicle Type",
                  items: const [
                    'Atul Shakti',
                    'Eicher',
                    'Suzuki pickup',
                    'Bolero',
                    'Chhota Hathi',
                    'Auto Rickshaw',
                    'e-Rickshaw',
                    'e-Tempo',
                    'Activa',
                    'Bike',
                    'e-Bike'
                  ],
                  value: selectedVehicle,
                  onChanged: (String? newValue) {
                    driverController.selectedVehicleNotifier.value = newValue;
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            formField(
              controller: driverController.rcNumController,
              "RC-Number",
              Icons.numbers,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => showImagePickerOptions(
                  (file) => driverController.rcBookImg = file),
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload RC book Image',
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
            const SizedBox(height: 8),
            driverController.rcBookImg != null
                ? Column(
                    children: [
                      Container(
                        width: 150,
                        child: Image.file(
                          driverController.rcBookImg!,
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
                            driverController.rcBookImg = null;
                          });
                        },
                        child: Text('Remove Image'),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 20),
            formField(
              controller: driverController.vNumController,
              "Vehicle-Number",
              Icons.numbers,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: showMultipleImagePickerOptions,
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload Vehicle Image',
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
                "*Image should contain front and back side number plate",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
            driverController.vehicleImages.isNotEmpty
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: driverController.vehicleImages.map((file) {
                          return Column(
                            children: [
                              Container(
                                width: 150,
                                child: Image.file(
                                  file,
                                  height: 150,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            driverController.vehicleImages = List.empty();
                          });
                        },
                        child: Text('Remove Image'),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 10),
            formField(
              controller: driverController.dLController,
              "Driving License",
              Icons.directions_bike_sharp,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => showImagePickerOptions((file) {
                driverController.licenseImg = file;
              }),
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload Driving License Image',
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
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            driverController.licenseImg != null
                ? Column(
                    children: [
                      Container(
                        width: 150,
                        child: Image.file(
                          driverController.licenseImg!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                        ),
                        onPressed: () {
                          setState(() {
                            driverController.licenseImg = null;
                          });
                        },
                        child: Text('Remove Image'),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 10),
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
