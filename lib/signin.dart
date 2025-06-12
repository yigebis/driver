import 'dart:convert';
import 'dart:ui' as html;

import 'package:driver/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  Credential _credential = Credential(); 
  bool _showPassword = false;

  String? _validateEmail(String email){
    if (email.isEmpty){
      return "Email is required";
    }
    if (!email.contains("@")){
      return "Email is not valid";
    }
    return null;
  }

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

  void signIn() async{
    if (_formStateKey.currentState!.validate()){
      _formStateKey.currentState!.save();

      var response = await http.post(
        Uri.parse('https://hawir-rv5k.onrender.com/driver/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email" : _credential._email.trim(),
          "password": _credential._password.trim()
        }),
      );

      // final storage = FlutterSecureStorage();
      Map<String, dynamic> data = jsonDecode(response.body);

      print(response.statusCode);
      if (response.statusCode == 200){
        var accessToken = data["token"];
        var driverData = data["driver"];
        // print(driverData);
        // await storage.write(key: "access_token", value: accessToken);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString("driver_data", jsonEncode(driverData));
        Navigator.pushNamed(context, "/main");
      }
      else{
        var errorMessage = data["error"];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(80.0),
        child: Form(
          key: _formStateKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) => _validateEmail(value!),
                onSaved: (value) => _credential._email = value!,
              ),
              SizedBox(height: 8.0,),
              TextFormField(
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "Password",     
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: (){
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    }
                  )
                ),
                validator: (value) => _validatePassword(value!),
                onSaved: (value) => _credential._password = value!,
              ),
              SizedBox(height : 8.0),
              ElevatedButton(
                onPressed: (){
                  signIn();
                }, 
                child: Text("Sign In"),
              )

            ],
          ),
        )
        
      ),
    );
  }
}

class Credential{
  late String _email;
  late String _password;

  Credential();
}