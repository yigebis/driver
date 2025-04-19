import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Email: ${_credential._email} ] \nPassword: ${_credential._password}" )
      //   )
      // );

      // Navigator.pushNamed(context, "/dashboard");

      var response = await http.post(
        Uri.parse('http://localhost:8080/driver/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email" : _credential._email,
          "password": _credential._password
        }),
      );

      print(response.body);
      print(response.statusCode);


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

  Credential(){}
}