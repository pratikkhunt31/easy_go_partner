import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../consts/firebase_consts.dart';
import '../home/home_view.dart';
import '../login/num_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changeScreen() {
    Future.delayed(Duration(seconds: 3), () {
      // Get.off(() => const NumberScreen());
      auth.authStateChanges().listen((User? user) {
        if (user == null && mounted) {
          Get.to(() => NumberScreen());
        }
        // else if (currentUser!.phoneNumber!.isEmpty){
        //   Get.offAll(() => HomeView());
        // }
        else {
          Get.to(() => HomeView());
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splash.gif',
          fit: BoxFit.cover,
          height: double.infinity,
        ),
      ),
    );
  }
}
