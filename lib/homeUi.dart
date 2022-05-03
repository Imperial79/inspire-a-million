import 'dart:ui';
import 'package:blog_app/blogCard.dart';
import 'package:blog_app/colors.dart';
import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/myProfileUi.dart';
import 'package:blog_app/searchui.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeUi extends StatefulWidget {
  const HomeUi({Key? key}) : super(key: key);

  @override
  State<HomeUi> createState() => _HomeUiState();
}

class _HomeUiState extends State<HomeUi> with WidgetsBindingObserver {
  String selectedScreen = 'home';
  List followingUsers = [];
  List followers = [];
  Stream? blogStream;
  DocumentSnapshot<Map<String, dynamic>>? users;
  bool dark = false;
  String tokenId = '';

  @override
  void initState() {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    WidgetsBinding.instance!.addObserver(this);
    onPageLoad();
    getFollowingUsersPosts();
    super.initState();
    getTokenID();
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
    if (state == AppLifecycleState.resumed) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Userdetails.uid)
          .update({"active": "1"});
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Userdetails.uid)
          .update({"active": "0"});
    }
    super.didChangeAppLifecycleState(state);
  }

  onPageLoad() async {
    if (Userdetails.userName == '') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Userdetails.userName = prefs.getString('USERNAMEKEY')!;
      Userdetails.userEmail = prefs.getString('USEREMAILKEY')!;
      Userdetails.uid = prefs.getString('USERKEY')!;
      Userdetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
      Userdetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;
      Userdetails.myTokenId = prefs.getString('TOKENID')!;
      setState(() {});
      print(Userdetails.userEmail.split('@')[0]);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Userdetails.uid)
        .update({"active": "1"});
  }

  getFollowingUsersPosts() async {
    await DatabaseMethods().getUsersIAmFollowing().then((value) {
      setState(() {
        users = value;
        followingUsers = users!.data()!['following'];
        followers = users!.data()!['followers'];
        followingUsers.add(FirebaseAuth.instance.currentUser!.uid);

        print('followers --------- ' + followers.toString());
        DatabaseMethods().getBlogs(followingUsers).then((value) {
          blogStream = value;
        });
      });
    });
    getFollowersToken();
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
            print('Followers TokenId ------- ' + user.docs[i]['tokenId']);
            followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          followersTokenId = [];
          print('No followers thus no tokenID');
        }
        // print('Followers TokenId ------- ' + followersTokenId.toString());

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        // statusBarBrightness: Brightness.light,
        statusBarIconBrightness:
            isDarkMode! ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        // systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: RefreshIndicator(
        strokeWidth: 2,
        onRefresh: () {
          return getFollowingUsersPosts();
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                isDarkMode!
                    ? 'lib/assets/image/darkBack.jpg'
                    : 'lib/assets/image/back.jpg',
              ),
              fit: BoxFit.cover,
              opacity: 0.7,
              colorFilter: ColorFilter.mode(
                isDarkMode!
                    ? Colors.black.withOpacity(0.25)
                    : Colors.white.withOpacity(0.1),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    if (selectedScreen == 'home') Home(),
                    if (selectedScreen == 'create') CreateBlogUi(),
                    if (selectedScreen == 'profile') MyProfileUi(),
                  ],
                ),
              ),
              BuildnavigationBar(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BuildnavigationBar(),
    );
  }

  Widget Home() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // sendNotification(
                    //   [Userdetails.myTokenId],
                    //   'You\'ve Clicked on !nspire',
                    //   '!nspire',
                    //   inspireLogoUrl,
                    // ).whenComplete(() =>
                    //     print('Notification has been Sent'));
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Text(
                      '!nspire',
                      style: GoogleFonts.josefinSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                        color: isDarkMode!
                            ? Colors.grey.shade300
                            : isDarkMode!
                                ? Colors.blue.shade100
                                : primaryColor,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    PageRouteTransition.effect = TransitionEffect.rightToLeft;
                    PageRouteTransition.push(context, SearchUi()).then((value) {
                      setState(() {
                        getFollowingUsersPosts();
                      });
                    });
                  },
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2,
                        sigmaY: 2,
                      ),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundColor: isDarkMode!
                            ? Colors.blue.shade900
                            : Colors.blue.withOpacity(0.2),
                        child: SvgPicture.asset(
                          'lib/assets/icons/search.svg',
                          height: 15,
                          color: isDarkMode!
                              ? primaryAccentColor
                              : isDarkMode!
                                  ? Colors.blue.shade100
                                  : primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      'Latest Blogs',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  StreamBuilder<dynamic>(
                    stream: blogStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length == 0) {
                          return Container();
                        }
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds = snapshot.data.docs[index];
                            return BlogCard(snap: ds);
                          },
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: isDarkMode!
                                ? Colors.blue.shade100
                                : primaryColor,
                            strokeWidth: 1.6,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildnavigationBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(bottom: 13, top: 7),
          // height: 67,
          decoration: BoxDecoration(
            color: isDarkMode!
                ? Colors.grey.shade900.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
          ),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BuildNavBarButtons(label: 'home'),
              BuildNavBarButtons(label: 'create'),
              BuildNavBarButtons(label: 'profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget BuildNavBarButtons({final label}) {
    return MaterialButton(
      onPressed: () {
        getFollowingUsersPosts();
        setState(() {
          selectedScreen = label;
        });
      },
      color: selectedScreen == label
          ? isDarkMode!
              ? Colors.grey.shade800.withOpacity(0.5)
              : primaryAccentColor.withOpacity(0.9)
          : Colors.transparent,
      highlightElevation: 0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selectedScreen == label
              ? isDarkMode!
                  ? Colors.grey.shade600
                  : primaryColor
              : Colors.transparent,
        ),
      ),
      child: Text(
        label == 'home'
            ? 'HOME'
            : label == 'create'
                ? 'BLOG!'
                : 'ME',
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.w800,
          color: selectedScreen == label
              ? isDarkMode!
                  ? Colors.blue.shade100
                  : primaryColor
              : isDarkMode!
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
        ),
      ),
    );
  }
}
