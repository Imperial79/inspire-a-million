import 'package:blog_app/BlogCard/commentCard.dart';
import 'package:blog_app/BlogCard/commentReplyUI.dart';
import 'package:blog_app/BlogCard/tagsUI.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import '../services/database.dart';

Widget ShowModal(String blogId) {
  return SafeArea(
    child: StatefulBuilder(builder: (context, StateSetter setModalState) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey.shade700,
                  fontSize: 50,
                  // fontWeight: FontWeight.w100,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {
                  deletePost(blogId);
                  Navigator.pop(context);
                },
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        UniconsLine.trash_alt,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                      Text(
                        'Delete Blog',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.7,
                          color: isDarkMode
                              ? Colors.grey.shade100
                              : Colors.grey.shade800,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

deletePost(final blogId) async {
  await DatabaseMethods().deletePostDetails(blogId);
}

Future NavPush(context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future NavPushReplacement(BuildContext context, screen) async {
  await Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

Widget CommentList(String blogId) {
  return FutureBuilder<dynamic>(
    future: FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('time', descending: true)
        .get(),
    builder: (context, snapshot) {
      var primaryColor;
      return (snapshot.hasData)
          ? (snapshot.data.docs.length == 0)
              ? Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_rounded,
                        size: 70,
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      Text(
                        'No Comments',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    return CommentCard(
                      blogId: blogId,
                      snap: ds,
                      context: context,
                    );
                  },
                )
          : Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(
                  color: isDarkMode ? primaryAccentColor : primaryColor,
                  strokeWidth: 1.6,
                ),
              ),
            );
    },
  );
}

// Widget BuildCommentCard({
//   final snap,
//   blogId,
//   required BuildContext context,
// }) {
//   return Container(
//     padding: EdgeInsets.only(left: 15, top: 20, right: 15),
//     width: double.infinity,
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CircleAvatar(
//           radius: 17,
//           backgroundColor: Colors.grey.shade100,
//           child: CachedNetworkImage(
//             imageUrl: snap['userImage'],
//             imageBuilder: (context, image) => CircleAvatar(
//               backgroundColor: Colors.grey.shade100,
//               backgroundImage: image,
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         Expanded(
//           flex: 5,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 snap['displayName'] == Userdetails.userDisplayName
//                     ? 'You '
//                     : snap['displayName'],
//                 style: TextStyle(
//                   color: isDarkMode ? Colors.grey.shade300 : Colors.black,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               Text(
//                 snap['comment'].toString().replaceAll('/:', ':'),
//                 style: TextStyle(
//                   fontSize: snap['comment'].split(' ').length > 10 ? 15 : 17,
//                   color: isDarkMode ? Colors.grey.shade300 : Colors.black,
//                 ),
//               ),
//               SizedBox(
//                 height: 5,
//               ),
//               Text(
//                 DateFormat.yMMMd().format(snap['time'].toDate()),
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         IconButton(
//           onPressed: () {
//             NavPush(
//                 context,
//                 ReplyUI(
//                   blogId: blogId,
//                   commentId: snap['time'].toString(),
//                   comment: snap['comment'].toString().replaceAll('/:', ':'),
//                 ));
//           },
//           icon: Icon(
//             Icons.reply,
//             size: 15,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget TagsCard(String tag, BuildContext context, bool isHome) {
  return Padding(
    padding: EdgeInsets.only(right: 6),
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        if (isHome) {
          NavPush(context, TagsUI(tag: tag));
        }
      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.165),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
  );
}

Widget DummyBlogCard() {
  return Column(
    children: List.generate(
      10,
      (index) => Container(
        margin: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        // height: 200,
        color: Colors.grey.withOpacity(0.2),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey.withOpacity(0.5),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

ShowSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
      content: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontFamily: 'Product',
        ),
      ),
    ),
  );
}

SnackBarThemeData SnackBarTheme() {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    contentTextStyle: TextStyle(
      fontFamily: 'Product',
    ),
  );
}
