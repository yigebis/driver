
import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Row CurrentTravels(bool isNow){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          // alignment: Alignment(0, 0),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          color: Colors.green,
          child: Text("Hawassa", style: TextStyle(color: Colors.white),),
          
        ),

        isNow ? ElevatedButton(
          onPressed: (){
            Navigator.pushNamed(context, "/track");
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(10),
            backgroundColor: Colors.red, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text("Start Tracking", style: TextStyle(color: Colors.white),),

        ) : Container(
          // alignment: Alignment(0, 0),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          color: const Color.fromARGB(255, 100, 117, 100),
          child: Text("2 mins", style: TextStyle(color: Colors.white),),
          
        ),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("Driver Dashboard"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, "/profile");
                  }, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: CircleBorder()),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.amber[800],
                        child: Text("Y"),
                      ),
                    ],
                  )
                ),

                // Text("My Profile"),
                
                SizedBox(height: 60.0),
                
                Expanded(
                  flex: 9,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: <Widget>[
                      Text("Current Travels"),
                      SizedBox(height: 8.0),
                      Divider(color: Colors.grey[500], height: 2.0),
                      SizedBox(height: 20,),
                      Container(
                        color: Colors.blue[200],
                        height: 100,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CurrentTravels(true),
                        ),
                      )
                    ],
                  ),
                )
            
              ],
            ),
          )
        ),
      )
    );
  }
}