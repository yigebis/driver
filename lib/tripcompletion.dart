import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';

class TripCompletion extends StatelessWidget {
  const TripCompletion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("Trip Completed"),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Trip Completed!",
              style: TextStyle(
                color: Colors.green,
                fontSize: 42,
              ),
            ),

            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  child : Text("Time Taken", style: TextStyle(color: Colors.white),),
                  color: Colors.blueGrey,
                ),
                SizedBox(width: 20,),
                Container(
                  child: Text("2:04:03", style: TextStyle(color: Colors.red, fontSize: 20),),
                  padding: EdgeInsets.all(8),
                  // color: Colors.blueGrey,
                )
              ],
            )
            
          ],
        ),
      )
    );
  }
}