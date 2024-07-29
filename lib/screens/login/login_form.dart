import 'dart:io';
import 'dart:async';
import 'package:easy_go_partner/controller/driver_controller.dart';
import 'package:easy_go_partner/screens/login/bank_details.dart';
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
    }
    // else if (driverController.emailController.text.isEmpty) {
    //   authController.validSnackBar("Email Address is not empty");
    // } else if (!driverController.emailController.text.contains("@gmail.com")) {
    //   authController.validSnackBar("Email Address is not valid");
    // } else if (driverController.addressController.text.isEmpty) {
    //   authController.validSnackBar("Address is not empty");
    // } else if (driverController.selectedVehicleNotifier.value == null) {
    //   authController.validSnackBar("Vehicle-type is not empty");
    // } else if (driverController.rcNumController.text.isEmpty) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register as a Driver",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              "Let's create your account",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              controller: driverController.nameController,
              "Enter Your Name",
              Icons.person_outline_sharp,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              "Mobile",
              Icons.phone,
              sufIcon: Icons.edit,
              read: true,
              hint: widget.phoneNumber,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              controller: driverController.emailController,
              "Email",
              Icons.email_outlined,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              controller: driverController.addressController,
              "Address",
              Icons.home_outlined,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              controller: driverController.cityController,
              "City",
              Icons.location_city_outlined,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                  ],
                  value: selectedVehicle,
                  onChanged: (String? newValue) {
                    driverController.selectedVehicleNotifier.value = newValue;
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            formField(
              controller: driverController.rcNumController,
              "RC-Number",
              Icons.numbers,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            OutlinedButton.icon(
              onPressed: () => showImagePickerOptions(
                      (file) => driverController.rcBookImg = file),
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload RC book Image',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
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
                  EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            driverController.rcBookImg != null
                ? Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Image.file(
                    driverController.rcBookImg!,
                    height: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                  child: Text(
                    'Remove Image',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
              ],
            )
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            formField(
              controller: driverController.vNumController,
              "Vehicle-Number",
              Icons.numbers,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            OutlinedButton.icon(
              onPressed: showMultipleImagePickerOptions,
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload Vehicle Image',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
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
                  EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "*Image should contain front and back side number plate",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            driverController.vehicleImages.isNotEmpty
                ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: driverController.vehicleImages.map((file) {
                    return Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Image.file(
                            file,
                            height: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                  child: Text(
                    'Remove Image',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
              ],
            )
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            formField(
              controller: driverController.dLController,
              "Driving License",
              Icons.directions_bike_sharp,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            OutlinedButton.icon(
              onPressed: () => showImagePickerOptions((file) {
                driverController.licenseImg = file;
              }),
              icon: Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                'Upload Driving License Image',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
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
                  EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            driverController.licenseImg != null
                ? Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Image.file(
                    driverController.licenseImg!,
                    height: MediaQuery.of(context).size.width * 0.4,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                  child: Text(
                    'Remove Image',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                    ),
                  ),
                ),
              ],
            )
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                hint: "Continue",
                onPress: () {
                  validate();
                },
                borderRadius: BorderRadius.circular(5.0),
                color: const Color(0xFF0000FF),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
      ),
    );
  }

}
