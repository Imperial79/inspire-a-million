import 'package:blog_app/Home%20Screen/exploreUI.dart';
import 'package:blog_app/createBlogUi.dart';
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

class _DashboardUIState extends State<DashboardUI> with WidgetsBindingObserver {
  String selectedScreen = 'home';
  int activeTab = 0;

  // bool dark = false;
  String tokenId = '';

  @override
  void initState() {
    // print(savedScrollOffset);
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    WidgetsBinding.instance.addObserver(this);
    onPageLoad();
    // getFollowingUsersPosts();
    super.initState();
    getTokenID();
  }

  // Future<void> getFollowingUsersPosts() async {
  //   await DatabaseMethods().getUsersIAmFollowing().then((value) {
  //     setState(() {
  //       users = value;
  //       followingUsers = users!.data()!['following'];
  //       followers = users!.data()!['followers'];
  //       followingUsers.add(FirebaseAuth.instance.currentUser!.uid);

  //       print('followers --------- ' + followers.toString());
  //       DatabaseMethods().getBlogs(followingUsers).then((value) {
  //         blogStream = value;
  //       });
  //     });
  //   });
  //   getFollowersToken();
  // }

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
            print('Followers TokenId ------- ' + user.docs[i]['tokenId']);
            Global.followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          Global.followersTokenId = [];
          print('No followers thus no tokenID');
        }
        // print('Followers TokenId ------- ' + followersTokenId.toString());

        setState(() {});
      });
    }
  }

  getTokenID() async {
    var status = await OneSignal.shared.getDeviceState();
    tokenId = status!.userId!;
    print('My Token ID ---> ' + tokenId);

    FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.uid)
        .update({'tokenId': tokenId});

    Userdetails.myTokenId = tokenId;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (Userdetails.userEmail.isNotEmpty) {
      if (state == AppLifecycleState.resumed) {
        print(
            'Observing ' + Userdetails.userName + ' and setting it to ONLINE');
        await FirebaseFirestore.instance
            .collection("users")
            .doc(Userdetails.uid)
            .update({"active": "1"});
      } else {
        print(
            'Observing ' + Userdetails.userName + ' and setting it to OFFLINE');
        await FirebaseFirestore.instance
            .collection("users")
            .doc(Userdetails.uid)
            .update({"active": "0"});
      }
      super.didChangeAppLifecycleState(state);
    } else {
      print('Not Observing ' + Userdetails.userName);
      // await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(Userdetails.uid)
      //     .update({"active": "0"});
    }
  }

  onPageLoad() async {
    if (Userdetails.userName == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Userdetails.userName = prefs.getString('USERNAMEKEY')!;
      Userdetails.userEmail = prefs.getString('USEREMAILKEY')!;
      Userdetails.uid = prefs.getString('USERKEY')!;
      Userdetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
      Userdetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;
      // Userdetails.myTokenId = prefs.getString('TOKENID')!;
      setState(() {});
      // print(Userdetails.userEmail.split('@')[0]);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Userdetails.uid)
        .update({"active": "1"});
  }

  // Future<void> getFollowingUsersPosts() async {
  //   await DatabaseMethods().getUsersIAmFollowing().then((value) {
  //     setState(() {
  //       users = value;
  //       followingUsers = users!.data()!['following'];
  //       followers = users!.data()!['followers'];
  //       followingUsers.add(FirebaseAuth.instance.currentUser!.uid);

  //       print('followers --------- ' + followers.toString());
  //       DatabaseMethods().getBlogs(followingUsers).then((value) {
  //         blogStream = value;
  //       });
  //     });
  //   });
  //   getFollowersToken();
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
      body: Container(
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(
            //     isDarkMode!
            //         ? 'lib/assets/image/darkBack.jpg'
            //         : 'lib/assets/image/back.jpg',
            //   ),
            //   fit: BoxFit.cover,
            //   opacity: isDarkMode! ? 1 : 0.7,
            //   colorFilter: ColorFilter.mode(
            //     isDarkMode!
            //         ? Colors.black.withOpacity(0.5)
            //         : Colors.white.withOpacity(0.1),
            //     BlendMode.darken,
            //   ),
            // ),
            ),
        child: getBody(),
      ),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: activeTab,
      children: [
        ExploreUI(),
        CreateBlogUi(),
        MyProfileUi(),
        // SettingsUI(),
      ],
    );
  }

  Widget getFooter() {
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

  Widget _buildBottomBar(List<Widget> items) {
    return NavigationBar(
      elevation: 0,
      onDestinationSelected: (int index) {
        setState(() {
          activeTab = index;
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
