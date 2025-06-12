import 'package:driver/locale_provider.dart';
import 'package:driver/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:driver/signin.dart';
// import 'package:driver/dashboard.dart';
import 'package:driver/track.dart';
import 'package:driver/tripcompletion.dart';
import 'package:driver/profile.dart';
import 'package:driver/changepassword.dart';

import 'package:provider/provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/driver_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'generated/l10n.dart'; // generated localization file

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()..loadDriverData()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('am'),
        ],
        locale: localeProvider.locale,
        initialRoute: "/signin",
        routes: {
          "/signin" : (context) => Signin(),
          "/main": (context) => MainScreen(),
          "/profile" : (context) => Profile(),
          "/track" : (context) => Track(),
          "/tripcompletion" : (context) => TripCompletion(),
          "/changepassword" : (context) => ChangePassword(),
        }
      );

  }
}

