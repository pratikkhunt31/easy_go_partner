import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import '../../consts/firebase_consts.dart';
import '../../model/payment_model.dart';
import '../../widget/custom_widget.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
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
          }
        });
      } else {
        // print('No pending rides found for the current user.');
      }
    });
  }

  Stream<List<Payment>> getPaymentDetails() async* {
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
        List<Payment> filteredRides = [];

        rides.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          if (rideData['paymentDetails'] != null &&
              rideData['paymentDetails']['status'] == 'success') {
            filteredRides.add(Payment.fromMap(key, rideData));
          }
        });

        return filteredRides;
      } else {
        print('No rides found for the current user.');
        return [];
      }
    });
  }

  void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Once the payment status is successful, the payment will be credited to your bank account within 24 to 48 hours.',
              ),
              SizedBox(height: 10),
              Text(
                'If you have any queries, please contact us.',
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF0000FF)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        elevation: 0,
        backgroundColor: const Color(0xFF0000FF),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Information',
            onPressed: () {
              showInfoDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Payment>>(
        stream: getPaymentDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0000FF),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('There is no any Payments.'));
          }
          List<Payment> payments = snapshot.data!;
          // List<Ride> rides = snapshot.data!;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 3,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CustomExpansionTile(
                      leading: Icon(Icons.account_balance_wallet,
                          color: Color(0xFF0000FF)),
                      expandedTitleColor: Color(0xFF0000FF),
                      title: 'Order ID: ${payment.paymentOrderId}',
                      children: [
                        ListTile(
                          title: Text('Payout: ${payment.amount}'),
                          subtitle: Text('Payment ID: ${payment.paymentId}'),
                          trailing: Text(
                            'Status: ${payment.paymentStatus}',
                            style: TextStyle(
                              color: payment.paymentStatus == 'success'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final List<Widget> children;
  final Color expandedTitleColor;

  CustomExpansionTile({
    required this.leading,
    required this.title,
    required this.children,
    required this.expandedTitleColor,
  });

  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: widget.leading,
      title: Text(
        widget.title,
        style: TextStyle(
          color: _isExpanded ? widget.expandedTitleColor : Colors.black,
        ),
      ),
      children: widget.children,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
    );
  }
}
