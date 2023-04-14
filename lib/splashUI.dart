import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:blog_app/dashboardUI.dart';
import 'package:blog_app/screens/Home%20Screen/exploreUI.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utilities/colors.dart';

class SplashUI extends StatefulWidget {
  const SplashUI({Key? key}) : super(key: key);

  @override
  State<SplashUI> createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> {
  String tokenId = '';

  @override
  void initState() {
    super.initState();
    onPageLoad();
    getMyTokenID();
  }

  onPageLoad() async {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    if (Userdetails.uniqueName == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Userdetails.uniqueName = prefs.getString('USERNAMEKEY')!;
      Userdetails.userEmail = prefs.getString('USEREMAILKEY')!;
      Userdetails.uid = prefs.getString('USERKEY')!;
      Userdetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
      Userdetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;

      setState(() {});
    }

    await DatabaseMethods().setUserOnline();
    await updateFollowingUsersList();
    getFollowersToken();
    NavPushReplacement(context, DashboardUI());
  }

  getFollowersToken() async {
    ///////////////  GETTING FOLLOWER'S TOKEN ID LIST //////////////////////////////

    if (followers.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: followers)
          .get()
          .then((user) {
        if (user.size > 0) {
          for (int i = 0; i < user.size; i++) {
            // print('Followers TokenId ------- ' + user.docs[i]['tokenId']);
            Global.followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          Global.followersTokenId = [];
        }

        // setState(() {});
      });
    }
  }

  getMyTokenID() async {
    var status = await OneSignal.shared.getDeviceState();
    tokenId = status!.userId!;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.uid)
        .update({'tokenId': tokenId});

    Userdetails.myTokenId = tokenId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemColors(
      statusColor: transparentColor,
      navColor: transparentColor,
    );
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Splash Screen',
              cursor: ' |',
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? primaryAccentColor : primaryColor,
              ),
            ),
          ],
          totalRepeatCount: 100,
          displayFullTextOnTap: true,
          stopPauseOnTap: true,
        ),
      ),
    );
  }
}
