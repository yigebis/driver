import 'dart:convert';

import 'package:driver/constants/api_constants.dart';
import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_flushbar/flushbar.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var _formStateKey = GlobalKey<FormState>();
  bool isButtonDisabled = false;
  var driverData;
  var token;
  var setup;

  bool _showOldPassword = false, _showNewPassword = false, _showNew2Password = false;
  Credential _credential = Credential();
  var _oldPassword = "", _newPassword = "", _new2Password = "";

  String? _validatePassword(String password){
    if (password.length < 8){
      return "Password should have a length of at least 8";
    }
    int upper = 0, lower = 0, digit = 0, special = 0;
    for (int i = 0; i < password.length; i++){
      var ascii = password[i].codeUnitAt(0);
      if (ascii >= 65 && ascii <= 90){
        upper++;
      }
      else if (ascii >= 97 && ascii <= 122){
        lower++;
      }
      else if(ascii >= 48 && ascii < 58){
        digit++;
      }
      else{
        special++;
      } 
    }

    if (lower * upper * special * digit == 0){
      return "password should contain at least one uppercase, lowercase, digit and special character";
    }

    return null;
  }

  String? _validateConfirmPassword(password){
    if (password != _newPassword){
      return "should be the same as the new password";
    }
    return null;
  }

  Flushbar successFlushBar(){
    return Flushbar(
      message: "Password Changed Successfully!",
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    );
  }

  Flushbar failureFlushBar(){
    return Flushbar(
      message: "oops, error while changing password",
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    );
  }

  void change() async{
    if (_formStateKey.currentState!.validate()){
      _formStateKey.currentState!.save();

      var changeResponse = await http.post(
        Uri.parse("$BASE_URL/driver/changepassword"),
        headers: {
          "Authorization" : "Bearer $token",
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "old_password" : _oldPassword,
          "new_password" : _newPassword,
          "confirm_password" : _new2Password
        }),
      );

      if (changeResponse.statusCode == 200){
        isButtonDisabled = true;
        successFlushBar().show(context).then( (value) => Navigator.pushReplacementNamed(context, "/signin"));
      }
      else{
        failureFlushBar().show(context);
        setState(
          (){
            isButtonDisabled = false;
          }
        );
        
      }
      // print(changeResponse.statusCode);
      // print(changeResponse.body);
    }
  }

  void initState(){
    super.initState();
    initAsync();
  }

  void initAsync() async{
    var prefs = await SharedPreferences.getInstance();
    var driverJSON = jsonDecode(prefs.getString("driver_data")!);
    var tokenString = prefs.getString("access_token");
    setState(() {
      driverData = driverJSON;
      token = tokenString;
      setup = true;
    });

    // print(token);
  }

  TextFormField formField(String type, bool showStatus, Function validator){
    return TextFormField(
      obscureText: !showStatus,
      decoration: InputDecoration(
        labelText: type == "O"? "Old Password" : (type == "N"? "New Password" : "Confirm New Password"),
        suffixIcon: IconButton(
          icon: Icon(showStatus ? Icons.visibility : Icons.visibility_off),
          onPressed: (){
            setState(() {
              if (type == "O"){
                _showOldPassword = !showStatus;
              }
              else if (type == "N"){
                _showNewPassword = !showStatus;
              }
              else{
                _showNew2Password = !showStatus;
              }
            });
          },
        )
      ),
      validator: (value) => validator(value!),
      onChanged: (value) => setState(() {
        if (type == "O"){
          _oldPassword = value;
        }
        else if (type == "N"){
          _newPassword = value;
        }
        else{
          _new2Password = value;
        }
      }),
      onSaved: (value) => type == "O"? _credential._oldPassword = value! : (type == "N"? _credential._newPassword = value! : _credential._confirmPassword = value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("Change Password"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard when tapping outside
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0), // smaller, more adaptive padding
          reverse: true, // ensures view scrolls up when keyboard appears
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formStateKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  formField("O", _showOldPassword, _validatePassword),
                  SizedBox(height: 16.0),

                  formField("N", _showNewPassword, _validatePassword),
                  SizedBox(height: 16.0),

                  formField("2", _showNew2Password, _validateConfirmPassword),
                  SizedBox(height: 24.0),

                  ElevatedButton(
                    onPressed: isButtonDisabled ? null : change,
                    child: Text("Change Password"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Credential{
  late String _oldPassword, _newPassword, _confirmPassword;
} 