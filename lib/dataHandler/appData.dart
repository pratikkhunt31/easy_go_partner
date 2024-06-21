import 'package:get/get.dart';

import '../model/address.dart';

class AppData extends GetxController {
  // var pickupLocation = Address();
  var currentLocation = Address();

  // void updatePickUpLocationAddress(Address pickUpAddress) {
  //   pickupLocation = pickUpAddress;
  // }

  void updateCurrentLocationAddress(Address currentAddress) {
    currentLocation = currentAddress;
  }
}

