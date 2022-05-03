import 'dart:ui';
import 'package:blog_app/colors.dart';
import 'package:blog_app/commentUi.dart';
import 'package:blog_app/likesUI.dart';
import 'package:blog_app/othersProfileUi.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/like_animation.dart';
import 'package:blog_app/services/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class BlogCard extends StatefulWidget {
  final snap;
  BlogCard({required this.snap});

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  Widget Alert(final blogId) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      title: Text(
        'Delete Blog?',
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text('Do You want to delete this blog ?'),
      actions: [
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {});
          },
          child: Text(
            'Cancel',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w800,
              color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
            ),
          ),
        ),
        MaterialButton(
          onPressed: () {
            deletePost(blogId);
            Navigator.pop(context);
            setState(() {});
          },
          color: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            'Delete',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  deletePost(final blogId) async {
    await DatabaseMethods().deletePostDetails(widget.snap['blogId']);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 4,
            sigmaY: 4,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode!
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.snap['uid'] != Userdetails.uid) {
                                PageRouteTransition.push(context,
                                    OthersProfileUi(uid: widget.snap['uid']));
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: primaryAccentColor,
                              radius: 22,
                              backgroundImage: NetworkImage(
                                widget.snap['profileImage'],
                              ),
                            ),
                          ),
                          StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('uid', isEqualTo: widget.snap['uid'])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                DocumentSnapshot ds = snapshot.data.docs[0];
                                // print(ds['active']);
                                return CircleAvatar(
                                  radius: 7,
                                  backgroundColor:
                                      isDarkMode! ? Colors.black : Colors.white,
                                  child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: ds['active'] == '1'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }
                              return CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.snap['uid'] != Userdetails.uid) {
                                  PageRouteTransition.push(context,
                                      OthersProfileUi(uid: widget.snap['uid']));
                                }
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Text(
                                  widget.snap['userDisplayName'] ==
                                          Userdetails.userDisplayName
                                      ? 'You'
                                      : widget.snap['userDisplayName'],
                                  style: GoogleFonts.openSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: isDarkMode!
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              DateFormat.Hm()
                                      .format(widget.snap['time'].toDate()) +
                                  '  •  ' +
                                  timeago.format(
                                    widget.snap['time'].toDate(),
                                    locale: 'en_short',
                                  ) +
                                  ' ago' +
                                  '  •  ' +
                                  DateFormat.yMMMd()
                                      .format(widget.snap['time'].toDate()),
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.w600,
                                color: isDarkMode!
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      widget.snap['uid'] == Userdetails.uid
                          ? IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Alert(widget.snap['blogId']);
                                      },
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.grey.shade500,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 13,
                ),
                SelectableLinkify(
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      await launch(link.url);
                    } else {
                      throw 'Could not launch $link';
                    }
                  },
                  text: widget.snap['description'],
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600,
                    fontSize:
                        widget.snap['description'].length > 100 ? 14 : 16.8,
                    height: 1.5,
                    color: isDarkMode! ? Colors.grey.shade200 : Colors.black,
                  ),
                ),
                widget.snap['likes'].length == 0
                    ? Container()
                    : SizedBox(
                        height: 20,
                      ),
                widget.snap['likes'].length == 0
                    ? Container()
                    : Row(
                        children: [
                          widget.snap['likes'].length == 1
                              ? StreamBuilder<dynamic>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('uid',
                                          isEqualTo: widget.snap['likes'][0])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data.docs.length == 0) {
                                        return SingleLikePreview(
                                            profileImg: '');
                                      } else {
                                        DocumentSnapshot ds =
                                            snapshot.data.docs[0];
                                        return SingleLikePreview(
                                          profileImg: ds['imgUrl'],
                                        );
                                      }
                                    }
                                    return Container();
                                  },
                                )
                              : StreamBuilder<dynamic>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .where('uid',
                                          whereIn: widget.snap['likes'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    try {
                                      return DoubleLikePreview(
                                        img1: snapshot.data.docs[0]['imgUrl'],
                                        img2: snapshot.data.docs[1]['imgUrl'],
                                      );
                                    } catch (e) {
                                      return Container();
                                    }
                                  },
                                ),
                          GestureDetector(
                            onTap: () {
                              PageRouteTransition.push(
                                  context,
                                  LikesUI(
                                    snap: widget.snap,
                                  ));
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Text(
                                widget.snap['likes'].length == 1
                                    ? ' liked it'
                                    : widget.snap['likes']
                                            .contains(Userdetails.uid)
                                        ? 'You and ' +
                                            (widget.snap['likes'].length - 1)
                                                .toString() +
                                            ' more have liked'
                                        : widget.snap['likes'].length
                                                .toString() +
                                            ' people liked it',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode!
                                      ? Colors.grey.shade400
                                      : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        DatabaseMethods().likeBlog(
                            widget.snap['blogId'], widget.snap['likes']);
                        sendNotification(
                          [widget.snap['tokenId']],
                          Userdetails.userDisplayName + ' has liked your post',
                          '!nspire',
                          Userdetails.userProfilePic,
                        );
                      },
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      color: widget.snap['likes'].contains(Userdetails.uid)
                          ? primaryAccentColor.withOpacity(0.2)
                          : Colors.transparent,
                      elevation: 0,
                      highlightElevation: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        child: Row(
                          children: [
                            LikeAnimation(
                              isAnimating: widget.snap['likes']
                                  .contains(Userdetails.uid),
                              smallLike: true,
                              child: Icon(
                                widget.snap['likes'].contains(Userdetails.uid)
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isDarkMode!
                                    ? Colors.blue.shade100
                                    : primaryColor,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              widget.snap['likes'].length.toString(),
                              style: GoogleFonts.openSans(
                                color: isDarkMode!
                                    ? Colors.blue.shade100
                                    : primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    MaterialButton(
                      onPressed: () {
                        PageRouteTransition.effect =
                            TransitionEffect.bottomToTop;
                        PageRouteTransition.push(
                            context,
                            CommentUi(
                              blogId: widget.snap['blogId'],
                              tokenId: widget.snap['tokenId'],
                            )).then((value) {
                          setState(() {});
                        });
                      },
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      elevation: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'lib/assets/icons/comment.svg',
                              color: isDarkMode!
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              height: 20,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              widget.snap['comments'].toString() + ' Comments',
                              style: GoogleFonts.openSans(
                                color: isDarkMode!
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget DoubleLikePreview({final img1, img2}) {
    return Container(
      width: 55,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          CircleAvatar(
            backgroundColor: isDarkMode! ? Colors.black : Colors.white,
            radius: 15,
            child: CircleAvatar(
              radius: 13,
              backgroundColor:
                  isDarkMode! ? Colors.blue.shade100 : primaryColor,
              child: CachedNetworkImage(
                imageUrl: img1,
                imageBuilder: (context, image) => CircleAvatar(
                  radius: 13,
                  backgroundColor:
                      isDarkMode! ? Colors.blue.shade100 : primaryColor,
                  backgroundImage: image,
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: CircleAvatar(
              backgroundColor: isDarkMode! ? Colors.black : Colors.white,
              radius: 15,
              child: CircleAvatar(
                radius: 13,
                backgroundColor:
                    isDarkMode! ? Colors.blue.shade100 : primaryColor,
                child: CachedNetworkImage(
                  imageUrl: img2,
                  imageBuilder: (context, image) => CircleAvatar(
                    radius: 13,
                    backgroundColor:
                        isDarkMode! ? Colors.blue.shade100 : primaryColor,
                    backgroundImage: image,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SingleLikePreview({final profileImg}) {
    return CircleAvatar(
      backgroundColor: isDarkMode! ? Colors.black : Colors.white,
      radius: 17,
      child: profileImg == ''
          ? CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
            )
          : CircleAvatar(
              radius: 15,
              backgroundColor:
                  isDarkMode! ? Colors.blue.shade100 : primaryColor,
              child: CachedNetworkImage(
                imageUrl: profileImg,
                imageBuilder: (context, image) => CircleAvatar(
                  radius: 15,
                  backgroundColor:
                      isDarkMode! ? Colors.blue.shade100 : primaryColor,
                  backgroundImage: image,
                ),
              ),
            ),
    );
  }
}
