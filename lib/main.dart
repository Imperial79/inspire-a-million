import 'package:blog_app/colors.dart';
import 'package:blog_app/dashboardUI.dart';
import 'package:blog_app/loginUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/settingsUI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: '!nspire',
      color: primaryAccentColor,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        scaffoldBackgroundColor: scaffoldDarkColor,
        // scaffoldBackgroundColor: Color(0xFF003038),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: scaffoldLightColor,
        // fontFamily: 'Product',
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
        // pageTransitionsTheme: const PageTransitionsTheme(
        //   builders: {
        //     TargetPlatform.android: ZoomPageTransitionsBuilder(),
        //   },
        // ),
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DashboardUI();
          } else {
            return LoginUi();
          }
        },
      ),
    );
  }
}
