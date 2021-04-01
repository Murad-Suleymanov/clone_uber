import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clone_uber/AllScreens/searchScreen.dart';
import 'package:clone_uber/AllWidgets/divider.dart';
import 'package:clone_uber/AllWidgets/progressDialog.dart';
import 'package:clone_uber/Assistants/assistantMethods.dart';
import 'package:clone_uber/DataHandler/appData.dart';
import 'package:clone_uber/MainScreenComponents/paymentType.dart';
import 'package:clone_uber/MainScreenComponents/requestContainer.dart';
import 'package:clone_uber/Models/directionDetails.dart';
import 'package:clone_uber/configMaps.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  var colorizeColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Signatra',
  );

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  DirectionDetails tripDirectionDetails;

  Position currentPosition;
  var geoLocator = new Geolocator();

  double bottomPaddingOfMap = 0;
  double rideDetailContainer = 0;
  double requestRideDetailContainer = 0;
  double searchContinerHeight = 320.0;

  bool drawerOpen = true;

  DatabaseReference rideRequestRef;

  @override
  void initState() {
    super.initState();

    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationLocation;

    Map pickUpMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map destMap = {
      "latitude": destination.latitude.toString(),
      "longitude": destination.longitude.toString(),
    };

    Map riderOfMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpMap,
      "destination": destMap,
      "created_at": DateTime.now().toString(),
      "rider_name": currentUserInfo.name,
      "rider_phone": currentUserInfo.phone,
      "pickup_address": pickUp.placeName,
      "destination_address": destination.placeName,
    };

    rideRequestRef.set(riderOfMap);
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
  }

  resetApp() {
    setState(() {
      searchContinerHeight = 330.0;
      rideDetailContainer = 0;
      bottomPaddingOfMap = 330.0;
      drawerOpen = true;
      requestRideDetailContainer = 0;

      polyLineSet.clear();
      markers.clear();
      circles.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRequestRideContainer() async {
    setState(() {
      requestRideDetailContainer = 260.0;
      rideDetailContainer = 0;
      bottomPaddingOfMap = 260;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDistance();

    setState(() {
      searchContinerHeight = 0;
      rideDetailContainer = 260;
      bottomPaddingOfMap = 330.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng lastLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: lastLatPosition, zoom: 14);

    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address ::  " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(
        currentInitialPosition.latitude, currentInitialPosition.longitude),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        drawer: Container(
          color: Colors.white,
          width: 255.0,
          child: Drawer(
            child: ListView(
              children: [
                Container(
                  height: 165.0,
                  child: DrawerHeader(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset("images/user_icon.png",
                            height: 65.0, width: 65.0),
                        SizedBox(width: 16.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profile Name",
                              style: TextStyle(
                                  fontSize: 16.0, fontFamily: "Brand-Bold"),
                            ),
                            SizedBox(height: 6.0),
                            Text("Visit Profile"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                MyDivider(),
                SizedBox(height: 12.0),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text("History", style: TextStyle(fontSize: 15.0)),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title:
                      Text("Visit profile", style: TextStyle(fontSize: 15.0)),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text("About", style: TextStyle(fontSize: 15.0)),
                ),
              ],
            ),
          ),
        ),
        // appBar: AppBar(
        //   title: Text("Main screen"),
        // ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polyLineSet,
              markers: markers,
              circles: circles,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);

                newGoogleMapController = controller;

                locatePosition();

                setState(() {
                  bottomPaddingOfMap = 330.0;
                });
              },
            ),
            Positioned(
              top: 45.0,
              left: 22.0,
              child: GestureDetector(
                onTap: () {
                  if (drawerOpen) {
                    scaffoldState.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(drawerOpen ? Icons.menu : Icons.close,
                        color: Colors.black),
                    radius: 20.0,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: searchContinerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6.0),
                        Text("Sizi görmək xoşdur!",
                            style: TextStyle(fontSize: 12.0)),
                        Text("Haraya gedirsiniz?",
                            style: TextStyle(
                                fontSize: 20.0, fontFamily: "Brand-Bold")),
                        SizedBox(height: 20.0),
                        GestureDetector(
                          onTap: () async {
                            var res = await Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => SearchScreen()));

                            if (res == "obtainDirection") {
                              displayRideDetailsContainer();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: Colors.blue),
                                  SizedBox(width: 12.0),
                                  Text("Təyinat nöqtəsini seçin"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.0),
                        Row(
                          children: [
                            Icon(Icons.home, color: Colors.grey),
                            SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Provider.of<AppData>(context)
                                            .pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation
                                        .placeName
                                    : "Ev ünvanını daxil et"),
                                SizedBox(height: 4.0),
                                Text(
                                  "Ev ünvanı",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12.0),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10.0),
                        MyDivider(),
                        SizedBox(height: 10.0),
                        Row(
                          children: [
                            Icon(Icons.work, color: Colors.grey),
                            SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("İş ünvanını daxil et"),
                                SizedBox(height: 4.0),
                                Text(
                                  "İş ünvanı",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12.0),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //
            Positioned(
              bottom: 0,
              left: 0.0,
              right: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: Container(
                  height: rideDetailContainer,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.tealAccent[100],
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  "images/taxi.png",
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Minik masini",
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: "Brand Bold"),
                                    ),
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : '',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.grey),
                                    )
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  ((tripDirectionDetails != null)
                                      ? AssistantMethods.calculateFares(
                                                  tripDirectionDetails)
                                              .toString() +
                                          ' Manat'
                                      : ''),
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: "Brand Bold"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        PaymentTypeWidget(),
                        SizedBox(height: 24.0),
                        RideRequesetWidget(
                            executableFunction: displayRequestRideContainer),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 0.5,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                height: requestRideDetailContainer,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Process isleyir',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                            ColorizeAnimatedText(
                              'Gozleyin',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                            ColorizeAnimatedText(
                              'Surucu axtarilir',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          isRepeatingAnimation: true,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),
                      SizedBox(height: 22.0),
                      GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26.0),
                            border:
                                Border.all(width: 2.0, color: Colors.grey[300]),
                          ),
                          child: Icon(Icons.close, size: 26.0),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Legv et",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
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

  Future<void> getPlaceDistance() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).pickUpLocation;

    var finalPosition =
        Provider.of<AppData>(context, listen: false).destinationLocation;

    var initialLatLng =
        LatLng(initialPosition.latitude, initialPosition.longitude);

    var finalLatLng = LatLng(finalPosition.latitude, finalPosition.longitude);

    showDialog(
      context: context,
      builder: (context) => ProgressDialog(
        message: "Gozleyin",
      ),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        initialLatLng, finalLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    pLineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedTexts);

    if (decodePolyLinePointsResult.isNotEmpty) {
      decodePolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("PolyLineId"),
        color: Colors.blue,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 3,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (initialLatLng.latitude > finalLatLng.latitude &&
        finalLatLng.longitude < initialLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: finalLatLng, northeast: initialLatLng);
    } else if (initialLatLng.longitude > finalLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(initialLatLng.latitude, finalLatLng.longitude),
          northeast: LatLng(finalLatLng.latitude, initialLatLng.longitude));
    } else if (initialLatLng.latitude > finalLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(finalLatLng.latitude, initialLatLng.longitude),
          northeast: LatLng(initialLatLng.latitude, finalLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: initialLatLng, northeast: finalLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker initialMarker = Marker(
      markerId: MarkerId("initial"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: initialLatLng,
      infoWindow: InfoWindow(
          title: initialPosition.placeName, snippet: "Hazirki mekan"),
    );

    Marker finalMarker = Marker(
      markerId: MarkerId("final"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: finalLatLng,
      infoWindow: InfoWindow(
          title: finalPosition.placeName, snippet: "Gedilecek mekan"),
    );

    setState(() {
      markers.addAll({initialMarker, finalMarker});
    });

    Circle initialCircle = Circle(
      circleId: CircleId("initial"),
      fillColor: Colors.blueAccent,
      center: initialLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
    );

    Circle finalCircle = Circle(
      circleId: CircleId("final"),
      fillColor: Colors.deepPurple,
      center: finalLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
    );

    setState(() {
      circles.addAll({initialCircle, finalCircle});
    });
  }
}
