import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef CustomCallBack = void Function();

// ignore: must_be_immutable
class RideRequesetWidget extends StatelessWidget {
  CustomCallBack executableFunction;

  RideRequesetWidget({this.executableFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      // ignore: deprecated_member_use
      child: RaisedButton(
        onPressed: () {
          executableFunction();
        },
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sifaris",
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26.0),
            ],
          ),
        ),
      ),
    );
  }
}
