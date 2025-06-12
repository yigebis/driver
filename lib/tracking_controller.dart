import 'dart:async';
import 'dart:convert';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver/constants/api_constants.dart';
import 'package:driver/remote/bus_track.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;

class BusTrackingService {
  Timer? _locationUpdateTimer;
  static final BusTrackingService _instance = BusTrackingService._internal();
  factory BusTrackingService() => _instance;
  bool isTracking = false;
  Duration _elapsedTime = Duration.zero;
  DateTime? _tripStartTime;
  String? _token;
  String? _tripID;

  BusTrackingService._internal();

  WebSocketChannel? _channel;

  StreamSubscription<InternetConnectionStatus>? _connectionSubscription;

  void initInternetMonitoring(String token) {
    _connectionSubscription?.cancel(); // cancel existing stream if any

    _connectionSubscription = InternetConnectionChecker.instance.onStatusChange.listen((status) {
      print('Internet status changed: $status');
      if (status == InternetConnectionStatus.connected && _channel == null) {
        print("Reconnecting WebSocket after internet restored...");
        connect(token);
      }
    });
  }


  final _listeners = <void Function(LatLng)>{};

  bool checkTracking(){
    if (isTracking == true) {
      return true;
    }
    return false;
  }

  void startDriverLocationUpdates(String tripID, String busID, String token) async{
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;

    _tripStartTime = DateTime.now();
    // make the actual start time of the trip as now
    _token = token;
    _tripID = tripID;
    await BusTrackRemote.announceStarting(tripID, token);

    () async {
      Position pos = await Geolocator.getCurrentPosition();
      final data = jsonEncode({
        "bus_id": busID,
        "latitude": pos.latitude,
        "longitude": pos.longitude,
      });
      _channel?.sink.add(data);
    }();
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      Position pos = await Geolocator.getCurrentPosition();
      final data = jsonEncode({
        "bus_id": busID,
        "latitude": pos.latitude,
        "longitude": pos.longitude,
      });
      _channel?.sink.add(data);
    });

    isTracking = true;
  }

  Future<bool> handleLocationPermission() async{
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        print("Location permission denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever){
      print("Location permission denied forever");
      return false;
    }

    return true;
  }

  Duration getCurrentElapsedTime(){
    _elapsedTime = DateTime.now().difference(_tripStartTime!);
    return _elapsedTime;
  }

  // void initConnectivityMonitoring(token) {

  //   Connectivity().onConnectivityChanged.listen((result) {
  //     print("connectivity changed");
  //     final isConnected = (result != ConnectivityResult.none);
  //     if (isConnected && _channel == null) {
  //       print("Reconnecting WebSocket after connectivity restored...");
  //       connect(token); // Reconnect if not connected
  //     }
  //   });
  // }

  void connect(token) {
    if (_channel != null) return; // Already connected

    // _channel = WebSocketChannel.connect(Uri.parse('wss://hawir-rv5k.onrender.com/ws'));
    _channel = IOWebSocketChannel.connect(Uri.parse("wss://$BASE_URL_TRAILING/ws"),
      headers: {
        'Authorization' : 'Bearer $token',
      }
    );

    _channel!.stream.listen(
      (data) {
        print("Received: $data");
        final json = jsonDecode(data);
        final lat = (json['latitude'] as num).toDouble();
        final lng = (json['longitude'] as num).toDouble();
        final location = LatLng(lat, lng);

        for (var listener in _listeners) {
          listener(location);
        }
      },
      onDone: () {
        print("WebSocket closed");
        _channel = null;
      },
      onError: (error) {
        print("WebSocket error: $error");
        _channel = null;
      },
    );

    print("WebSocket connected");
  }

  void addListener(void Function(LatLng) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(LatLng) listener) {
    _listeners.remove(listener);
  }

  void close() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _channel?.sink.close();
    _channel = null;
    isTracking = false;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    BusTrackRemote.announceStopping(_tripID, _token);
    _tripID = null;
    _token = null;
  }
}