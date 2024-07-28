import 'dart:async';
import 'package:easy_go_partner/consts/firebase_consts.dart';
import 'package:easy_go_partner/ride/request_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import '../../assistants/assistantsMethod.dart';
import '../../controller/driver_controller.dart';
import '../../dataHandler/appData.dart';
import '../../widget/custom_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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

  // StreamSubscription<DatabaseEvent>? onlineStatusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      String? vType = await getVehicleType();
      driverController.getRideRequests(vType);
    });
    loadUserData();
    fetchDriverVerificationStatus();
    isVerified =
        false; // Initialize with false until verification status is fetched
    isLoading = true;

    if (isOnline) {
      startLocationUpdates();
    }

  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    verificationStatusSubscription?.cancel();
    // stopForegroundService();
    locationSubscription?.cancel();
    super.dispose();
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

      setState(() {
        currentLocation = position;
      });

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition,
        zoom: 18,
      );

      await newMapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );

      String address = await AssistantsMethod.searchCurrentAddress(position);

      setState(() {
        currentLocController.text = address;
      });

      // appData.updateDropOffLocationAddress(Address(
      //   placeName: address,
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      // ));
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
      updateDriverLocationForAllPendingRides(currentLocation);
    });
    location.enableBackgroundMode(enable: true);
  }

  //
  void updateDriverLocationForAllPendingRides(
      LocationData currentLocation) async {
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
            DatabaseReference rideRequestRef = FirebaseDatabase.instance
                .ref()
                .child('Ride Request')
                .child(key);

            rideRequestRef.update({
              'd_location': {
                'latitude': currentLocation.latitude.toString(),
                'longitude': currentLocation.longitude.toString(),
              },
            });
            // print(rideRequestRef.key);
          }
        });
      } else {
        // print('No pending rides found for the current user.');
      }
    });
  }

  // void updateDriverLocationInBackground(LocationData location) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? rideRequestId = prefs.getString('rideRequestId');
  //
  //   if (rideRequestId != null) {
  //     DatabaseReference rideRequestRef = FirebaseDatabase.instance
  //         .ref()
  //         .child('Ride Request')
  //         .child(rideRequestId);
  //
  //     rideRequestRef.update({
  //       'd_location': {
  //         'latitude': location.latitude.toString(),
  //         'longitude': location.longitude.toString(),
  //       },
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.remove_red_eye_sharp, size: 50),
              SizedBox(height: 10),
              Text("Your application is under review"),
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Color(0xFF0000FF),
                        ));
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 50),
                              SizedBox(height: 20),
                              Text("No Request Available"),
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
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Image.asset('assets/images/truck2.png',
                                  width: 50, height: 50),
                              title: Text(rideRequest['created_at']),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF0000FF),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      child: RequestDetail(data: rideRequest),
                                      type: PageTransitionType.bottomToTop,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(height: 1.0, thickness: 1.0),
                            const SizedBox(height: 5),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                children: [
                                  Text("From: "),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(rideRequest['pickUp_address']),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                children: [
                                  Text("To: "),
                                  SizedBox(width: 22),
                                  Expanded(
                                    child: Text(rideRequest['dropOff_address']),
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Request accepted'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    Navigator.pop(
                                        context); // Close the progress dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Try again'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text("Accept"),
                              ),
                            ),
                          ],
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
                    Icon(Icons.cloud_off_sharp, size: 50),
                    SizedBox(height: 10),
                    Text("You're offline"),
                  ],
                ),
              )
        // : Center(
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Icon(Icons.remove_red_eye_sharp, size: 50),
        //         SizedBox(height: 10),
        //         Text("Your application is under review"),
        //       ],
        //     ),
        //   ),
        );
  }

  Future<void> acceptRideRequest(String rideRequestId) async {
    var pickUp = appData.currentLocation;
    Map<String, String> currentLocMap = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString()
    };

    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child('Ride Request')
        .child(rideRequestId);
    await rideRequestRef.update({
      'd_address': currentLocController.text,
      'd_location': currentLocMap,
      'driver_id': currentUser!.uid,
    });

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('rideRequestId', rideRequestId);

    // FlutterForegroundTask.startService(
    //   notificationTitle: "Tracking Driver Location",
    //   notificationText: "Your location is being tracked for the ride request.",
    // );
    updateDriverLocation(rideRequestId);
    // startLocationUpdates();
    // bg.BackgroundGeolocation.start();
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

