import 'package:firebase_database/firebase_database.dart';

class AppUser {
  String id;
  String email;
  String name;
  String phone;

  AppUser({this.id, this.email, this.name, this.phone});

  AppUser.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = dataSnapshot.value["email"];
    name = dataSnapshot.value["name"];
    phone = dataSnapshot.value["phone"];
  }
}
