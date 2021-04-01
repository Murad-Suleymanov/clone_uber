import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

typedef CustomCallBack = void Function();

// ignore: must_be_immutable
class RequestWaiterWidget extends StatelessWidget {
  double requestRideDetailContainer;
  CustomCallBack cancelRideRequest;
  CustomCallBack resetApp;

  RequestWaiterWidget(
      {this.requestRideDetailContainer, this.cancelRideRequest, this.resetApp});

  var colorizeColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  var colorizeTextStyle = TextStyle(
    fontSize: 50.0,
    fontFamily: 'Signatra',
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                    border: Border.all(width: 2.0, color: Colors.grey[300]),
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
    );
  }
}
