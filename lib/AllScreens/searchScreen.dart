import 'package:clone_uber/AllWidgets/divider.dart';
import 'package:clone_uber/AllWidgets/progressDialog.dart';
import 'package:clone_uber/Assistants/requestAssistant.dart';
import 'package:clone_uber/DataHandler/appData.dart';
import 'package:clone_uber/Models/address.dart';
import 'package:clone_uber/Models/placePrediction.dart';
import 'package:clone_uber/configMaps.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpContoller = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  List<PlacePrediction> placePredictions = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";

    pickUpContoller.text = placeAddress;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: [
            Container(
              height: 215.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child: Column(
                  children: [
                    SizedBox(height: 5.0),
                    Stack(
                      children: [
                        GestureDetector(
                          child: Icon(Icons.arrow_back),
                          onTap: () {
                            Navigator.of(_scaffoldKey.currentContext).pop();
                          },
                        ),
                        Center(
                          child: Text("Təyinat nöqtəsini axtar",
                              style: TextStyle(fontSize: 18.0)),
                        )
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Image.asset(
                          "images/pickicon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickUpContoller,
                                decoration: InputDecoration(
                                  hintText: "PickUp location",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Image.asset(
                          "images/desticon.png",
                          height: 16.0,
                          width: 16.0,
                        ),
                        SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (value) {
                                  findPlace(value);
                                },
                                controller: destinationController,
                                decoration: InputDecoration(
                                  hintText: "Haraya gedirsiniz?",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            //list of tile
            (placePredictions.length > 0)
                ? Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListView.separated(
                        padding: EdgeInsets.all(0.0),
                        itemBuilder: (context, index) {
                          return PredictionTile(
                            placePrediction: placePredictions[index],
                            scfContext: _scaffoldKey.currentContext,
                          );
                        },
                        itemCount: placePredictions.length,
                        separatorBuilder: (context, index) => MyDivider(),
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length < 4) return;
    String autoCompleteUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$geoCodingKey&sessiontoken=1234567890&components=country:az";

    var response = await RequestAssistant.getRequest(autoCompleteUrl);

    if (response == "failed") return;

    if (response["status"] != "OK") return;

    var predictions = response["predictions"];

    var placeList =
        (predictions as List).map((e) => PlacePrediction.fromJson(e)).toList();

    setState(() {
      placePredictions = placeList;
    });
  }
}

class PredictionTile extends StatelessWidget {
  final BuildContext scfContext;
  final PlacePrediction placePrediction;

  PredictionTile({Key key, this.placePrediction, this.scfContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        getPlaceAddressDetails(placePrediction.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10.0),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(
                        placePrediction.main_text,
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        placePrediction.secondary_text,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                SizedBox(width: 10.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => ProgressDialog(
    //     message: "Yuklenir",
    //   ),
    // );

    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$geoCodingKey";

    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    //Navigator.pop(context);
    //Navigator.pop(context, "obtainDirection");

    if (res == "failed") return;

    if (res["status"] != "OK") return;

    Address address = Address();

    address.placeName = res["result"]["name"];
    address.placeId = placeId;
    address.latitude = res["result"]["geometry"]["location"]["lat"];
    address.longitude = res["result"]["geometry"]["location"]["lng"];

    // Provider.of<AppData>(context, listen: false)
    //     .updateDestinationLocationAddress(address);

    // print("This is your destination :: ");
    // print(address.placeName);

    // Navigator.pop(context, "obtainDirection");

    var newString = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: geoCodingKey, // Put YOUR OWN KEY here.
          onPlacePicked: (result) async {
            showDialog(
              context: context,
              builder: (BuildContext context) => ProgressDialog(
                message: "Elave edilir, gozleyin...",
              ),
            );
            String placeDetailsUrl1 =
                "https://maps.googleapis.com/maps/api/place/details/json?place_id=${result.placeId}&key=$geoCodingKey";

            var res1 = await RequestAssistant.getRequest(placeDetailsUrl1);

            Navigator.pop(context);

            if (res1 == "failed") return;

            if (res1["status"] != "OK") return;

            Address address1 = Address();

            address1.placeName = res1["result"]["name"];
            address1.placeId = result.placeId;
            address1.latitude = res1["result"]["geometry"]["location"]["lat"];
            address1.longitude = res1["result"]["geometry"]["location"]["lng"];

            Provider.of<AppData>(context, listen: false)
                .updateDestinationLocationAddress(address1);

            print("This is your destination :: ");
            print(address1.placeName);
            Navigator.pop(context, "obtainDirection");
          },
          initialPosition: LatLng(address.latitude, address.longitude),
          useCurrentLocation: false,
          selectInitialPosition: true,
        ),
      ),
    );
    Navigator.of(context).pop("obtainDirection");
  }
}
