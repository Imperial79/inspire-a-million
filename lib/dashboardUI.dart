import 'package:blog_app/Home%20Screen/exploreUI.dart';
import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/searchBlogsUI.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Profile_Screen/myProfileUi.dart';

DocumentSnapshot<Map<String, dynamic>>? users;

class DashboardUI extends StatefulWidget {
  DashboardUI({Key? key}) : super(key: key);

  @override
  State<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends State<DashboardUI>
    with SingleTickerProviderStateMixin {
  // String selectedScreen = 'home';
  int activeTab = 0;

  String tokenId = '';

  late TabController tabController;

  @override
  void initState() {
    print('Dashboard');
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    // onPageLoad();
    super.initState();
    // getTokenID();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
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
          // print('No followers thus no tokenID');
        }
        // print('Followers TokenId ------- ' + followersTokenId.toString());

        setState(() {});
      });
    }
  }

  getMyTokenID() async {
    var status = await OneSignal.shared.getDeviceState();
    tokenId = status!.userId!;
    // print('My Token ID ---> ' + tokenId);

    FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.uid)
        .update({'tokenId': tokenId});

    Userdetails.myTokenId = tokenId;
    setState(() {});
  }

  // onPageLoad() async {
  //   if (Userdetails.userName == '') {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     Userdetails.userName = prefs.getString('USERNAMEKEY')!;
  //     Userdetails.userEmail = prefs.getString('USEREMAILKEY')!;
  //     Userdetails.uid = prefs.getString('USERKEY')!;
  //     Userdetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
  //     Userdetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;
  //     setState(() {});
  //   }

  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(Userdetails.uid)
  //       .update({"active": "1"});
  // }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness:
            isDarkMode! ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: SafeArea(
        top: false,
        child: getBody1(),
      ),
      bottomNavigationBar: getFooter1(),
    );
  }

  // Widget getBody2() {
  //   return TabBarView(
  //     controller: tabController,
  //     children: [
  //       ExploreUI(),
  //       CreateBlogUi(),
  //       SearchBlogsUI(),
  //       MyProfileUi(),
  //     ],
  //   );
  // }

  // Widget getFooter2() {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 10),
  //     child: TabBar(
  //       controller: tabController,
  //       indicatorPadding: EdgeInsets.zero,
  //       indicator: UnderlineTabIndicator(borderSide: BorderSide.none),
  //       labelStyle: TextStyle(fontSize: 12, height: 1.7),
  //       unselectedLabelColor: isDarkMode! ? Colors.grey : Colors.grey.shade400,
  //       labelColor: isDarkMode! ? Colors.white : Colors.black,
  //       tabs: [
  //         Tab(
  //           icon: Icon(
  //             Icons.explore,
  //             size: 26,
  //           ),
  //           text: 'Explore',
  //           iconMargin: EdgeInsets.zero,
  //         ),
  //         Tab(
  //           icon: Icon(
  //             Icons.edit,
  //             size: 26,
  //           ),
  //           text: 'Blog!',
  //           iconMargin: EdgeInsets.zero,
  //         ),
  //         Tab(
  //           icon: Icon(
  //             Icons.tag,
  //             size: 26,
  //           ),
  //           text: 'Tags',
  //           iconMargin: EdgeInsets.zero,
  //         ),
  //         Tab(
  //           icon: Icon(
  //             Icons.person,
  //             size: 26,
  //           ),
  //           text: 'Profile',
  //           iconMargin: EdgeInsets.zero,
  //         ),
  //       ],
  //     ),
  //   );
  // }

////////////////////  OLD NAVIGATION BAR CODE BELOW  ///////////////////////////

  Widget getBody1() {
    return IndexedStack(
      index: activeTab,
      children: [
        ExploreUI(),
        CreateBlogUi(),
        MyProfileUi(),
      ],
    );
  }

  Widget getFooter1() {
    final List<Widget> items = [
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Explore',
      ),
      NavigationDestination(
        icon: Icon(Icons.edit_outlined),
        selectedIcon: Icon(Icons.edit),
        label: 'Blog!',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Me',
        tooltip: 'Profile',
      ),
    ];

    return _buildBottomBar(items);
  }

  Widget NewBottomNavbar() {
    return BottomNavigationBar(
      backgroundColor: Colors.grey.shade200,
      type: BottomNavigationBarType.fixed,
      currentIndex: activeTab,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
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
          label: 'Sales',
          icon: Icon(Icons.bar_chart),
        ),
        BottomNavigationBarItem(
          label: 'Update Rate',
          icon: Icon(Icons.file_upload_outlined),
        ),
        BottomNavigationBarItem(
          label: 'Stock Entry',
          icon: Icon(Icons.edit_note),
        ),
      ],
    );
  }

  Widget _buildBottomBar(List<Widget> items) {
    return NavigationBar(
      elevation: 0,
      onDestinationSelected: (int index) {
        setState(() {
          activeTab = index;
          FocusScope.of(context).unfocus();
        });
      },
      selectedIndex: activeTab,
      height: 68,
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      animationDuration: Duration(milliseconds: 200),
      destinations: items,
    );
  }
}
