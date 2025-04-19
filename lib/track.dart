import 'package:flutter/material.dart';
import 'package:driver/sections/appBar.dart';

class Track extends StatefulWidget {
  const Track({super.key});

  @override
  State<Track> createState() => _TrackState();
}

class _TrackState extends State<Track> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("Bus Tracking"),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  // alignment: Alignment(0, 0),
                  color: Colors.green,
                  child: Text("Addis Ababa", style: TextStyle(color: Colors.white),),
                ),
        
                Icon(Icons.arrow_forward),
        
                Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  // alignment: Alignment(0, 0),
                  color: Colors.green,
                  child: Text("Hawassa", style: TextStyle(color: Colors.white),),
                ),
              ],
            ),

            SizedBox(height: 8),

            Expanded(
              flex: 9,
              child: Container(
                height: 80,
                color: Colors.blueGrey,
              ),
            ),
        
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, "/tripcompletion");
              },
              child: Text("Stop Tracking"),
            )
          ],
        ),
      )
    );
  }
}