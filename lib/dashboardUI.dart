import 'package:animations/animations.dart';
import 'package:blog_app/Home%20Screen/exploreUI.dart';
import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/communityListUI.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/animated_indexed_stack.dart';
import 'package:blog_app/utilities/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'Profile_Screen/myProfileUi.dart';
import 'utilities/constants.dart';

DocumentSnapshot<Map<String, dynamic>>? users;

class DashboardUI extends StatefulWidget {
  DashboardUI({Key? key}) : super(key: key);

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI> {
  int activeTab = 0;
  String tokenId = '';

  @override
  void initState() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    super.initState();
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
            Global.followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          Global.followersTokenId = [];
        }

        setState(() {});
      });
    }
  }

  getMyTokenID() async {
    var status = await OneSignal.shared.getDeviceState();
    tokenId = status!.userId!;
    // print('My Token ID ---> ' + tokenId);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.uid)
        .update({'tokenId': tokenId});

    Userdetails.myTokenId = tokenId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDarkMode ? Colors.grey.shade900 : Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: SafeArea(
        top: false,
        child: getBody(),
      ),
      bottomNavigationBar: getBottomNavBar(),
    );
  }

  List<Widget> view = [
    ExploreUI(),
    CreateBlogUi(),
    CommunityListUI(),
    MyProfileUi(),
  ];

  Widget getBody() {
    return AnimatedIndexedStack(
      index: activeTab,
      children: view,
    );

    // return PageTransitionSwitcher(
    //   duration: Duration(milliseconds: 400),
    //   transitionBuilder: (
    //     Widget child,
    //     Animation<double> animation,
    //     Animation<double> secondaryAnimation,
    //   ) {
    //     return FadeThroughTransition(
    //       animation: animation,
    //       secondaryAnimation: secondaryAnimation,
    //       child: child,
    //     );
    //   },
    //   child: view[activeTab],
    // );
    // return IndexedStack(
    //   index: activeTab,
    //   children: [
    //     ExploreUI(),
    //     CreateBlogUi(),
    //     SearchBlogsUI(),
    //     MyProfileUi(),
    //   ],
    // );
  }

  Widget getBottomNavBar() {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      type: BottomNavigationBarType.shifting,
      currentIndex: activeTab,
      selectedItemColor: isDarkMode ? primaryAccentColor : Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      selectedIconTheme: IconThemeData(size: 28),
      onTap: (value) {
        setState(() => activeTab = value);
      },
      items: [
        BottomNavigationBarItem(
          label: 'Explore',
          icon: Icon(Icons.explore_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Blog!',
          icon: Icon(Icons.edit_note_rounded),
        ),
        BottomNavigationBarItem(
          label: 'Community',
          icon: Icon(Icons.group),
        ),
        BottomNavigationBarItem(
          label: 'Profile',
          icon: Icon(Icons.person),
        ),
      ],
    );
  }
}
