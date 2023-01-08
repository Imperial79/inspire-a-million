import 'package:blog_app/splashUI.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/loginUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyC8UbFIY5MVEqyHWUfKrYRlHc7b-gWzJEw",
      appId: "1:49563021670:android:69a801980d4057170c98a7",
      messagingSenderId: "49563021670",
      projectId: "blogged---blog-app",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    configOneSignel();
  }

  void configOneSignel() {
    OneSignal.shared.setAppId(Global.appId); //Uses the appId from OneSignal
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: '!nspire',
      color: Colors.grey.shade100,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        scaffoldBackgroundColor: scaffoldDarkColor,
        brightness: Brightness.dark,
        fontFamily: 'Product',
      ),
      theme: ThemeData(
        useMaterial3: true,
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: Colors.white),
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: scaffoldLightColor,
        fontFamily: 'Product',
        snackBarTheme: SnackBarTheme(),
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SplashUI();
          } else {
            return LoginUi();
          }
        },
      ),
    );
  }
}
