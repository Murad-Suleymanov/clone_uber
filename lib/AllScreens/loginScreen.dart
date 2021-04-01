import 'package:clone_uber/AllScreens/mainscreen.dart';
import 'package:clone_uber/AllScreens/registrationScreen.dart';
import 'package:clone_uber/AllWidgets/progressDialog.dart';
import 'package:clone_uber/Entities/dbConstants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  static const String idScreen = "login";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  register(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, RegistrationScreen.idScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 35.0,
                ),
                Image(
                  image: AssetImage("images/logo.png"),
                  width: 390.0,
                  height: 250.0,
                  alignment: Alignment.center,
                ),
                SizedBox(
                  height: 1.0,
                ),
                Text(
                  "Login as Rider",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 1.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(
                  height: 1.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                    ),
                    hintStyle: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(
                  height: 1.0,
                ),
                // ignore: deprecated_member_use
                RaisedButton(
                  onPressed: () {
                    loginAndAuthenticationUser(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                  color: Colors.yellow,
                  textColor: Colors.white,
                  child: Container(
                    child: Center(
                      child: Text(
                        "Log in",
                      ),
                    ),
                  ),
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.idScreen, (route) => false);
                  },
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  void loginAndAuthenticationUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Authenticating, Please wait...");
        });

    final User user = (await auth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .catchError((errorMsg) {
      Navigator.pop(context);
      displayToastMessage("Error: " + errorMsg.toString(), context);
    }))
        .user;

    if (user != null) {
      DbHelper.userDbReference
          .child(user.uid)
          .once()
          .then((value) => (DataSnapshot snap) {
                if (snap.value != null) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.idScreen, (route) => false);

                  displayToastMessage("Logged succesfully", context);
                } else {
                  Navigator.pop(context);
                  auth.signOut();
                  displayToastMessage("Error raised", context);
                }
              });

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      displayToastMessage("Not create", context);
    }
  }

  void displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
