import 'package:easy_go_partner/assistants/requestAssistants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../consts/firebase_consts.dart';
import '../dataHandler/appData.dart';
import '../model/address.dart';
import '../model/directionDetail.dart';

class AssistantsMethod {

  static Future<String> searchCurrentAddress(Position position) async {
    String placeAddress = "";
    // String st0, st1, st2, st3, st4, st5, st6;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistants.getRequest(url);

    if (response != 'failed') {
      // st0 = response["results"][0]["address_components"][0]["long_name"];
      // st1 = response["results"][0]["address_components"][1]["long_name"];
      // st2 = response["results"][0]["address_components"][2]["long_name"];
      // st3 = response["results"][0]["address_components"][3]["long_name"];
      // st4 = response["results"][0]["address_components"][5]["long_name"];
      // st5 = response["results"][0]["address_components"][7]["long_name"];
      // st6 = response["results"][0]["address_components"][6]["long_name"];

      // placeAddress = st1 + ", " + st2 + ", "+ st3 + ", "+ st5;
      // + st4 + ", "+ st5 + ", " + st6
      //  + st3 + ", " + st4;
      placeAddress = response["results"][0]["formatted_address"];

      Address driverCurrentAddress = new Address();
      driverCurrentAddress.longitude = position.longitude;
      driverCurrentAddress.latitude = position.latitude;
      driverCurrentAddress.placeName = placeAddress;

      final appData = Get.put(AppData());

      appData.updateCurrentLocationAddress(driverCurrentAddress);

      // Provider.of<AppData>(context).updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetail?> obtainPlaceDirectionDirection(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition.latitude},${finalPosition.longitude}&origin=${initialPosition.latitude},${initialPosition.longitude}&key=$mapKey";

    var res = await RequestAssistants.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetail directionDetail = DirectionDetail();

    directionDetail.encodedPoint =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetail.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetail.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetail.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetail.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetail;
  }
}
