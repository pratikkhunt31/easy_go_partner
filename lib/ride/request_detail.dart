import 'dart:async';

import 'package:easy_go_partner/ride/pending_ride_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../assistants/assistantsMethod.dart';
import '../widget/custom_widget.dart';

class RequestDetail extends StatefulWidget {
  final dynamic data;

  const RequestDetail({super.key, this.data});

  @override
  State<RequestDetail> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetail> {
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  GoogleMapController? newMapController;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.data['pickUpLatLng'] = LatLng(
      double.parse(widget.data['pickUp']['latitude']),
      double.parse(widget.data['pickUp']['longitude']),
    );
    widget.data['dropOffLatLng'] = LatLng(
      double.parse(widget.data['dropOff']['latitude']),
      double.parse(widget.data['dropOff']['longitude']),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Detail'),
        backgroundColor: const Color(0xFF0000FF),
        elevation: 0,
      ),
      body: Container(
        color: Colors.black12,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10),
              child: Container(
                // color: Colors.black,
                width: double.infinity,
                height: 200,
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
            SizedBox(height: 10),
            Expanded(
              child: Container(
                // height: 476,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                            senderName: widget.data['sender_name'],
                            senderPhone: widget.data['sender_phone'],
                            receiverName: widget.data['receiver_name'],
                            receiverPhone: widget.data['receiver_phone'],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Fare Summary",
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
                        padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(widget.data['distance']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Trip Fare (incl. Toll)"),
                                    Text(widget.data['payout']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Net Fare"),
                                    Text(widget.data['payout']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Amount Payable (rounded)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.data['payout'],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      "${widget.data['goods']}",
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
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = widget.data['pickUpLatLng'];
    var finalPos = widget.data['dropOffLatLng'];

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
            title: widget.data['pickUp_address'], snippet: "Pick Up Location"),
        position: pickUpLatLng,
      );

      Marker dropOffMarker = Marker(
        markerId: MarkerId("dropOffId"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: widget.data['dropOff_address'], snippet: "Drop Off Location"),
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
