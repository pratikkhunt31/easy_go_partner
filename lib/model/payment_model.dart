import 'package:google_maps_flutter/google_maps_flutter.dart';

class Payment {
  final String rideId;
  final String amount;
  final String distance;
  final String time;
  final String payment;
  final bool isStarted;
  final String goods;
  final String paymentOrderId;
  final String paymentId;
  final String paymentStatus;
  final String status;

  Payment({
    required this.rideId,
    required this.amount,
    required this.distance,
    required this.time,
    required this.payment,
    required this.isStarted,
    required this.goods,
    required this.paymentOrderId,
    required this.paymentId,
    required this.paymentStatus,
    required this.status,
  });

  factory Payment.fromMap(String rideRequestId, Map<String, dynamic> data) {
    return Payment(
      rideId: rideRequestId,
      amount: data['payout'],
      distance: data['distance'],
      time: data['created_at'],
      payment: data['payment_status'],
      isStarted: data['is_started'],
      goods: data['goods'],
      paymentOrderId: data['paymentDetails']['orderId'],
      paymentId: data['paymentDetails']['paymentId'],
      paymentStatus: data['paymentDetails']['status'],
      status: data['status'],
    );
  }
}
