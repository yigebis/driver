import 'package:driver/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class BusTrackRemote{

  static const BASE = "http://192.168.69.64:8080";
  // static const BASE = BASE_URL;

  static Future<void> announceStarting(tripID, token) async{
    print("starting trip with ID: $tripID");
    var url = Uri.parse("$BASE/bus_tracking/start/$tripID");
    var response = await http.post(
      url,
      headers: {
        "Authorization" : "Bearer $token",
        'Content-Type': 'application/json',
      });

    if (response.statusCode == 200) {
      print("Trip started successfully");
    } else {
      print("Failed to start trip: ${response.statusCode} ${response.body}");
    }
  }

  static Future<void> announceStopping(tripID, token) async{
    print("stopping trip with ID: $tripID");
    var url = Uri.parse("$BASE/bus_tracking/stop/$tripID");
    var response = await http.post(
      url,
      headers: {
        "Authorization" : "Bearer $token",
        'Content-Type': 'application/json',
      });

    if (response.statusCode == 200) {
      print("Trip stopped successfully");
    } else {
      print("Failed to stop trip: ${response.statusCode} ${response.body}");
    }
  }
}