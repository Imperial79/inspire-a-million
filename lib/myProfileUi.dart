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
import 'package:google_fonts/google_fonts.dart';
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
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: isDarkMode!
                            ? Colors.blue.shade400
                            : isDarkMode!
                                ? Colors.blue.shade100
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
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        ds['name'],
                        style: GoogleFonts.openSans(
                          color: isDarkMode! ? Colors.white : Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                      ),
                      Text(
                        '@' + ds['username'],
                        style: GoogleFonts.openSans(
                          color:
                              isDarkMode! ? Colors.blue.shade100 : primaryColor,
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
                        style: GoogleFonts.openSans(
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
                    ],
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      children: [
                        StreamBuilder<dynamic>(
                          stream: FirebaseFirestore.instance
                              .collection('blogs')
                              .where('uid',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
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
                                ));
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: MaterialButton(
                        onPressed: () async {
                          AuthMethods().signOut();
                          PageRouteTransition.effect =
                              TransitionEffect.leftToRight;
                          PageRouteTransition.pushReplacement(
                              context, LoginUi());
                        },
                        elevation: 0,
                        highlightElevation: 0,
                        color: isDarkMode! ? Colors.red.shade100 : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 14,
                          ),
                          child: FittedBox(
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w700,
                                color: isDarkMode!
                                    ? Colors.red.shade800
                                    : Colors.white,
                              ),
                            ),
                          ),
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
              color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
              strokeWidth: 1.6,
            ),
          );
        },
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
                      ? Colors.blue.shade100
                      : primaryColor.withOpacity(0.1),
              // borderRadius: BorderRadius.circular(15),
              borderRadius: count == '0'
                  ? BorderRadius.circular(10)
                  : BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
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
                                style: GoogleFonts.openSans(
                                  color: isDarkMode!
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w900,
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
                                    style: GoogleFonts.openSans(
                                      color: isDarkMode!
                                          ? Colors.blue.shade100
                                          : primaryColor.withOpacity(0.7),
                                      fontWeight: FontWeight.w900,
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
                                    style: GoogleFonts.openSans(
                                      color: isDarkMode!
                                          ? Colors.blue.shade100
                                              .withOpacity(0.7)
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
                    : Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: press,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 43),
                            // width: 20,
                            // height: 110,
                            decoration: BoxDecoration(
                              color: isDarkMode!
                                  ? Colors.blue.shade900
                                  : isDarkMode!
                                      ? Colors.blue.shade100
                                      : primaryColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            // padding: EdgeInsets.all(20),
                            // width: 100,
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 14,
                              ),
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
