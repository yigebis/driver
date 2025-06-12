import 'package:driver/remote/bus_track.dart';
import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:driver/tracking_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class Track extends StatefulWidget {
  const Track({super.key});

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {
  static LatLng? busPosition;
  final MapController _mapController = MapController();
  final double _zoomLevel = 15;

  @override
  void initState() {
    super.initState();
    BusTrackingService().addListener(_onLocationUpdate);
  }

  void _onLocationUpdate(LatLng data) {
    setState(() {
      busPosition = data;
    });
    _mapController.move(data, _zoomLevel);
  }

  @override
  void dispose() {
    BusTrackingService().removeListener(_onLocationUpdate);
    super.dispose();
  }

  void stopTrip() async {
    bool? stopped = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmStop),
          content: Text(AppLocalizations.of(context)!.stopPrompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        );
      },
    );

    if (stopped == true) {
      BusTrackingService().close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.tripStopped)),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/tripcompletion');
      });
    }
  }

  Widget noTrips() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.tripNotSelected,
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget stopButton() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Center(
        child: ElevatedButton(
          onPressed: stopTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 6,
          ),
          child: Text(
            AppLocalizations.of(context)!.stopTrip,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar(AppLocalizations.of(context)!.trackingTitle),
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: !BusTrackingService().checkTracking()
            ? noTrips()
            : busPosition == null
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.locationWaiting,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: busPosition!,
                          initialZoom: _zoomLevel,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: busPosition!,
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.directions_bus,
                                  size: 40,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      stopButton(),
                    ],
                  ),
      ),
    );
  }
}
