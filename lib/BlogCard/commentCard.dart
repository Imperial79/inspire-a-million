import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/globalVariable.dart';
import '../utilities/utility.dart';
import 'commentReplyUI.dart';

class CommentCard extends StatelessWidget {
  final snap, blogId;
  final BuildContext context;
  const CommentCard({Key? key, this.snap, this.blogId, required this.context})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Text(
                  snap['displayName'] == Userdetails.userDisplayName
                      ? 'You '
                      : snap['displayName'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  snap['comment'].toString().replaceAll('/:', ':'),
                  style: TextStyle(
                    fontSize: snap['comment'].split(' ').length > 10 ? 15 : 17,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.black,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  DateFormat.yMMMd().format(snap['time'].toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
              NavPush(
                  context,
                  ReplyUI(
                    blogId: blogId,
                    commentId: snap['time'].toString(),
                    comment: snap['comment'].toString().replaceAll('/:', ':'),
                  ));
            },
            icon: Icon(
              Icons.reply,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}
