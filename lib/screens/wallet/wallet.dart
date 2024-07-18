import 'dart:developer';

import 'package:easy_go_partner/model/ride_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../consts/firebase_consts.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  List<Map<String, dynamic>> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  void fetchPayments() async {
    if (currentUser == null) return;
    final DatabaseReference rideRequestRef =
    FirebaseDatabase.instance.ref().child('Ride request');

    rideRequestRef
        .orderByChild('driver_id')
        .equalTo(currentUser!.uid)
        .once()
        .then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<String, dynamic>> payments = [];
        data.forEach((key, value) {
          if (value['payment_status'] == 'complete' &&
              value['paymentDetails']['status'] == 'success') {
            payments.add({
              'orderId': value['paymentDetails']['orderId'],
              'paymentId': value['paymentDetails']['paymentId'],
              'payout': value['payout'],
            });
          }
        });
        setState(() {
          payments = payments;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
    ;
  }

  Stream<List<Payment>> getPaymentStream() async* {
    if (currentUser == null) {
      print("User is not logged in");
      yield [];
      return;
    }

    DatabaseReference rideRequestRef =
        FirebaseDatabase.instance.ref().child('Ride request');

    yield* rideRequestRef
        .orderByChild('driver_id')
        .equalTo(currentUser!.uid)
        .onValue
        .map((event) {
      if (event.snapshot.exists) {
        Map<String, dynamic> rides =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        List<Payment> filteredPayments = [];

        rides.forEach((key, value) {
          Map<String, dynamic> rideData = Map<String, dynamic>.from(value);
          if (rideData['payment_status'] == 'complete') {
            // filteredPayments.add({
            //   'Hii':rideData['payment_status'] == 'complete',
            //   // 'orderId': rideData['paymentDetails']['orderId'],
            //   // 'paymentId': rideData['paymentDetails']['paymentId'],
            //   // 'payout': rideData['payout'],
            // });
            filteredPayments.add(Payment.fromMap(rideData));
          }
        });

        return filteredPayments;
      } else {
        print('No payments found for the current user.');
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        elevation: 0,
        backgroundColor: const Color(0xFF0000FF),
      ),
      body: StreamBuilder<List<Payment>>(
        stream: getPaymentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0000FF),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 60, color: Colors.grey),
                  SizedBox(height: 5),
                  Text('No data available',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return ExpansionTile(
                leading: Icon(Icons.account_balance_wallet),
                title: Text('Order ID: ${payment.orderId}'),
                children: [
                  ListTile(
                    title: Text('Order ID: ${payment.orderId}'),
                    subtitle: Text('Payment ID: ${payment.paymentId}'),
                    trailing: Text('Payout: ${payment.paymentStatus}'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
