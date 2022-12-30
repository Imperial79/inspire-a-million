import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../utilities/constants.dart';

class CommentUi extends StatefulWidget {
  final blogId;
  final tokenId;
  CommentUi({required this.blogId, required this.tokenId});

  @override
  State<CommentUi> createState() => _CommentUiState();
}

class _CommentUiState extends State<CommentUi> {
  final commentController = TextEditingController();
  final dbMethod = DatabaseMethods();
  Stream? commentStream;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  uploadComments(
      {required String commentText,
      blogId,
      required BuildContext context}) async {
    if (commentText.isNotEmpty) {
      var time = DateTime.now();
      Map<String, dynamic> commentMap = {
        'comment': commentText,
        'userImage': Userdetails.userProfilePic,
        'displayName': Userdetails.userDisplayName,
        'uid': Userdetails.uid,
        'time': time,
      };
      FocusScope.of(context).unfocus();
      commentController.clear();
      DatabaseMethods().uploadComments(blogId, commentMap, time.toString());
      sendNotification(
        tokenIdList: Global.followersTokenId,
        contents: commentText,
        heading: Userdetails.userDisplayName + ' has commented',
        largeIconUrl: Userdetails.userProfilePic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'COMMENTS',
          style: TextStyle(
            letterSpacing: 6,
            color: isDarkMode ? Colors.blue.shade100 : primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  CommentList(widget.blogId),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: commentController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade200 : Colors.black,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Comment as ' +
                            Userdetails.userDisplayName.split(' ')[0] +
                            ' ...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
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
                      uploadComments(
                        commentText:
                            commentController.text.replaceAll(':', '/:'),
                        blogId: widget.blogId,
                        context: context,
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

  Widget BuildCommentCard({
    final snap,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 15, top: 20, right: 15),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: CachedNetworkImage(
              imageUrl: snap['userImage'],
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
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: snap['displayName'] == Userdetails.userDisplayName
                            ? 'You '
                            : snap['displayName'] + ' ',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey.shade300 : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: snap['comment'],
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey.shade300 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMd().format(snap['time'].toDate()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
