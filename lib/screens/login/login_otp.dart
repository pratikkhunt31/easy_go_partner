import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../controller/auth_controller.dart';
import '../../widget/custom_widget.dart';
import '../home/home_view.dart';
import 'login_form.dart';

class LoginOtp extends StatefulWidget {
  final String phoneNumber;
  // final String countryCode;

  const LoginOtp(this.phoneNumber, {Key? key}) : super(key: key);

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  String? otpCode;
  TextEditingController otpController = TextEditingController();
  AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController.phoneAuth(widget.phoneNumber);
    // print("+${selectedCountry.phoneCode + widget..text.trim()}");
  }

  void checkUserDataAndNavigate() async {
    bool userDataExists =
        await authController.checkUserDataExists(widget.phoneNumber.trim());
    if (userDataExists) {
      // User data exists, navigate to OTP screen
      // Get.offAll(() => HomeView());
      print("Exist");
    } else {
      // User data doesn't exist, navigate to login form
      // Get.offAll(() => LoginForm(widget.phoneNumber));
      print("Not Exist");
    }
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
                      'assets/images/number.jpg',
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
                              // showProgressDialog(context);
                              try {
                                await authController.verifyOtp(otpCode!);
                                // await authController.saveUserInfo(widget.name!, widget.email!, widget.phoneNumber);
                                // hideProgressDialog(context);
                                authController.successSnackBar(
                                    "OTP verified successfully");
                                checkUserDataAndNavigate();
                              } catch (e) {
                                // hideProgressDialog(context);
                                // If verification fails, show error message
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
                      color: Colors.black38,
                    ),
                  ),
                  // const SizedBox(height: 15),
                  const Text(
                    "Resend New Code",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0000FF),
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
