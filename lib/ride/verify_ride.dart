import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controller/auth_controller.dart';
import '../../widget/custom_widget.dart';

class VerifyRideOtp extends StatefulWidget {
  final String phoneNumber;
  final String rideId;

  // final String countryCode;

  const VerifyRideOtp(this.phoneNumber, this.rideId, {Key? key}) : super(key: key);

  @override
  State<VerifyRideOtp> createState() => _VerifyRideOtpState();
}

class _VerifyRideOtpState extends State<VerifyRideOtp> {
  String? otpCode;
  TextEditingController otpController = TextEditingController();
  AuthController authController = Get.put(AuthController());
  bool isResendButtonEnabled = false;
  int start = 60;
  late Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.rideAuth(widget.phoneNumber);
    log(widget.phoneNumber);
    // print("+${selectedCountry.phoneCode + widget..text.trim()}");
    startTimer();
  }

  void startTimer() {
    start = 60;
    isResendButtonEnabled = false;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (start <= 1) {
          timer.cancel();
          isResendButtonEnabled = true;
        } else {
          start--;
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> completeRide() async {
    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child('Ride Request')
        .child(widget.rideId);
    await rideRequestRef.update({
      'status': "complete",
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // var otpController;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth *
                    0.1, // 10% of screen width as horizontal padding
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.3,
                    // 30% of screen height for image
                    child: Image.asset(
                      'assets/images/otp.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Verification",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter the OTP sent to your phone number",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // const Pinput(
                  //   length: 6,
                  //   showCursor: true,
                  //   // defaultPinTheme: ,
                  //   // controller: otpController,
                  // ),
                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0000FF),
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        otpCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CustomButton(
                      hint: "Verify",
                      color: otpCode.toString().length.isEqual(6)
                          ? const Color(0xFF0000FF)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(25.0),
                      onPress: otpCode.toString().length.isEqual(6)
                          ? () async {
                        try {
                          await authController.verifyOtp(otpCode!);
                          await completeRide();
                          Get.snackbar(
                            "Success",
                            "Ride completed",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          Navigator.pop(context);
                          Navigator.pop(context);
                          // Get.offAll(() => HomeView());
                        } catch (e) {
                          authController.error("Error verifying OTP", e);
                        }
                      }
                          : () {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Didn't receive any code?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // const SizedBox(height: 15),
                  // const Text(
                  //   "Resend New Code",
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xFF0000FF),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: isResendButtonEnabled
                        ? () async {
                      int retryCount = 0;
                      const int maxRetries = 3;

                      while (retryCount < maxRetries) {
                        try {
                          await authController
                              .rideAuth(widget.phoneNumber);
                          startTimer();
                          break; // Exit the loop if successful
                        } catch (e) {
                          if (e is FirebaseException &&
                              e.message == 'Too many attempts') {
                            retryCount++;
                            if (retryCount >= maxRetries) {
                              print(
                                  "Too many attempts. Please try again later.");
                              break;
                            }
                            await Future.delayed(Duration(
                                seconds: 2 *
                                    retryCount)); // Exponential backoff
                          } else {
                            print("Error: $e");
                            break;
                          }
                        }
                      }
                    }
                        : null,
                    child: Text(
                      isResendButtonEnabled
                          ? "Resend New Code"
                          : "Resend Code in $start seconds",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isResendButtonEnabled
                            ? Color(0xFF0000FF)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
