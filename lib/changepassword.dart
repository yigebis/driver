import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var _formStateKey = GlobalKey<FormState>();
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

  void change(){
    if (_formStateKey.currentState!.validate()){
      _formStateKey.currentState!.save();
      print("Correct");
    }
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
      body: Padding(
        padding: EdgeInsets.all(80.0),
        child: Form(
          key: _formStateKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              formField("O", _showOldPassword, _validatePassword),
              SizedBox(height: 8.0),

              formField("N", _showNewPassword, _validatePassword),
              SizedBox(height: 8.0),

              formField("2", _showNew2Password, _validateConfirmPassword),
              SizedBox(height: 8.0),

              ElevatedButton(
                onPressed: (){
                  change();
                }, 
                child: Text("Change Password"),
              )
            ],
          )
        )
      )
    );
  }
}

class Credential{
  late String _oldPassword, _newPassword, _confirmPassword;
} 