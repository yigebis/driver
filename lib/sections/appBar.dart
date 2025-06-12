import 'package:flutter/material.dart';

AppBar driverAppBar(String title){
  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 74, 235, 80),
    automaticallyImplyLeading: false,
  );
}