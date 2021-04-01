import 'package:clone_uber/Models/address.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, destinationLocation;
  Position initialPosition;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDestinationLocationAddress(Address destinationAddress) {
    destinationLocation = destinationAddress;
    notifyListeners();
  }
}
