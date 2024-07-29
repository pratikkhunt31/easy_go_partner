import 'dart:async';

import 'package:easy_go_partner/consts/firebase_consts.dart';
import 'package:easy_go_partner/ride/pending_ride_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';

import '../../model/ride_model.dart';
import '../../widget/custom_widget.dart';

class Pending extends StatefulWidget {
  const Pending({super.key});

  @override
  State<Pending> createState() => _PendingState();
}

class _PendingState extends State<Pending> {

  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    // Call the method to check and request location permissions
    checkLocationPermission();
    startLocationUpdates();
  }

  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        validSnackBar('You have to enable location permission');
      } else {
        // locatePosition();
      }
    } else {
      // locatePosition();
    }
  }

  void startLocationUpdates() {
    locationSubscription?.cancel(); // Cancel any existing subscription
    Location location = Location();
    locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
          updateDriverLocationForAllPendingRides(currentLocation);
        });
    if (!mounted) {
      location.enableBackgroundMode(enable: true);
    }
  }

  void updateDriverLocationForAllPendingRides(LocationData currentLocation) async {
    if (currentUser == null) {
      print("User is not logged in");
      return;
    }

    DatabaseReference rideRequestRef =
    FirebaseDatabase.instance.ref().child('Ride Request');

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

  Stream<List<Ride>> getPendingRides() async* {
      if (currentUser == null) {
        print("User is not logged in");
        yield [];
        return;
      }

      DatabaseReference rideRequestRef =
          FirebaseDatabase.instance.ref().child('Ride Request');

      yield* rideRequestRef
          .orderByChild('driver_id')
          .equalTo(currentUser!.uid)
          .onValue
          .map((event) {
        if (event.snapshot.exists) {
          Map<String, dynamic> rides =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          List<Ride> filteredRides = [];

          rides.forEach((key, value) {
            Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
            if (rideData['status'] == 'pending') {
              filteredRides.add(Ride.fromMap(key, rideData));
            }
          });
          filteredRides.sort((a, b) {
            DateTime createdAtA = DateFormat('dd-MM-yyyy HH:mm:ss').parse(a.createdAt);
            DateTime createdAtB = DateFormat('dd-MM-yyyy HH:mm:ss').parse(b.createdAt);
            return createdAtB.compareTo(createdAtA); // Sort in descending order
          });
          return filteredRides;
        } else {
          print('No rides found for the current user.');
          return [];
        }
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: StreamBuilder<List<Ride>>(
        stream: getPendingRides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Color(0xFF0000FF),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('There is no pending request.'));
          }

          List<Ride> rides = snapshot.data!;

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              Ride ride = rides[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Image.asset('assets/images/truck2.png',
                            width: 50, height: 50),
                        title: Text(ride.time),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF0000FF),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: PendingRideDetails(ride: ride),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        height: 1.0,
                        thickness: 1.0,
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Text("From:-"),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(ride.pickUpAddress),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Text("To:-"),
                            SizedBox(width: 22),
                            Expanded(
                              child: Text(ride.dropOffAddress),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Padding(
                      //   padding:
                      //   const EdgeInsets.symmetric(horizontal: 25.0),
                      //   child: Row(
                      //     children: const [
                      //       SizedBox(height: 20),
                      //       Text(
                      //         "Driver Details:-",
                      //         style:
                      //         TextStyle(fontWeight: FontWeight.bold),
                      //       ),
                      //       SizedBox(width: 5),
                      //       Text("Name, Mobile Number"),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 5),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Column(
// children: [
// Padding(
// padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
// child: Card(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// ListTile(
// leading: SvgPicture.asset(
// 'assets/images/truck.svg',
// width: 50, height: 50),
// title: const Text('Date and Time'),
// trailing: const Text('\$1000'),
// ),
// const Divider(
// height: 1.0,
// thickness: 1.0,
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Pick up Address Pick up Address Pick up Address"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 8),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Drop Location Drop Location Drop Location Drop Location"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// SizedBox(height: 20),
// Text(
// "Driver Details:-",
// style:
// TextStyle(fontWeight: FontWeight.bold),
// ),
// SizedBox(width: 5),
// Text("Name, Mobile Number"),
// ],
// ),
// ),
// const SizedBox(height: 5),
// ],
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
// child: Card(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// ListTile(
// leading: Image.asset('assets/images/truck2.png',
// width: 50, height: 50),
// title: const Text('Date and Time'),
// trailing: const Text('\$1000'),
// ),
// const Divider(
// height: 1.0,
// thickness: 1.0,
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Pick up Address Pick up Address Pick up Address"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 8),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Drop Location Drop Location Drop Location Drop Location"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// SizedBox(height: 20),
// Text(
// "Driver Details:-",
// style:
// TextStyle(fontWeight: FontWeight.bold),
// ),
// SizedBox(width: 5),
// Text("Name, Mobile Number"),
// ],
// ),
// ),
// const SizedBox(height: 5),
// ],
// ),
// ),
// ),
// Padding(
// padding: const EdgeInsets.only(top: 8.0, left: 5, right: 5),
// child: Card(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// ListTile(
// leading: SvgPicture.asset(
// 'assets/truck.svg',
// width: 50, height: 50),
// title: const Text('Date and Time'),
// trailing: const Text('\$1000'),
// ),
// const Divider(
// height: 1.0,
// thickness: 1.0,
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Pick up Address Pick up Address Pick up Address"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 8),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// Text("From:-"),
// SizedBox(width: 5),
// Expanded(
// child: Text(
// "Drop Location Drop Location Drop Location Drop Location"),
// ),
// ],
// ),
// ),
// const SizedBox(height: 5),
// Padding(
// padding:
// const EdgeInsets.symmetric(horizontal: 25.0),
// child: Row(
// children: const [
// SizedBox(height: 20),
// Text(
// "Driver Details:-",
// style:
// TextStyle(fontWeight: FontWeight.bold),
// ),
// SizedBox(width: 5),
// Text("Name, Mobile Number"),
// ],
// ),
// ),
// const SizedBox(height: 5),
// ],
// ),
// ),
// ),
// ],
// )
