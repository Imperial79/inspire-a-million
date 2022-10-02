import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/Profile_Screen/othersProfileUi.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Home Screen/exploreUI.dart';

class InspiredUi extends StatefulWidget {
  final snap;
  final my;
  InspiredUi({required this.snap, this.my});

  @override
  State<InspiredUi> createState() => _InspiredUiState();
}

class _InspiredUiState extends State<InspiredUi> {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          widget.my ? 'You' : widget.snap['name'],
                          style: TextStyle(
                            fontSize: 17,
                            letterSpacing: 1,
                            color: isDarkMode
                                ? Colors.grey.shade300
                                : Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'INSPIRED',
                        style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 17,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? primaryAccentColor : primaryColor,
                        ),
                      ),
                    ],
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
                    .where('following', arrayContains: widget.snap['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'No Users',
                          style: TextStyle(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return UserListTile(ds);
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isDarkMode ? Colors.blue.shade100 : primaryColor,
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

  Widget UserListTile(DocumentSnapshot<Object?> ds) {
    return Tooltip(
      message: ds['name'],
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OthersProfileUi(uid: ds['uid'])));
        },
        leading: CircleAvatar(
          child: CachedNetworkImage(
            imageUrl: ds['imgUrl'],
            imageBuilder: (context, image) => CircleAvatar(
              backgroundImage: image,
            ),
          ),
        ),
        title: Text(
          ds['name'] == Userdetails.userDisplayName ? 'You' : ds['name'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade200 : Colors.black,
            wordSpacing: isDarkMode ? -4 : 0,
          ),
        ),
        subtitle: Text(
          '@' + ds['username'],
          style: TextStyle(
            color: isDarkMode ? primaryAccentColor : primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: MaterialButton(
          onPressed: () async {
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

              // sendNotification(
              //   [ds['tokenId']],
              //   Userdetails.userDisplayName + ' has unfollowed you!',
              //   'Inspire',
              //   Userdetails.userProfilePic,
              // );
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

              sendNotification(
                tokenIdList: [ds['tokenId']],
                contents: Userdetails.userDisplayName + ' has followed you!',
                heading: 'Inspire',
                largeIconUrl: Userdetails.userProfilePic,
              );
            }

            updateFollowingUsersList().then((value) => setState(() {}));
          },
          elevation: 0,
          // color: isDarkMode ? primaryAccentColor : primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: ds['followers'].contains(Userdetails.uid)
                ? BorderSide(
                    color: Colors.blueGrey.shade200,
                  )
                : BorderSide.none,
          ),
          color: ds['followers'].contains(Userdetails.uid)
              ? Colors.transparent
              : isDarkMode
                  ? primaryAccentColor
                  : primaryColor,

          child: Text(
            ds['followers'].contains(Userdetails.uid)
                ? 'Following'
                : ds['following'].contains(Userdetails.uid)
                    ? 'Follow Back'
                    : 'Follow',
            style: TextStyle(
              wordSpacing: isDarkMode ? -2 : 0,
              color: ds['followers'].contains(Userdetails.uid)
                  ? isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600
                  : isDarkMode
                      ? primaryColor
                      : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
