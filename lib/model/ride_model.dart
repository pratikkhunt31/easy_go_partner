import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ride {
  final String rideId;
  final String dropOffAddress;
  final String pickUpAddress;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String amount;
  final String distance;
  final String time;
  final String payment;
  final bool isStarted;
  final LatLng pickUpLatLng;
  final LatLng dropOffLatLng;
  final String goods;

  Ride(
      {required this.rideId,
      required this.dropOffAddress,
      required this.pickUpAddress,
      required this.senderName,
      required this.senderPhone,
      required this.receiverName,
      required this.receiverPhone,
      required this.amount,
      required this.distance,
      required this.time,
        required this.payment,
      required this.isStarted,
      required this.pickUpLatLng,
      required this.dropOffLatLng,
      required this.goods});

  factory Ride.fromMap(String rideRequestId, Map<String, dynamic> data) {
    return Ride(
      rideId: rideRequestId,
      dropOffAddress: data['dropOff_address'],
      pickUpAddress: data['pickUp_address'],
      senderName: data['sender_name'],
      senderPhone: data['sender_phone'],
      receiverName: data['receiver_name'],
      receiverPhone: data['receiver_phone'],
      amount: data['payout'],
      distance: data['distance'],
      time: data['created_at'],
      payment: data['payment_status'],
      isStarted: data['is_started'],
      pickUpLatLng: LatLng(
        double.parse(data['pickUp']['latitude']),
        double.parse(data['pickUp']['longitude']),
      ),
      dropOffLatLng: LatLng(
        double.parse(data['dropOff']['latitude']),
        double.parse(data['dropOff']['longitude']),
      ),
      goods: data['goods'],
    );
  }
}

class Payment {
  final String paymentStatus;
  final String orderId;
  final String paymentId;
  final String status;

  Payment(
      {required this.paymentStatus,
      required this.orderId,
      required this.paymentId,
      required this.status});

  factory Payment.fromMap(Map<String, dynamic> data) {
    return Payment(
      paymentStatus: data['payment_status'],
      orderId: data['paymentDetails']['orderId'],
      paymentId: data['paymentDetails']['paymentId'],
      status: data['paymentDetails']['status'],
    );
  }
}
