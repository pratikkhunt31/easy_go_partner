import 'package:easy_go_partner/controller/notification.dart';
import 'package:easy_go_partner/firebase_options.dart';
import 'package:easy_go_partner/plugin/location_service_plugin.dart';
import 'package:easy_go_partner/screens/home/home_view.dart';
import 'package:easy_go_partner/screens/login/num_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'controller/driver_controller.dart';
import 'network_dependency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  await NotificationService().initNotification();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Get.put(DriverController());
  runApp(const MyApp());
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthRedirect(),
    );
  }
}

class AuthRedirect extends StatefulWidget {
  @override
  _AuthRedirectState createState() => _AuthRedirectState();
}

class _AuthRedirectState extends State<AuthRedirect> {
  @override
  void initState() {
    super.initState();
    changeScreen();

    // TODO: remove this test code
    // if (kDebugMode) {
    //   debugPrint("Starting location service");
    //   LocationServicePlugin.startLocationService("-O11ON1TnX_lNENmOpZV");

    //   Future.delayed(Duration(seconds: 10), () async {
    //     debugPrint("Is Location Service Running: " +
    //         (await LocationServicePlugin.checkServiceRunning()).toString());
    //   });

    //   Future.delayed(Duration(seconds: 30), () {
    //     LocationServicePlugin.stopLocationService();
    //   });

    //   Future.delayed(Duration(seconds: 32), () async {
    //     debugPrint("Is Location Service Running: " +
    //         (await LocationServicePlugin.checkServiceRunning()).toString());
    //   });
    // }
  }

  void changeScreen() {
    Future.delayed(Duration(seconds: 2), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null && mounted) {
          Get.to(() => NumberScreen());
        } else {
          Get.off(() => HomeView());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Ensure the column takes only the space it needs
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              child: LoadingIndicator(
                indicatorType: Indicator.ballClipRotateMultiple,
                colors: [Color(0xFF0000FF)],
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
