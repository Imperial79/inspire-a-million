import 'dart:ui';
import 'package:blog_app/blogCard.dart';
import 'package:blog_app/colors.dart';
import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/myProfileUi.dart';
import 'package:blog_app/searchui.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Stream? blogStream;
  DocumentSnapshot<Map<String, dynamic>>? users;

  @override
  void initState() {
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    WidgetsBinding.instance!.addObserver(this);
    onPageLoad();
    getFollowingUsersPosts();
    super.initState();
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
        followingUsers.add(FirebaseAuth.instance.currentUser!.uid);
        print('followingUsers --------- ' + followingUsers.toString());
        DatabaseMethods().getBlogs(followingUsers).then((value) {
          blogStream = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness:
            isDarkMode! ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor:
            isDarkMode! ? Colors.grey.shade900 : Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
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
          child: SafeArea(
            child: Column(
              children: [
                if (selectedScreen == 'home')
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, top: 10, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isDarkMode = !isDarkMode!;
                                  });
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
                                  PageRouteTransition.effect =
                                      TransitionEffect.rightToLeft;
                                  PageRouteTransition.push(context, SearchUi())
                                      .then((value) {
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
                                  padding:
                                      EdgeInsets.only(left: 20, bottom: 10),
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
                                          DocumentSnapshot ds =
                                              snapshot.data.docs[index];
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedScreen == 'create') CreateBlogUi(),
                if (selectedScreen == 'profile') MyProfileUi(),
                // MediaQuery.of(context).viewInsets.bottom != 0
                //     ? Container()
                //     : BuildnavigationBar(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BuildnavigationBar(),
    );
  }

  Widget BuildnavigationBar() {
    return Container(
      height: 67,
      decoration: BoxDecoration(
        color: isDarkMode! ? Colors.grey.shade900 : Colors.white,
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
    );
  }

  Widget BuildNavBarButtons({final label}) {
    return MaterialButton(
      onPressed: () {
        setState(() {
          selectedScreen = label;
          if (label == 'HOME') getFollowingUsersPosts();
        });
      },
      color: selectedScreen == label
          ? isDarkMode!
              ? Colors.grey.shade800.withOpacity(0.5)
              : primaryAccentColor.withOpacity(0.5)
          : Colors.transparent,
      highlightElevation: 0,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
