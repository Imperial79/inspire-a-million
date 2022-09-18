import 'package:blog_app/Home%20Screen/exploreUI.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'inspiredUi.dart';
import 'motivatorUi.dart';

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
    // onPageLoad();
    super.initState();
  }

  Future updateFollowingUsersList_this() async {
    await DatabaseMethods().getUsersIAmFollowing().then((value) {
      final users = value;
      followingUsers = users!.data()!['following'];
      followers = users!.data()!['followers'];

      if (!followingUsers.contains(Userdetails.uid)) {
        followingUsers.add(FirebaseAuth.instance.currentUser!.uid);
      }
    });
    return print('Updated Following Users [' +
        followingUsers.length.toString() +
        '] ---------> ' +
        followingUsers.toString());
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<dynamic>(
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        CircleAvatar(
                          radius: 44.5,
                          backgroundColor: isDarkMode!
                              ? Colors.blue.shade300
                              : isDarkMode!
                                  ? Colors.blue.shade100
                                  : primaryColor,
                          child: CircleAvatar(
                            radius: 43,
                            backgroundColor: isDarkMode!
                                ? Colors.grey.shade900
                                : Colors.white,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              radius: 39,
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

                              // sendNotification(
                              //   tokenIdList: [ds['tokenId']],
                              //   contents: Userdetails.userDisplayName +
                              //       ' has unfollowed you!',
                              //   heading: 'Inspire',
                              //   largeIconUrl: Userdetails.userProfilePic,
                              // );
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
                                tokenIdList: [ds['tokenId']],
                                contents: Userdetails.userDisplayName +
                                    ' has followed you!',
                                heading: 'Inspire',
                                largeIconUrl: Userdetails.userProfilePic,
                              );
                            }

                            updateFollowingUsersList()
                                .then((value) => setState(() {}));
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
                                : ds['following'].contains(Userdetails.uid)
                                    ? 'Follow Back'
                                    : 'Follow',
                            style: TextStyle(
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
                          style: TextStyle(
                            color: isDarkMode!
                                ? Colors.white
                                : Colors.grey.shade800,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          maxLines: 2,
                        ),
                        Text(
                          '@' + ds['username'],
                          style: TextStyle(
                            color: isDarkMode!
                                ? Colors.blue.shade100
                                : primaryColor,
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
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            children: [
                              StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('blogs')
                                    .where('uid', isEqualTo: widget.uid)
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
                                count: ds['followers'].length.toString(),
                                label: 'Inspired',
                                press: () {
                                  NavPush(
                                      context,
                                      InspiredUi(
                                        snap: ds,
                                        my: false,
                                      ));
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              StatsCard(
                                count: ds['following'].length.toString(),
                                label: 'Motivators',
                                press: () {
                                  NavPush(
                                      context,
                                      MotivatorUi(
                                        snap: ds,
                                        from: 'others',
                                      ));
                                },
                              ),
                            ],
                          ),
                        ),
                        BlogList(isMe: false, name: ds['name'], uid: ds['uid']),
                      ],
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
            ],
          ),
        ),
      ),
    );
  }

  // Widget BuildStatsCard({final label, final count, final press}) {
  //   return Expanded(
  //     child: AnimatedContainer(
  //       duration: Duration(seconds: 5),
  //       width: double.infinity,
  //       padding: count == '0'
  //           ? EdgeInsets.symmetric(vertical: 15)
  //           : EdgeInsets.all(0),
  //       decoration: BoxDecoration(
  //         color: isDarkMode!
  //             ? Colors.grey.withOpacity(0.2)
  //             : isDarkMode!
  //                 ? primaryAccentColor
  //                 : primaryColor.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Row(
  //         children: [
  //           Expanded(
  //             flex: 5,
  //             child: Padding(
  //               padding: EdgeInsets.only(left: 20, right: 10),
  //               child: Row(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Align(
  //                     alignment: Alignment.centerLeft,
  //                     child: FittedBox(
  //                       child: Text(
  //                         count,
  //                         style: TextStyle(
  //                           color: isDarkMode!
  //                               ? Colors.grey.shade300
  //                               : Colors.grey.shade700,
  //                           fontWeight: FontWeight.w900,
  //                           fontSize: 45,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     width: 70,
  //                   ),
  //                   Expanded(
  //                     child: Align(
  //                       alignment: Alignment.centerRight,
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.end,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           FittedBox(
  //                             child: Text(
  //                               label,
  //                               style: TextStyle(
  //                                 color: isDarkMode!
  //                                     ? primaryAccentColor
  //                                     : primaryColor.withOpacity(0.7),
  //                                 fontWeight: FontWeight.w800,
  //                                 fontSize: 30,
  //                               ),
  //                             ),
  //                           ),
  //                           FittedBox(
  //                             child: Text(
  //                               label == 'Inspirations'
  //                                   ? 'Blogs'
  //                                   : label == 'Inspired'
  //                                       ? 'Followers'
  //                                       : 'Following',
  //                               style: TextStyle(
  //                                 color: isDarkMode!
  //                                     ? primaryAccentColor.withOpacity(0.7)
  //                                     : primaryColor.withOpacity(0.5),
  //                                 fontWeight: FontWeight.w700,
  //                                 fontSize: 20,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           count == '0'
  //               ? Container()
  //               : InkWell(
  //                   onTap: press,
  //                   child: Container(
  //                     margin: EdgeInsets.only(right: 10),
  //                     padding: EdgeInsets.all(10),
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: isDarkMode! ? primaryAccentColor : primaryColor,
  //                     ),
  //                     child: RotatedBox(
  //                       quarterTurns: 90,
  //                       child: SvgPicture.asset(
  //                         'lib/assets/icons/back.svg',
  //                         color: isDarkMode! ? Colors.black : Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
