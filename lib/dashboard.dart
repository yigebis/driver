import 'dart:async';
import 'dart:convert';

import 'package:driver/constants/api_constants.dart';
import 'package:driver/helper/timeFormatHelper.dart';
import 'package:driver/locale_provider.dart';
import 'package:driver/providers/driver_provider.dart';
import 'package:driver/providers/navigation_provider.dart';
import 'package:driver/tracking_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DriverProvider driverProvider;
  bool setup = false;
  String token = "";
  // Map<String, dynamic> decodedToken = {};
  Map<String, dynamic> _driverData = {};
  List<Travel> currentTravels = [];

  @override
  void initState() {
    super.initState();
    initAsync();
    setup = true;
  }

  Future<void> initAsync() async {
    driverProvider = Provider.of<DriverProvider>(context, listen: false);
    await driverProvider.loadDriverData();
      setState(() {
        token = driverProvider.token!;
        _driverData = driverProvider.driverData!;
      });
    await fetchTrips();
  }

  Future<void> fetchTrips() async {
    List<dynamic> travelIDs = _driverData["current_trips"];
    List<Future<http.Response>> requests = travelIDs.map((id) {
      return http.get(Uri.parse("$BASE_URL/travel/$id"), headers: {"Authorization": "Bearer $token"});
    }).toList();

    List<http.Response> responses = await Future.wait(requests);

    List<Travel> trips = [];
    for (final res in responses) {
      if (res.statusCode == 200) {
        var tripData = jsonDecode(res.body);
        tripData["planned_start_time"] = DateTime.parse(tripData["planned_start_time"]);
        trips.add(Travel.fromJson(tripData));
      }
    }
    setState(() {
      currentTravels = trips;
    });      
  }
  // --- UI-ONLY updates: colors, fonts, spacing, gradients, elevation ---

Widget profileSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, "/profile"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 6,
            shadowColor: Colors.black38,
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: _driverData["photo"] != null
                ? NetworkImage(_driverData["photo"])
                : null,
            backgroundColor: Colors.blue.shade100,
            child: _driverData["photo"] == null
                ? Text(
                    setup ? _driverData["first_name"][0].toUpperCase() : "",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _driverData["first_name"] != null
              ? "${AppLocalizations.of(context)!.welcomeComma} ${_driverData["first_name"]}"
              : "${AppLocalizations.of(context)!.loading}...",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    ),
  );
}

Widget trackButton(String tripID, String busID) {
  return ElevatedButton.icon(
    onPressed: () {
      BusTrackingService().initInternetMonitoring(token);
      BusTrackingService().connect(token);
      BusTrackingService().startDriverLocationUpdates(tripID, busID, token);      
      Provider.of<NavigationProvider>(context, listen: false).setIndex(2);
    },
    icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
    label: Text(AppLocalizations.of(context)!.startTracking, style: TextStyle(fontSize: 14, color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green[600],
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      shadowColor: Colors.black45,
    ),
  );
}

Widget trackingButton() {
  return ElevatedButton.icon(
    onPressed: () {},
    icon: const Icon(Icons.track_changes, color: Colors.white, size: 18),
    label: Text(AppLocalizations.of(context)!.tracking, style: TextStyle(fontSize: 14, color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow[800],
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      shadowColor: Colors.black45,
    ),
  );
}

Widget currentTravelsWidget(String tripID, String start, String destination, String busID, String remFormat) {
  return Card(
    color: const Color(0xFF2C2C2C),
    elevation: 6,
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Start Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.from, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        Text(
                          start,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  // Destination Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.to, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        Text(
                          destination,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: remFormat != "Now"
                    ? (BusTrackingService().checkTracking()
                        ? trackingButton()
                        : trackButton(tripID, busID))
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF607D8B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          remFormat,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Drawer settingDrawer(){
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFF00ACC1),
          ),
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 5,),
              Text(
                AppLocalizations.of(context)!.settings,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),

        ListTile(
          leading: const Icon(Icons.color_lens),
          title: Text(AppLocalizations.of(context)!.theme),
          onTap: (){
            //TODO: Implement theme change
            Navigator.pop(context);
          },
        ),

        ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context)!.language),
          onTap: () async{
            // TODO: Implement language change
            Navigator.pop(context);
            final selectedLocale = await showDialog<Locale>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.selectLanguage),
                content: Column(
                  // mainAxisAlignment: MainAxisAlignment.min,
                  children: [
                    ListTile(
                      title: const Text('English'),
                      onTap: () => Navigator.pop(context, const Locale('en')),
                    ),

                    ListTile(
                      title: const Text('አማርኛ'),
                      onTap: () => Navigator.pop(context, const Locale('am'))
                    )
                  ],
                ),
              )
            );

            if (selectedLocale != null){
              Provider.of<LocaleProvider>(context, listen: false).setLocale(selectedLocale);
            }
          },
        ),

        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(AppLocalizations.of(context)!.logout),
          onTap: () async{
            driverProvider.clearUserData();
            Navigator.pushNamedAndRemoveUntil(context, "/signin", (route) => false);
          },
        )
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  driverProvider = Provider.of<DriverProvider>(context, listen: false);
  _driverData = driverProvider.driverData!;

  return Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context)!.hawir),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 74, 235, 80),
    ),
    drawer: settingDrawer(),
    body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF37474F), Color(0xFF263238)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  profileSection(),
                  const SizedBox(height: 40),
                  Text(
                    AppLocalizations.of(context)!.currentTravels,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey[500], height: 2, thickness: 1),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: !setup
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : (currentTravels.isNotEmpty
                            ? ListView.separated(
                                physics: const NeverScrollableScrollPhysics(), // Prevents conflict with SingleChildScrollView
                                shrinkWrap: true, // Important!
                                itemCount: currentTravels.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final travel = currentTravels[index];
                                  final remFormat = formatHumanFriendlyTime(travel.departureTime);
                                  return currentTravelsWidget(
                                    travel.id,
                                    travel.startLocation,
                                    travel.destinationLocation,
                                    travel.busID,
                                    remFormat,
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noCurrentTravels,
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}


class Travel {
  final String id;
  final String startLocation;
  final String destinationLocation;
  final String busID;
  final DateTime departureTime;

  Travel({
    required this.id,
    required this.startLocation,
    required this.destinationLocation,
    required this.departureTime,
    required this.busID,
  });

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'],
      startLocation: json['start_location'],
      destinationLocation: json['destination'],
      departureTime: json['planned_start_time'],
      busID: json['bus_ref'],
    );
  }
}
