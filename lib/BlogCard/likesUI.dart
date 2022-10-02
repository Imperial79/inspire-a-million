import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikesUI extends StatefulWidget {
  final snap;
  LikesUI({this.snap});

  @override
  State<LikesUI> createState() => _LikesUIState();
}

class _LikesUIState extends State<LikesUI> {
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15, left: 15),
              child: Row(
                children: [
                  Text(
                    'Likes',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? primaryAccentColor : primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('uid', whereIn: widget.snap['likes'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'No Users',
                          style: TextStyle(
                            color: Colors.blueGrey.shade200,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: CachedNetworkImage(
                              imageUrl: ds['imgUrl'],
                              imageBuilder: (context, image) => CircleAvatar(
                                backgroundImage: image,
                              ),
                            ),
                          ),
                          title: Text(
                            ds['name'] == Userdetails.userDisplayName
                                ? 'You'
                                : ds['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.grey.shade200
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '@' + ds['username'],
                            style: TextStyle(
                              color: isDarkMode
                                  ? primaryAccentColor
                                  : primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: ds['uid'] == Userdetails.uid
                              ? null
                              : MaterialButton(
                                  onPressed: () async {
                                    if (ds['followers']
                                        .contains(Userdetails.uid)) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(ds['uid'])
                                          .update({
                                        'followers': FieldValue.arrayRemove(
                                            [Userdetails.uid]),
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(Userdetails.uid)
                                          .update({
                                        'following':
                                            FieldValue.arrayRemove([ds['uid']])
                                      });

                                      // sendNotification(
                                      //   tokenIdList: [ds['tokenId']],
                                      //   contents: Userdetails.userDisplayName +
                                      //       ' has unfollowed you!',
                                      //   heading: 'Inspire',
                                      //   largeIconUrl:
                                      //       Userdetails.userProfilePic,
                                      // );
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(ds['uid'])
                                          .update({
                                        'followers': FieldValue.arrayUnion(
                                            [Userdetails.uid]),
                                      });

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(Userdetails.uid)
                                          .update({
                                        'following':
                                            FieldValue.arrayUnion([ds['uid']])
                                      });

                                      sendNotification(
                                        tokenIdList: [ds['tokenId']],
                                        contents: Userdetails.userDisplayName +
                                            ' has followed you!',
                                        heading: 'Inspire',
                                        largeIconUrl:
                                            Userdetails.userProfilePic,
                                      );
                                    }
                                  },
                                  elevation: 0,
                                  color:
                                      ds['followers'].contains(Userdetails.uid)
                                          ? Colors.transparent
                                          : primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: ds['followers']
                                              .contains(Userdetails.uid)
                                          ? primaryColor
                                          : Colors.transparent,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: Text(
                                    ds['followers'].contains(Userdetails.uid)
                                        ? 'Following'
                                        : 'Follow',
                                    style: TextStyle(
                                      color: ds['followers']
                                              .contains(Userdetails.uid)
                                          ? isDarkMode
                                              ? primaryAccentColor
                                              : primaryColor
                                          : isDarkMode
                                              ? Colors.grey.shade100
                                              : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isDarkMode ? primaryAccentColor : primaryColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
