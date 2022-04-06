import 'package:blog_app/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';

class CommentUi extends StatefulWidget {
  final blogId;
  CommentUi({required this.blogId});

  @override
  State<CommentUi> createState() => _CommentUiState();
}

class _CommentUiState extends State<CommentUi> {
  final commentController = TextEditingController();
  final dbMethod = DatabaseMethods();
  Stream? commentStream;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  uploadComments() async {
    if (commentController.text.isNotEmpty) {
      var time = DateTime.now();
      Map<String, dynamic> commentMap = {
        'comment': commentController.text,
        'userImage': Userdetails.userProfilePic,
        'displayName': Userdetails.userDisplayName,
        'uid': Userdetails.uid,
        'time': time,
      };
      DatabaseMethods().uploadComments(widget.blogId, commentMap);

      commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Widget CommentList() {
    return StreamBuilder<dynamic>(
      stream: FirebaseFirestore.instance
          .collection('blogs')
          .doc(widget.blogId)
          .collection('comments')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return (snapshot.hasData)
            ? (snapshot.data.docs.length == 0)
                ? Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      children: [
                        Icon(
                          Icons.comment_rounded,
                          size: 70,
                          color: isDarkMode!
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        Text(
                          'No Comments',
                          style: GoogleFonts.openSans(
                            fontSize: 20,
                            color: isDarkMode!
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
                      // print('yes');
                      return BuildCommentCard(snap: ds);
                    },
                  )
            : Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(
                    color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                    strokeWidth: 1.6,
                  ),
                ),
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      PageRouteTransition.pop(context);
                    },
                    icon: SvgPicture.asset(
                      'lib/assets/icons/back.svg',
                      color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                    ),
                  ),
                  Text(
                    'Comments!',
                    style: GoogleFonts.openSans(
                      color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CommentList(),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color:
                      isDarkMode! ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: commentController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      style: GoogleFonts.openSans(
                        color:
                            isDarkMode! ? Colors.grey.shade200 : Colors.black,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        hintText: 'comment as ' +
                            Userdetails.userDisplayName.split(' ')[0],
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.openSans(
                          color: isDarkMode!
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CircleAvatar(
                      backgroundColor:
                          isDarkMode! ? Colors.blue.shade400 : primaryColor,
                      child: IconButton(
                        onPressed: () {
                          uploadComments();
                        },
                        icon: CircleAvatar(
                          radius: 10,
                          backgroundColor:
                              isDarkMode! ? Colors.grey.shade900 : Colors.white,
                        ),
                      ),
                    ),
                  )
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
                        style: GoogleFonts.openSans(
                          color:
                              isDarkMode! ? Colors.grey.shade300 : Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: snap['comment'],
                        style: GoogleFonts.openSans(
                          color: Colors.black,
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
                  style: GoogleFonts.openSans(
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
