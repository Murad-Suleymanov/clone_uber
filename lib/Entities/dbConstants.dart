import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DbHelper {
  static DatabaseReference userDbReference =
      FirebaseDatabase.instance.reference().child("Users");

  static DatabaseReference rideRequestReference =
      FirebaseDatabase.instance.reference().child("Ride Requests");

  static User user;
}
