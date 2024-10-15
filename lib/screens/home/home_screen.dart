import 'dart:async';
import 'package:easy_go_partner/consts/firebase_consts.dart';
import 'package:easy_go_partner/ride/request_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart' as per;
import '../../assistants/assistantsMethod.dart';
import '../../controller/driver_controller.dart';
import '../../dataHandler/appData.dart';
import '../../plugin/location_service_plugin.dart';
import '../../widget/custom_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DriverController driverController = Get.put(DriverController());
  TextEditingController currentLocController = TextEditingController();
  DatabaseReference database = FirebaseDatabase.instance.ref();
  AppData appData = Get.put(AppData());

  bool isOnline = true;
  bool isVerified = false;
  bool isLoading = true;
  GoogleMapController? newMapController;
  geo.Position? currentLocation;
  StreamSubscription<DatabaseEvent>? verificationStatusSubscription;
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      String? vType = await getVehicleType();
      driverController.getRideRequests(vType);
    });
    loadUserData();
    fetchDriverVerificationStatus();
    checkLocationPermission();
    checkNotificationPermission();
    updateFcmToken();

    isVerified =
        false; // Initialize with false until verification status is fetched
    isLoading = true;
    // if (isOnline) {
    //   startLocationUpdates();
    // }
    updateDriverLocationForAllPendingRides();
  }

  @override
  void dispose() {
    verificationStatusSubscription?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }

  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request location permissions if not granted or permanently denied
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle the case where the user denies or permanently denies permission
        validSnackBar('You have to enable location permission');
      } else {
        // locatePosition();
      }
    } else {
      // locatePosition();
    }
  }

  void checkNotificationPermission() async {
    per.PermissionStatus permission = await per.Permission.notification.status;
    if (permission.isDenied || permission.isPermanentlyDenied) {
      // Request notification permissions if not granted or permanently denied
      permission = await per.Permission.notification.request();

      if (permission.isGranted) {
        // Permission granted
        validSnackBar('Notification permission granted.');
      } else {
        // Handle the case where the user denies or permanently denies permission
        validSnackBar('You have to enable notification permission.');
      }
    } else {}
  }

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        showUpdateDialog();
      }
    } catch (e) {
      // Handle the error appropriately, if needed
      // showErrorSnackBar('Failed to check for updates. Please try again later.');
    }
  }

  Future<void> performUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      await InAppUpdate.completeFlexibleUpdate();
      showSuccessSnackBar('App updated successfully.');
    } catch (e) {
      showErrorSnackBar('Failed to update the app. Please try again later.');
    }
  }

  void showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Available'),
          content: Text(
              'A new version of the app is available. Please update to continue using the app.'),
          actions: <Widget>[
            TextButton(
              child: Text('Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                Navigator.of(context).pop();
                performUpdate();
              },
            ),
          ],
        );
      },
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> updateFcmToken() async {
    try {
      if (currentUser != null) {
        FirebaseMessaging fMessaging = FirebaseMessaging.instance;
        final fCMToken = await fMessaging.getToken();

        DatabaseReference database = FirebaseDatabase.instance.ref();
        await database
            .child('drivers')
            .child(currentUser!.uid)
            .update({'driver_token': fCMToken});
      } else {
        // print("User is not logged in");
      }
    } catch (e) {
      print("Failed to update FCM token: $e");
    }
  }

  Future<String?> getVehicleType() async {
    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentUser!.uid);

    DataSnapshot snapshot = await driverRef.get();

    if (snapshot.value != null) {
      // Extract the vehicleType from the snapshot
      Map<String, dynamic> driverData =
          Map<String, dynamic>.from(snapshot.value as Map);
      return driverData['vehicleType'] as String?;
    } else {
      return null;
    }
  }

  Future<void> fetchDriverVerificationStatus() async {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(currentUser!.uid);

      verificationStatusSubscription =
          userRef.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          bool verified =
              userData['is_verified'] ?? false; // Default to false if not found
          if (mounted) {
            setState(() {
              isVerified = verified;
              isLoading = false;
            });
          }
        }
      });
    }
  }

  Future<void> loadUserData() async {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(currentUser!.uid);
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        if (mounted) {
          setState(() {
            isOnline = userData['is_online'];
            // nameController.text = userData['name'];
            // isLoading = false;
          });
        }
      }
    }
  }

  void updateOnlineStatus(bool status) {
    if (currentUser != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('drivers')
          .child(currentUser!.uid);
      userRef.update({'is_online': status});
      setState(() {
        isOnline = status;
      });
    }
  }

  void showOfflineConfirmation() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Are you sure you want to go offline?'),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('Yes'),
              onTap: () {
                Navigator.pop(context);
                updateOnlineStatus(false);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('No'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> locatePosition() async {
    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          currentLocation = position;
        });
      }

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition,
        zoom: 18,
      );

      await newMapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );

      String address = await AssistantsMethod.searchCurrentAddress(position);

      if (mounted) {
        setState(() {
          currentLocController.text = address;
        });
      }
    } catch (e) {
      // Handle any errors that occur during location fetching
      validSnackBar('Error fetching location: $e');
      throw e; // Re-throw the error to propagate it further if needed
    }
  }

  void startLocationUpdates() {
    locationSubscription?.cancel(); // Cancel any existing subscription
    Location location = Location();
    locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      updateDriverLocationForAllPendingRides();
    });
    if (!mounted) {
      location.enableBackgroundMode(enable: true);
    }
  }

  void updateDriverLocationForAllPendingRides() async {
    if (currentUser == null) {
      print("User is not logged in");
      return;
    }

    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child('Ride Request');

    // Fetch all ride requests where driver_id is equal to currentUserId and status is 'pending'
    rideRequestRef
        .orderByChild('driver_id')
        .equalTo(currentUser!.uid)
        .once()
        .then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<String, dynamic> rides =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        rides.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          if (rideData['status'] == 'pending') {
            LocationServicePlugin.startLocationService(key);
          }
        });
      } else {
        // print('No pending rides found for the current user.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double screenHeight = constraints.maxHeight;
        double iconSize = screenWidth * 0.14;
        double fontSize = screenWidth * 0.04;

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Ride Request"),
              backgroundColor: const Color(0xFF0000FF),
              elevation: 0,
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0000FF),
              ),
            ),
          );
        }
        if (!isVerified) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Ride Request"),
              backgroundColor: const Color(0xFF0000FF),
              elevation: 0,
              actions: [
                Switch(
                  value: isOnline,
                  onChanged: (value) {},
                  activeColor: Colors.green,
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_red_eye_sharp, size: iconSize),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Your application is under review",
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: isVerified
              ? AppBar(
                  title: const Text("Ride Request"),
                  backgroundColor: const Color(0xFF0000FF),
                  elevation: 0,
                  actions: [
                    Switch(
                      value: isOnline,
                      onChanged: (value) {
                        if (value) {
                          updateOnlineStatus(true);
                        } else {
                          showOfflineConfirmation();
                        }
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                )
              : AppBar(
                  title: const Text("Ride Request"),
                  backgroundColor: const Color(0xFF0000FF),
                  elevation: 0,
                ),
          body: isOnline
              ? Obx(() {
                  if (driverController.rideRequests.isEmpty) {
                    return FutureBuilder(
                      future: Future.delayed(Duration(seconds: 1)),
                      // Simulate a short loading period
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: Color(0xFF0000FF),
                          ));
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: iconSize),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  "No Request Available",
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  }
                  return ListView.builder(
                    itemCount: driverController.rideRequests.length,
                    itemBuilder: (context, index) {
                      var rideRequest = driverController.rideRequests[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: RequestDetail(data: rideRequest),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: Image.asset(
                                    'assets/images/truck2.png',
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  title: Text(
                                    rideRequest['created_at'],
                                    style: TextStyle(fontSize: fontSize),
                                  ),
                                  trailing: Text(
                                    rideRequest['payout'],
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      color: Color(0xFF0000FF),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1.0, thickness: 1.0),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  child: Row(
                                    children: [
                                      Text(
                                        "From: ",
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Expanded(
                                        child: Text(
                                          rideRequest['pickUp_address'],
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  child: Row(
                                    children: [
                                      Text(
                                        "To: ",
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                      SizedBox(width: screenWidth * 0.06),
                                      Expanded(
                                        child: Text(
                                          rideRequest['dropOff_address'],
                                          style: TextStyle(fontSize: fontSize),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () async {
                                      // Add accept request logic here
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return ProgressDialog(
                                              message: "Request Accepting");
                                        },
                                      );
                                      try {
                                        await locatePosition();
                                        acceptRideRequest(
                                            rideRequest['rideRequestId']);
                                        Navigator.pop(
                                            context); // Close the progress dialog
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Request accepted'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        Navigator.pop(
                                            context); // Close the progress dialog
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Try again'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                })
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off_sharp, size: iconSize),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "You're offline",
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> acceptRideRequest(String rideRequestId) async {
    var pickUp = appData.currentLocation;
    FirebaseMessaging fMessaging = FirebaseMessaging.instance;

    Map<String, String> currentLocMap = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString()
    };

    final fCMToken = await fMessaging.getToken();

    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child('Ride Request')
        .child(rideRequestId);
    await rideRequestRef.update({
      'd_address': currentLocController.text,
      'd_location': currentLocMap,
      'driver_id': currentUser!.uid,
      'driver_token': fCMToken,
    });

    updateDriverLocation(rideRequestId);
  }

  void updateDriverLocation(String rideRequestId) {
    Location location = Location();

    location.onLocationChanged.listen((LocationData currentLocation) {
      DatabaseReference rideRequestRef = FirebaseDatabase.instance
          .ref()
          .child('Ride Request')
          .child(rideRequestId); // Ensure you have the rideRequestId

      rideRequestRef.update({
        'd_location': {
          'latitude': currentLocation.latitude.toString(),
          'longitude': currentLocation.longitude.toString(),
        },
      });
    });
  }
}

// DatabaseReference rideRequestRef = FirebaseDatabase.instance
//     .ref()
//     .child('Ride Request')
//     .child(key);
//
// rideRequestRef.update({
// 'd_location': {
// 'latitude': currentLocation.latitude.toString(),
// 'longitude': currentLocation.longitude.toString(),
// },
// });
// print(rideRequestRef.key);
