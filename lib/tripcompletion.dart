import 'package:driver/providers/navigation_provider.dart';
import 'package:driver/sections/appBar.dart';
import 'package:driver/tracking_controller.dart';
import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class TripCompletion extends StatelessWidget {
  const TripCompletion({super.key});

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("Trip Completed"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[600],
              ),

              const SizedBox(height: 20),

              Text(
                "Trip Completed!",
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: const Color.fromARGB(255, 117, 105, 104), size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Time Taken",
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            formatDuration(BusTrackingService().getCurrentElapsedTime()), // Replace with dynamic time
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Provider.of<NavigationProvider>(context, listen: false).setIndex(0); // Go back or to the home screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Back to Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
