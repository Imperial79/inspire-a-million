import 'dart:ui';
import 'package:blog_app/colors.dart';
import 'package:blog_app/inspiredUi.dart';
import 'package:blog_app/loginUi.dart';
import 'package:blog_app/motivatorUi.dart';
import 'package:blog_app/myBlogsUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';

class MyProfileUi extends StatefulWidget {
  const MyProfileUi({Key? key}) : super(key: key);

  @override
  State<MyProfileUi> createState() => _MyProfileUiState();
}

class _MyProfileUiState extends State<MyProfileUi> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Expanded(
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              DocumentSnapshot ds = snapshot.data.docs[0];
              return Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: isDarkMode!
                          ? Colors.blue.shade400
                          : isDarkMode!
                              ? primaryAccentColor
                              : primaryColor,
                      child: CircleAvatar(
                        radius: 43,
                        backgroundColor:
                            isDarkMode! ? Colors.black : Colors.grey.shade200,
                        child: CircleAvatar(
                          backgroundColor: isDarkMode!
                              ? Colors.transparent
                              : Colors.grey.shade100,
                          radius: 39,
                          child: Hero(
                            tag: ds['imgUrl'],
                            child: CachedNetworkImage(
                              imageUrl: ds['imgUrl'],
                              imageBuilder: (context, image) => CircleAvatar(
                                radius: 39,
                                backgroundImage: image,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      ds['name'],
                      style: TextStyle(
                        color: isDarkMode! ? Colors.white : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      '@' + ds['username'],
                      style: TextStyle(
                        color: isDarkMode! ? primaryAccentColor : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      ds['email'],
                      style: TextStyle(
                        color: isDarkMode!
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      // flex: 5,
                      child: Column(
                        children: [
                          StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('blogs')
                                .where('uid', isEqualTo: Userdetails.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return BuildStatsCard(
                                  count: '0',
                                  label: 'Inspirations',
                                  press: () {},
                                );
                              }

                              return BuildStatsCard(
                                count: snapshot.data.docs.length.toString(),
                                label: 'Inspirations',
                                press: () {
                                  PageRouteTransition.effect =
                                      TransitionEffect.topToBottom;
                                  PageRouteTransition.push(
                                      context,
                                      MyBlogsUi(
                                        snap: ds,
                                        my: true,
                                      ));
                                },
                              );
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          BuildStatsCard(
                            count: ds['followers'].length.toString(),
                            label: 'Inspired',
                            press: () {
                              PageRouteTransition.effect =
                                  TransitionEffect.topToBottom;
                              PageRouteTransition.push(
                                  context,
                                  InspiredUi(
                                    snap: ds,
                                  ));
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          BuildStatsCard(
                            count: ds['following'].length.toString(),
                            label: 'Motivators',
                            press: () {
                              PageRouteTransition.effect =
                                  TransitionEffect.topToBottom;
                              PageRouteTransition.push(
                                context,
                                MotivatorUi(
                                  snap: ds,
                                  from: 'me',
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        AuthMethods().signOut();
                        PageRouteTransition.effect =
                            TransitionEffect.leftToRight;
                        PageRouteTransition.pushReplacement(context, LoginUi());
                      },
                      elevation: 0,
                      highlightElevation: 0,
                      color: isDarkMode!
                          ? Colors.red.withOpacity(0.5)
                          : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: isDarkMode!
                                ? Colors.red.shade100
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(
                color: isDarkMode! ? primaryAccentColor : primaryColor,
                strokeWidth: 1.6,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget BuildStatsCard({final label, final count, final press}) {
    return Expanded(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            width: double.infinity,
            padding: count == '0'
                ? EdgeInsets.symmetric(vertical: 15)
                : EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: isDarkMode!
                  ? Colors.grey.withOpacity(0.2)
                  : isDarkMode!
                      ? primaryAccentColor
                      : primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              child: Text(
                                count,
                                style: TextStyle(
                                  color: isDarkMode!
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 45,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isDarkMode!
                                          ? primaryAccentColor
                                          : primaryColor.withOpacity(0.7),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                FittedBox(
                                  child: Text(
                                    label == 'Inspirations'
                                        ? 'Blogs'
                                        : label == 'Inspired'
                                            ? 'Followers'
                                            : 'Following',
                                    style: TextStyle(
                                      color: isDarkMode!
                                          ? primaryAccentColor.withOpacity(0.7)
                                          : primaryColor.withOpacity(0.5),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                count == '0'
                    ? Container()
                    : InkWell(
                        onTap: press,
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
                          ),
                          child: RotatedBox(
                            quarterTurns: 90,
                            child: SvgPicture.asset(
                              'lib/assets/icons/back.svg',
                              color: isDarkMode! ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
