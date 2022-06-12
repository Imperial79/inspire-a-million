import 'package:blog_app/colors.dart';
import 'package:blog_app/dashboardUI.dart';
import 'package:blog_app/loginUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        scaffoldBackgroundColor: Colors.grey.shade900,
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
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
