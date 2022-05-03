import 'dart:ui';

import 'package:blog_app/colors.dart';
import 'package:blog_app/inspiredUi.dart';
import 'package:blog_app/motivatorUi.dart';
import 'package:blog_app/myBlogsUi.dart';
import 'package:blog_app/services/auth.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';

class OthersProfileUi extends StatefulWidget {
  final uid;
  OthersProfileUi({
    required this.uid,
  });

  @override
  _OthersProfileUiState createState() => _OthersProfileUiState();
}

class _OthersProfileUiState extends State<OthersProfileUi> {
  // QuerySnapshot<Map<String, dynamic>>? thisUser;
  Stream? followStream;
  List followersList = [];
  List? followingList;
  String postCount = '0';
  QuerySnapshot<Map<String, dynamic>>? postData;

  @override
  void initState() {
    onPageLoad();
    super.initState();
  }

  onFollowButtonClick(final ds) async {
    if (ds['followers'].contains(Userdetails.uid)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ds['uid'])
          .update({
        'followers': FieldValue.arrayRemove([Userdetails.uid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(Userdetails.uid)
          .update({
        'following': FieldValue.arrayRemove([ds['uid']])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ds['uid'])
          .update({
        'followers': FieldValue.arrayUnion([Userdetails.uid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(Userdetails.uid)
          .update({
        'following': FieldValue.arrayUnion([ds['uid']])
      });
    }
  }

  onPageLoad() async {
    //TODO
    await DatabaseMethods().getFollowersAndFollowing(widget.uid).then((value) {
      setState(() {
        followStream = value;
      });
    });
    await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get()
        .then((value) {
      setState(() {
        postData = value;
        postCount = postData!.docs.length.toString();
      });
    });
  }

  onFollowBtnClick(var ds) async {
    if (followersList.contains(Userdetails.uid)) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ds['uid'])
          .update({
        'followers': FieldValue.arrayRemove([Userdetails.uid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(Userdetails.uid)
          .update({
        'following': FieldValue.arrayRemove([ds['uid']])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ds['uid'])
          .update({
        'followers': FieldValue.arrayUnion([Userdetails.uid]),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(Userdetails.uid)
          .update({
        'following': FieldValue.arrayUnion([ds['uid']])
      });
    }
  }

  Widget FollowerCount() {
    return StreamBuilder<dynamic>(
      stream: followStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          followersList = snapshot.data['followers'];
          followingList = snapshot.data['following'];
          print(followersList);
          return Text(
            snapshot.data['followers'].length.toString(),
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade700,
              fontSize: 20,
            ),
          );
        } else {
          print(snapshot.data);
          return Text('0');
        }
      },
    );
  }

  Widget PostList() {
    return FutureBuilder<dynamic>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .where('postImage', isNotEqualTo: '')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
              strokeWidth: 1.6,
            ),
          );
        }
        if (snapshot.data.docs.length != 0) {
          return GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 5,
            shrinkWrap: true,
            children: List.generate(
              snapshot.data.docs.length,
              (index) {
                print(index);
                DocumentSnapshot ds = snapshot.data.docs[index];
                return ds['postImage'] == ''
                    ? Container()
                    : CachedNetworkImage(
                        imageUrl: ds['postImage'],
                        fit: BoxFit.cover,
                      );
              },
            ),
          );
        }
        return Text(
          'No Posts',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade200,
            fontSize: 20,
          ),
        );
      },
    );
  }

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
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: StreamBuilder<dynamic>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                return Text('No Data');
              }
              DocumentSnapshot ds = snapshot.data.docs[0];
              return Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44.5,
                        backgroundColor: isDarkMode!
                            ? Colors.blue.shade300
                            : isDarkMode!
                                ? Colors.blue.shade100
                                : primaryColor,
                        child: CircleAvatar(
                          radius: 43,
                          backgroundColor:
                              isDarkMode! ? Colors.grey.shade900 : Colors.white,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
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
                      MaterialButton(
                        onPressed: () async {
                          if (ds['followers'].contains(Userdetails.uid)) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(ds['uid'])
                                .update({
                              'followers':
                                  FieldValue.arrayRemove([Userdetails.uid]),
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Userdetails.uid)
                                .update({
                              'following': FieldValue.arrayRemove([ds['uid']])
                            });

                            sendNotification(
                              [ds['tokenId']],
                              Userdetails.userDisplayName +
                                  ' has unfollowed you!',
                              'Inspire',
                              Userdetails.userProfilePic,
                            );
                          } else {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(ds['uid'])
                                .update({
                              'followers':
                                  FieldValue.arrayUnion([Userdetails.uid]),
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Userdetails.uid)
                                .update({
                              'following': FieldValue.arrayUnion([ds['uid']])
                            });

                            sendNotification(
                              [ds['tokenId']],
                              Userdetails.userDisplayName +
                                  ' has followed you!',
                              'Inspire',
                              Userdetails.userProfilePic,
                            );
                          }
                        },
                        color: ds['followers'].contains(Userdetails.uid)
                            ? Colors.transparent
                            : isDarkMode!
                                ? Colors.blue.shade100
                                : primaryColor,
                        elevation: 0,
                        highlightElevation: 0,
                        highlightColor: primaryAccentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                          side: ds['followers'].contains(Userdetails.uid)
                              ? BorderSide(
                                  color: isDarkMode!
                                      ? Colors.blue.shade100
                                      : primaryColor,
                                )
                              : BorderSide.none,
                        ),
                        child: Text(
                          ds['followers'].contains(Userdetails.uid)
                              ? 'Following'
                              : 'Follow',
                          style: GoogleFonts.openSans(
                            color: ds['followers'].contains(Userdetails.uid)
                                ? isDarkMode!
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600
                                : isDarkMode!
                                    ? Colors.blue.shade800
                                    : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
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
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        ds['email'],
                        style: GoogleFonts.openSans(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('blogs')
                            .where('uid', isEqualTo: widget.uid)
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
                                from: 'others',
                              ));
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
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
      ),
    );
  }

  Widget BuildStatsCard({final label, final count, final press}) {
    return Container(
      width: double.infinity,
      padding:
          count == '0' ? EdgeInsets.symmetric(vertical: 15) : EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: isDarkMode!
            ? Colors.grey.shade800
            : isDarkMode!
                ? Colors.blue.shade100
                : primaryColor.withOpacity(0.1),
        // borderRadius: BorderRadius.circular(15),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 43),
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
    );
  }
}
