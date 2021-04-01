import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentTypeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.moneyCheckAlt,
            size: 18.0,
            color: Colors.black54,
          ),
          SizedBox(width: 16.0),
          Text("Nagd"),
          SizedBox(width: 6.0),
          Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16.0)
        ],
      ),
    );
  }
}
