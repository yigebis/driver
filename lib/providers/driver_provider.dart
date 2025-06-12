import 'dart:convert';
import 'package:driver/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProvider extends ChangeNotifier {
  Map<String, dynamic>? _decodedToken;
  Map<String, dynamic>? _driverData;
  String ? _token;
  String? _language = "አማርኛ";
  String? _calendar = "የኢትዮጵያ";

  Map<String, dynamic>? get driverData => _driverData;
  String get language => _language!;
  String get calendar => _calendar!;
  String? get token => _token;

  Future<void> loadDriverData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token") ?? "";
     
    if (token.isNotEmpty){
      _token = token;
      _decodedToken = JwtDecoder.decode(token);
    }
    
    final data = prefs.getString('driver_data');
    if (data != null) {
      _driverData = jsonDecode(data);
      notifyListeners();
    }
  }

  // get the current trip IDs of the driver
  // Future<void> fetchTrips() async{
  //   List<String> trips = _driverData!["current_trips"];
  //   for (String tripID in trips){
  //     var response = await http.get(
  //       Uri.parse('$BASE_URL/travel/$tripID'),
  //       headers: {
  //         'Authorization' : 'Bearer $_token',
  //         'Content-Type': 'application/json'
  //       },
  //     );

  //     if (response.statusCode == 200){

  //     }
  //   }
  // }

  void updatePhoto(String url) async {
      _driverData!['photo'] = url;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('driver_data', jsonEncode(_driverData));
      notifyListeners();
  }

  void updateLanguage(String newLang) {
    _language = newLang;
    notifyListeners();
  }

  void updateCalendar(String newCal) {
    _calendar = newCal;
    notifyListeners();
  }

  void setDriverData(Map<String, dynamic> data) async {
    _driverData = data;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('driver_data', jsonEncode(data));
    notifyListeners();
  }

  Future<void> clearUserData() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _driverData = null;
    _decodedToken = null;
    _token = null;
    
    print(prefs.getString("driver_data"));
  }
}
