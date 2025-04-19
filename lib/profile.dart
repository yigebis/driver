import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  var languageList = ["አማርኛ", "English"];
  var calendarList = ["የኢትዮጵያ", "Gregorian"];
  String selectedLanguage = "አማርኛ";
  String selectedCalendar = "የኢትዮጵያ";

  Row profileField(String key, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),
        Text(value, style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.normal,
          color: Colors.grey[700]
        ),)
      ],
    );
  }

  Row selectionField(String key, selectedType, List<String> typeList){
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12), // 🎯 rounded corners
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              hint: Text(selectedType),
              // style: DropdownButton,
              items: typeList.map((String value) {
                return DropdownMenuItem<String>(value : value, child: Text(value));
              }).toList(),
              onChanged: (String? x){
                setState(() {
                  key == "Language" ? selectedLanguage = x! : selectedCalendar = x!;
                });
              },
            ),
          ),
        ),
    ],);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("My Profile"),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              child: Text("Y"),
            ),
            SizedBox(height: 30,),

            profileField("Name", "Abebe Migbar"),
            SizedBox(height : 16),

            profileField("Date of Birth", "Jun 21, 2000"),
            SizedBox(height : 16),

            profileField("Gender", "Male"),
            SizedBox(height : 16),

            profileField("Email", "abekebe@gmail.com"),
            SizedBox(height : 16),

            selectionField("Language", selectedLanguage, languageList),
            SizedBox(height : 16),

            selectionField("Calendar", selectedCalendar, calendarList),
            SizedBox(height : 16),

            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, "/changepassword");
              },
              child: Text("Change Password"),
            ),
          ],
        ),
      )
    );
  }
}