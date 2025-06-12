import 'package:driver/dashboard.dart';
import 'package:driver/profile.dart';
import 'package:driver/track.dart';
import 'package:flutter/material.dart';
import 'providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MainScreen extends StatefulWidget{
  @override
  State<MainScreen> createState(){
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen>{
  // int selectedIndex = 0;
  List<Widget> screens = [];

  @override
  Widget build(BuildContext context){
      final navProvider = Provider.of<NavigationProvider>(context);
      final currentIndex = navProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          Dashboard(), 
          Profile(), 
          Track()
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        onTap: (index){
          setState(() {
            navProvider.setIndex(index);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context)!.home),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppLocalizations.of(context)!.profile),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: AppLocalizations.of(context)!.trackBus),
        ],
        currentIndex: currentIndex,
      )
    );
  }
}