import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../utilities/constants.dart';

class ReplyUI extends StatefulWidget {
  final blogId, commentId, comment;
  const ReplyUI({Key? key, this.commentId, this.comment, this.blogId})
      : super(key: key);

  @override
  State<ReplyUI> createState() => _ReplyUIState();
}

class _ReplyUIState extends State<ReplyUI> {
  final replyController = TextEditingController();

  Future getRepliedComments() async {
    return await FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.blogId.toString())
        .collection('comments')
        .doc(widget.commentId.toString())
        .collection('replies')
        .get();
  }

  uploadReply(String replyText, blogId, commentId) async {
    if (replyController.text.isNotEmpty) {
      var replyId = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> replyMap = {
        'reply': replyText,
        'replyId': replyId,
        'time': replyId,
        'commentId': commentId,
        'blogId': blogId,
        'name': Userdetails.userDisplayName,
        'uid': Userdetails.uid,
        'userImage': Userdetails.userProfilePic,
      };

      await FirebaseFirestore.instance
          .collection('blogs')
          .doc(blogId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .add(replyMap)
          .whenComplete(() {
        replyController.clear();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    replyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Replying to " ${widget.comment} "',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? primaryAccentColor : primaryColor,
                  fontSize: 17,
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(10),
                children: [
                  FutureBuilder<dynamic>(
                    future: getRepliedComments(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length == 0) {
                          return Text('No Replies');
                        }

                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: ((context, index) {
                            DocumentSnapshot ds = snapshot.data.docs[index];
                            return ReplyCard(ds);
                          }),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: replyController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade200 : Colors.black,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Reply to " ${widget.comment} "',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      uploadReply(
                        replyController.text,
                        widget.blogId.toString(),
                        widget.commentId.toString(),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      height: 40,
                      width: 40,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? primaryAccentColor : primaryColor,
                      ),
                      child: SvgPicture.asset(
                        'lib/assets/icons/share.svg',
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ReplyCard(final ds) {
    return Container(
      padding: EdgeInsets.only(left: 15, top: 20, right: 15),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Colors.grey.shade100,
            child: CachedNetworkImage(
              imageUrl: ds['userImage'],
              imageBuilder: (context, image) => CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                backgroundImage: image,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ds['displayName'] == Userdetails.userDisplayName
                      ? 'You '
                      : ds['displayName'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ds['reply'].toString().replaceAll('/:', ':'),
                  style: TextStyle(
                    fontSize: ds['reply'].split(' ').length > 10 ? 15 : 17,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMd().format(ds['time'].toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   width: 10,
          // ),
          // IconButton(
          //   onPressed: () {
          //     NavPush(
          //         context,
          //         ReplyUI(
          //           blogId: blogId,
          //           commentId: snap['time'],
          //           comment: snap['comment'].toString().replaceAll('/:', ':'),
          //         ));
          //   },
          //   icon: Icon(
          //     Icons.reply,
          //     size: 15,
          //   ),
          // ),
        ],
      ),
    );
  }
}
