import 'package:clone_uber/Assistants/requestAssistant.dart';
import 'package:clone_uber/DataHandler/appData.dart';
import 'package:clone_uber/Entities/dbConstants.dart';
import 'package:clone_uber/Models/address.dart';
import 'package:clone_uber/Models/allUsers.dart';
import 'package:clone_uber/Models/directionDetails.dart';
import 'package:clone_uber/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$geoCodingKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      placeAddress = response["results"][0]["formatted_address"];

      Address userPickUpAddress = new Address(
          latitude: position.latitude,
          longitude: position.longitude,
          placeName: placeAddress);

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$geoCodingKey";

    var response = await RequestAssistant.getRequest(directionUrl);

    if (response == "failed") return null;

    if (response["status"] != "OK") return null;

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedTexts =
        response["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        response["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.distanceValue =
        response["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        response["routes"][0]["legs"][0]["duration"]["text"];

    directionDetails.durationValue =
        response["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    //double totalLocalAmount = totalFareAmount * 160;

    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    DbHelper.user = FirebaseAuth.instance.currentUser;
    var reference = DbHelper.userDbReference.child(DbHelper.user.uid);

    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        AppUser user = AppUser.fromSnapshot(dataSnapshot);
        currentUserInfo = user;
      }
    });
  }
}
