import 'package:easy_go_partner/consts/firebase_consts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/driver_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DriverController driverController = Get.put(DriverController());

  @override
  void initState() {
    super.initState();
    driverController.getRideRequests("tempo"); // Pass the correct vehicle type
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Request"),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Obx(() {
        if (driverController.rideRequests.isEmpty) {
          return Column(
            children: [
              Center(child: Text("No ride requests available.")),
              // ElevatedButton(onPressed: () {driverController.getRideRequests("tempo");}, child: Text("Test"))
            ],
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
                      leading: Image.asset('assets/images/truck2.png', width: 50, height: 50),
                      title: Text(rideRequest['created_at']),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                    const Divider(height: 1.0, thickness: 1.0),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Text("To: "),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(rideRequest['dropOff_address']),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Text("User Details: "),
                          SizedBox(width: 5),
                          Text("${rideRequest['rider_name']}, ${rideRequest['rider_phone']}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          // Add accept request logic here
                          acceptRideRequest(rideRequest['rideRequestId']);
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
      }),
    );
  }

  void acceptRideRequest(String rideRequestId) {
    // Update the ride request status to accepted by this driver
    DatabaseReference rideRequestRef = FirebaseDatabase.instance.ref().child('Ride Request').child(rideRequestId);
    rideRequestRef.update({'driver_id': currentUser!.uid}); // Replace with the actual driver ID
  }
}
