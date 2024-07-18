import 'dart:async';
import 'dart:developer';

import 'package:easy_go_partner/ride/verify_ride.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../assistants/assistantsMethod.dart';
import '../model/ride_model.dart';
import '../widget/custom_widget.dart';

class PendingRideDetails extends StatefulWidget {
  final Ride ride;

  const PendingRideDetails({super.key, required this.ride});

  @override
  State<PendingRideDetails> createState() => _PendingRideDetailsState();
}

class _PendingRideDetailsState extends State<PendingRideDetails> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  GoogleMapController? newMapController;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  bool isLoading = true;
  bool isRideStarted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isRideStarted = widget.ride.isStarted;
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Processing, Please wait..."),
        barrierDismissible: false,
      );
      getPlaceDirection();
      Future.delayed(Duration(seconds: 3), () {
        // Navigator.of(context).pop(); // Dismiss the dialog
        setState(() {
          isLoading = false; // Set isLoading to false after loading is done
        });
      });
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 18,
  );

  Widget buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Colors.white12,
      child: Container(
        height: 145,
        color: Colors.white,
      ),
    );
  }

  Future<void> startRide() async {
    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child('Ride Request')
        .child(widget.ride.rideId);
    await rideRequestRef.update({
      'is_started': true,
    });

    setState(() {
      isRideStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride Details"),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black12,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, right: 12.0, top: 10),
                  child: Container(
                    // color: Colors.black,
                    width: double.infinity,
                    height: 250,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: _kGooglePlex,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      polylines: polylineSet,
                      markers: markersSet,
                      // circles: circlesSet,
                      onMapCreated: (GoogleMapController controller) {
                        mapController.complete(controller);
                        newMapController = controller;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (!isRideStarted) ...[
                          Padding(
                            padding: EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Have you started the ride?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 100,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF0000FF),
                                    ),
                                    onPressed: startRide,
                                    child: Text("Start Ride"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Padding(
                          padding: EdgeInsets.only(left: 12.0, right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              Text(
                                "Contact Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: isLoading
                              ? buildShimmerEffect() // Show shimmer if isLoading is true
                              : Container(
                                  child: ContactDetailCard(
                                    senderName: widget.ride.senderName,
                                    senderPhone: widget.ride.senderPhone,
                                    receiverName: widget.ride.receiverName,
                                    receiverPhone: widget.ride.receiverPhone,
                                  ),
                                ),
                        ),
                        SizedBox(height: 8),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         "Fare Summary",
                        //         style: TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 16,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: isLoading
                              ? buildShimmerEffect() // Show shimmer if isLoading is true
                              : Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Fare Summary",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Total Distance"),
                                            Text("${widget.ride.distance}"),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Trip Fare (incl. Toll)"),
                                            Text("${widget.ride.amount}"),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Net Fare"),
                                            Text("${widget.ride.amount}"),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Amount Receive (rounded)",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "${widget.ride.amount}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        // const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: isLoading
                              ? buildShimmerEffect() // Show shimmer if isLoading is true
                              : Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Goods",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        Divider(),
                                        Row(
                                          children: [
                                            Text(
                                              "${widget.ride.goods}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: isLoading
                              ? buildShimmerEffect() // Show shimmer if isLoading is true
                              : Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Payment",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Payment Status"),
                                            Text("${widget.ride.payment}"),
                                          ],
                                        ),

                                        // const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRideStarted)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: isLoading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: CustomButton(
                          hint: "Mark as Complete",
                          onPress: () async {},
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      )
                    : CustomButton(
                        hint: "Mark as Complete",
                        onPress: () async {
                          log("+91" + widget.ride.receiverPhone);
                          Get.to(
                            () => VerifyRideOtp(
                              "+91" + widget.ride.receiverPhone,
                              widget.ride.rideId,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = widget.ride.pickUpLatLng;
    var finalPos = widget.ride.dropOffLatLng;

    var pickUpLatLng = LatLng(initialPos.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos.latitude!, finalPos.longitude!);

    var details = await AssistantsMethod.obtainPlaceDirectionDirection(
        pickUpLatLng, dropOffLatLng);

    if (details != null) {
      // Navigator.pop(context);

      // print("This is Encoded Points: ${details.encodedPoint}");
      print(details.encodedPoint);

      PolylinePoints polylinePoints = PolylinePoints();
      List<PointLatLng> decodedLinePoints =
          polylinePoints.decodePolyline(details.encodedPoint!);

      pLineCoordinates.clear();

      if (decodedLinePoints.isNotEmpty) {
        decodedLinePoints.forEach((PointLatLng pointLatLng) {
          pLineCoordinates
              .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });
      }

      polylineSet.clear();
      markersSet.clear();

      setState(() {
        Polyline polyline = Polyline(
            color: Colors.black,
            polylineId: PolylineId("PolyLineId"),
            jointType: JointType.round,
            points: pLineCoordinates,
            width: 4,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true);

        polylineSet.add(polyline);
      });

      LatLngBounds latLngBounds;
      if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
          pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds =
            LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
      } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
            northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
      } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
            northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
      } else {
        latLngBounds =
            LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
      }

      newMapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

      Marker pickUpMarker = Marker(
        markerId: MarkerId("pickUpId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
            title: widget.ride.pickUpAddress, snippet: "Pick Up Location"),
        position: pickUpLatLng,
      );

      Marker dropOffMarker = Marker(
        markerId: MarkerId("dropOffId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: widget.ride.dropOffAddress, snippet: "Drop Off Location"),
        position: dropOffLatLng,
      );

      setState(() {
        markersSet.add(pickUpMarker);
        markersSet.add(dropOffMarker);
      });

      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    }
  }
}
