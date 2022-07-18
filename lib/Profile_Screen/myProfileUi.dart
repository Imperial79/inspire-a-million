import 'dart:ui';
import 'package:blog_app/colors.dart';
import 'package:blog_app/loginUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_route_transition/page_route_transition.dart';

import '../blogCard.dart';
import 'inspiredUi.dart';
import 'motivatorUi.dart';

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<dynamic>(
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
                              backgroundColor: isDarkMode!
                                  ? Colors.black
                                  : Colors.grey.shade200,
                              child: CircleAvatar(
                                backgroundColor: isDarkMode!
                                    ? Colors.transparent
                                    : Colors.grey.shade100,
                                radius: 39,
                                child: Hero(
                                  tag: ds['imgUrl'],
                                  child: CachedNetworkImage(
                                    imageUrl: ds['imgUrl'],
                                    imageBuilder: (context, image) =>
                                        CircleAvatar(
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
                              color: isDarkMode!
                                  ? primaryAccentColor
                                  : primaryColor,
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
                          Row(
                            children: [
                              StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('blogs')
                                    .where('uid', isEqualTo: Userdetails.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return StatsCard(
                                      count: '0',
                                      label: 'Inspirations',
                                      press: () {},
                                    );
                                  }

                                  return StatsCard(
                                    count: snapshot.data.docs.length.toString(),
                                    label: 'Inspirations',
                                    press: () {},
                                  );
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StatsCard(
                                press: () {
                                  PageRouteTransition.effect =
                                      TransitionEffect.topToBottom;
                                  PageRouteTransition.push(
                                      context,
                                      InspiredUi(
                                        snap: ds,
                                        my: true,
                                      ));
                                },
                                count: ds['followers'].length.toString(),
                                label: 'Inspired',
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StatsCard(
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
                                count: ds['following'].length.toString(),
                                label: 'Motivators',
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
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
              BlogList(
                  isMe: true,
                  name: Userdetails.userDisplayName,
                  uid: Userdetails.uid),
            ],
          ),
        ),
      ),
    );
  }

  Widget CustomBtn(BuildContext context,
      {final label, textColor, btnColor, press, splashColor}) {
    return Expanded(
      child: InkWell(
        splashColor: splashColor,
        onTap: press,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: btnColor,
          ),
          child: FittedBox(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: textColor,
                fontSize: 20,
                fontFamily: 'default',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
