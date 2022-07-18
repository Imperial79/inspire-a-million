import 'dart:ui';
import 'package:blog_app/colors.dart';
import 'package:blog_app/commentUi.dart';
import 'package:blog_app/likesUI.dart';
import 'package:blog_app/othersProfileUi.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/like_animation.dart';
import 'package:blog_app/utilities/utility.dart';
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
  final index;
  BlogCard({required this.snap, this.index});

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  // Widget Alert(final blogId) {
  //   return BackdropFilter(
  //     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
  //     child: AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       backgroundColor: isDarkMode! ? Colors.grey.shade800 : Colors.white,
  //       elevation: 0,
  //       title: Text(
  //         'Delete Blog',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w600,
  //           color: isDarkMode! ? Colors.white : Colors.black,
  //         ),
  //       ),
  //       content: Text(
  //         'Do You want to delete this blog ?',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w600,
  //           color: isDarkMode! ? Colors.white : Colors.black,
  //         ),
  //       ),
  //       actionsAlignment: MainAxisAlignment.spaceBetween,
  //       actions: [
  //         MaterialButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             setState(() {});
  //           },
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w600,
  //               color: isDarkMode! ? primaryAccentColor : primaryColor,
  //             ),
  //           ),
  //         ),
  //         MaterialButton(
  //           onPressed: () {
  //             deletePost(blogId);
  //             Navigator.pop(context);
  //             setState(() {});
  //           },
  //           color: Colors.red,
  //           elevation: 0,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(50),
  //           ),
  //           child: Text(
  //             'Delete',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w700,
  //               color: Colors.white,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0, bottom: 10),
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode!
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(0),
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
                            PageRouteTransition.push(
                                context,
                                OthersProfileUi(
                                  uid: widget.snap['uid'],
                                  heroTag: widget.snap['uid'],
                                )).then((value) => setState(() {}));
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
                                    ? isDarkMode!
                                        ? Colors.green.shade800
                                        : Colors.green
                                    : isDarkMode!
                                        ? Colors.red.shade800
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
                              PageRouteTransition.push(
                                  context,
                                  OthersProfileUi(
                                    uid: widget.snap['uid'],
                                    heroTag: widget.snap['uid'],
                                  )).then((value) => setState(() {}));
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
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 14,
                                color: isDarkMode!
                                    ? Colors.white
                                    : Colors.grey.shade800,
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
                          DateFormat.Hm().format(widget.snap['time'].toDate()) +
                              ' • ' +
                              timeago.format(
                                widget.snap['time'].toDate(),
                                locale: 'en_short',
                              ) +
                              ' • ' +
                              DateFormat.yMMMd()
                                  .format(widget.snap['time'].toDate()),
                          style: TextStyle(
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
                            // showDialog(
                            //   context: context,
                            //   builder: (context) {
                            //     return StatefulBuilder(
                            //       builder: (context, setState) {
                            //         return Alert(widget.snap['blogId']);
                            //       },
                            //     );
                            //   },
                            // );

                            showModalBottomSheet(
                              context: context,
                              enableDrag: true,
                              constraints: BoxConstraints(
                                maxHeight: 200,
                                minHeight: 100,
                              ),
                              backgroundColor: isDarkMode!
                                  ? Colors.grey.shade800
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              builder: (context) {
                                return ShowModal(widget.snap['blogId']);
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
              linkStyle: TextStyle(
                color: isDarkMode! ? primaryAccentColor : primaryColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
              onOpen: (link) async {
                if (await canLaunchUrl(Uri.parse(link.url))) {
                  await launchUrl(
                    Uri.parse(link.url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  throw 'Could not launch $link';
                }
              },
              text: widget.snap['description'],
              style: TextStyle(
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
                fontSize: widget.snap['description'].length > 100 ? 14 : 16.8,
                height: 1,
                color:
                    isDarkMode! ? Colors.grey.shade300 : Colors.grey.shade800,
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
                                    return SingleLikePreview(profileImg: '');
                                  } else {
                                    DocumentSnapshot ds = snapshot.data.docs[0];
                                    return GestureDetector(
                                      onTap: () {
                                        if (ds['uid'] != Userdetails.uid) {
                                          Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OthersProfileUi(
                                                            uid: ds['uid'],
                                                            heroTag: ds['uid'],
                                                          )))
                                              .then((value) => setState(() {}));
                                        }
                                      },
                                      child: SingleLikePreview(
                                        profileImg: ds['imgUrl'],
                                      ),
                                    );
                                  }
                                }

                                return CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      isDarkMode! ? Colors.black : Colors.white,
                                );
                              },
                            )
                          : StreamBuilder<dynamic>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('uid', whereIn: widget.snap['likes'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                try {
                                  return DoubleLikePreview(
                                    img1: snapshot.data.docs[0]['imgUrl'],
                                    press1: snapshot.data.docs[0]['uid'],
                                    press2: snapshot.data.docs[1]['uid'],
                                    img2: snapshot.data.docs[1]['imgUrl'],
                                  );
                                } catch (e) {
                                  return DummyDoubleLikePreview();
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
                                : widget.snap['likes'].contains(Userdetails.uid)
                                    ? 'You and ' +
                                        (widget.snap['likes'].length - 1)
                                            .toString() +
                                        ' more have liked'
                                    : widget.snap['likes'].length.toString() +
                                        ' people liked it',
                            style: TextStyle(
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode!
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
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
                      widget.snap['blogId'],
                      widget.snap['likes'],
                      widget.snap,
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    child: Row(
                      children: [
                        LikeAnimation(
                          isAnimating:
                              widget.snap['likes'].contains(Userdetails.uid),
                          smallLike: true,
                          child: Icon(
                            widget.snap['likes'].contains(Userdetails.uid)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          widget.snap['likes'].length.toString(),
                          style: TextStyle(
                            color:
                                isDarkMode! ? primaryAccentColor : primaryColor,
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
                    PageRouteTransition.effect = TransitionEffect.bottomToTop;
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
                          style: TextStyle(
                            color: isDarkMode!
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
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
    );
  }

  Widget DoubleLikePreview({final img1, img2, press1, press2}) {
    return Container(
      width: 55,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          GestureDetector(
            onTap: () {
              if (press1 != Userdetails.uid)
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OthersProfileUi(uid: press1, heroTag: press1)))
                    .then((value) => setState(() {}));
            },
            child: CircleAvatar(
              backgroundColor: isDarkMode!
                  ? Colors.grey.shade800.withOpacity(0.2)
                  : Colors.grey.shade100,
              radius: 15,
              child: CircleAvatar(
                radius: 13,
                backgroundColor:
                    isDarkMode! ? primaryAccentColor : primaryColor,
                child: CachedNetworkImage(
                  imageUrl: img1,
                  imageBuilder: (context, image) => CircleAvatar(
                    radius: 13,
                    backgroundColor:
                        isDarkMode! ? primaryAccentColor : primaryColor,
                    backgroundImage: image,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (press2 != Userdetails.uid)
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OthersProfileUi(
                                  uid: press2, heroTag: press2)))
                      .then((value) => setState(() {}));
              },
              child: CircleAvatar(
                backgroundColor: isDarkMode! ? Colors.black : Colors.white,
                radius: 15,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor:
                      isDarkMode! ? primaryAccentColor : primaryColor,
                  child: CachedNetworkImage(
                    imageUrl: img2,
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: 13,
                      backgroundColor:
                          isDarkMode! ? primaryAccentColor : primaryColor,
                      backgroundImage: image,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget DummyDoubleLikePreview() {
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
              backgroundColor: isDarkMode! ? primaryAccentColor : primaryColor,
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
                    isDarkMode! ? primaryAccentColor : primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SingleLikePreview({final profileImg}) {
    return CircleAvatar(
      backgroundColor: isDarkMode!
          ? Colors.grey.shade800.withOpacity(0.2)
          : Colors.grey.shade100,
      radius: 17,
      child: profileImg == ''
          ? CircleAvatar(
              radius: 15,
              backgroundColor: isDarkMode!
                  ? Colors.grey.shade800.withOpacity(0.2)
                  : Colors.grey.shade100,
            )
          : CircleAvatar(
              radius: 15,
              backgroundColor: isDarkMode! ? primaryAccentColor : primaryColor,
              child: CachedNetworkImage(
                imageUrl: profileImg,
                imageBuilder: (context, image) => CircleAvatar(
                  radius: 15,
                  backgroundColor:
                      isDarkMode! ? primaryAccentColor : primaryColor,
                  backgroundImage: image,
                ),
              ),
            ),
    );
  }
}
