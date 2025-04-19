import 'package:flutter/material.dart';
import 'package:driver/signin.dart';
import 'package:driver/dashboard.dart';
import 'package:driver/track.dart';
import 'package:driver/tripcompletion.dart';
import 'package:driver/profile.dart';
import 'package:driver/changepassword.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/signin",
      routes: {
        "/signin" : (context) => Signin(),
        "/dashboard": (context) => Dashboard(),
        "/profile" : (context) => Profile(),
        "/track" : (context) => Track(),
        "/tripcompletion" : (context) => TripCompletion(),
        "/changepassword" : (context) => ChangePassword(),
      }
    )
  );
}

