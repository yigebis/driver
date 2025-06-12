import 'dart:convert';
import 'dart:io';

import 'package:driver/constants/api_constants.dart';
import 'package:driver/sections/appBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:driver/providers/driver_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
    bool setup = false;
    String token = "";
    late DriverProvider driverProvider;
    var driverData = Map<String, dynamic>();
    File? _profileImage;
    bool _uploading = false;

  Future<void> editPhotoBackend(BuildContext context, String url) async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    String? token = driverProvider.token;

    var endPoint = Uri.parse("$BASE_URL/driver/upload");
    var response = await http.post(
      endPoint,
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"url": url}),
    );

    if (response.statusCode == 200) {
      driverProvider.updatePhoto(url);
    }
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _uploading = true;
      });

      try {
        final credentialURL = Uri.parse("$BASE_URL/driver/upload_preset");
        final credentialResponse = await http.get(
          credentialURL,
          headers: {
            "Authorization" : "Bearer $token",
            "Content-Type" : "application/json"
          },
        );

        var cloudName, uploadPreset;

        if (credentialResponse.statusCode != 200){
          return;
        }

        var decodedResponse = jsonDecode(credentialResponse.body);
        cloudName = decodedResponse["cloud_name"];
        uploadPreset = decodedResponse["upload_preset"];

        final uploadUrl = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
        final request = http.MultipartRequest('POST', uploadUrl);

        print(decodedResponse);
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(await http.MultipartFile.fromPath('file', _profileImage!.path));

        print("c");
        final response = await request.send();

        print("d");

        if (response.statusCode == 200) {
          final resBody = await response.stream.bytesToString();
          final resJson = jsonDecode(resBody);
          String imageUrl = resJson['secure_url'];
          final optimizedUrl = imageUrl.replaceFirst('/upload/', '/upload/f_auto,q_auto/');

          // Save this URL in your backend or SharedPreferences
          print("Uploaded Image URL: $optimizedUrl");
          await editPhotoBackend(context, optimizedUrl);
        } else {
          print("Upload failed: ${response.statusCode}");
        }
      } catch (e) {
        print("Error: $e");
      }

      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    driverProvider = Provider.of<DriverProvider>(context, listen: false);
    initAsync();
    setup = true;
  }

  void initAsync() async{
    if (driverProvider.driverData == null){
      await driverProvider.loadDriverData();
    }
    
    driverData = driverProvider.driverData!;
    print("c");
    token = driverProvider.token!;
  }

  // void getDriverData() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   var driverJSON = jsonDecode(prefs.getString("driver_data")!);
    
  //   setState(() {
  //     driverData = driverJSON;
  //     token = prefs.getString("access_token");
  //     setup = true;
  //   });
  // }

  String formatDate(String dateString) {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('MMM d, y').format(parsedDate);
  }

  Widget profileField(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              )),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade800,
                )),
          ),
        ],
      ),
    );
  }

  Widget selectionField(String key, String selectedType, List<String> typeList) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade700,
              )),
        ],
      ),
    );
  }

  void showPickOptionsDialog(BuildContext context){
    showModalBottomSheet(
      context: context, 
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
              onTap: (){
                Navigator.of(context).pop();
                pickAndUploadImage(ImageSource.camera);
              },
            ),

            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choose from gallery"),
              onTap: (){
                Navigator.of(context).pop();
                pickAndUploadImage(ImageSource.gallery);
              },
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: driverAppBar("My Profile"),
      backgroundColor: Color(0xFFF2F4F6),
      body: !setup
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: driverData["photo"] != null
                          ? NetworkImage(driverData["photo"])
                          : null,
                      backgroundColor: Colors.blue.shade100,
                      child: driverData["photo"] == null
                          ? Text(
                              setup ? driverData["first_name"][0].toUpperCase() : "",
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                            )
                          : null,
                    ),

                    TextButton.icon(
                      onPressed: _uploading ? null : () => showPickOptionsDialog(context),
                      icon: _uploading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(),) : Icon(Icons.camera_alt, color: Colors.blue.shade700),
                      label: Text("Edit Photo"),
                    ),


                    const SizedBox(height: 30),
                    profileField("Name", "${driverData["first_name"]} ${driverData["last_name"]}"),
                    profileField("Date of Birth", formatDate(driverData["date_of_birth"])),
                    profileField("Gender", driverData["sex"] == "M" ? "Male" : "Female"),
                    profileField("Email", driverData["email"]),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/changepassword");
                      },
                      icon: Icon(Icons.lock_reset_rounded, color: Colors.white,),
                      label: Text("Change Password", style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
