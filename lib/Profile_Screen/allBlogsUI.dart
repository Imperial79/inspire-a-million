import 'package:blog_app/colors.dart';
import 'package:blog_app/commentUi.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/like_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class MyBlogsUi extends StatefulWidget {
  final snap;
  final my;
  MyBlogsUi({this.snap, this.my});

  @override
  State<MyBlogsUi> createState() => _MyBlogsUiState();
}

class _MyBlogsUiState extends State<MyBlogsUi> {
  Widget Alert(final blogId) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      title: Text(
        'Delete Blog?',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkMode! ? Colors.white : Colors.black,
        ),
      ),
      content: Text(
        'Do You want to delete this blog ?',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDarkMode! ? Colors.white : Colors.black,
        ),
      ),
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
    await DatabaseMethods().deletePostDetails(blogId);
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.my ? 'Your' : widget.snap['name'] + '\'s',
                    style: TextStyle(
                      letterSpacing: 1,
                      fontSize: 15,
                      color: isDarkMode! ? Colors.grey.shade300 : Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'INSPIRATIONS',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 10,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode! ? Colors.grey.shade400 : primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('blogs')
                    .where('uid', isEqualTo: widget.snap['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Write Blogs',
                              style: GoogleFonts.openSans(
                                color: Colors.grey.shade300,
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '&\n!nspire a Million',
                              style: GoogleFonts.openSans(
                                color: Colors.grey.shade300,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return MyBlogCard(ds, context);
                      },
                    );
                  }
                  return Center(
                    child: CustomLoading(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget MyBlogCard(DocumentSnapshot<Object?> ds, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode! ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat.Hm().format(ds['time'].toDate()) +
                      '  •  ' +
                      timeago.format(
                        ds['time'].toDate(),
                        locale: 'en_short',
                      ) +
                      '  •  ' +
                      DateFormat.yMMMd().format(ds['time'].toDate()),
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ),
              ds['uid'] == Userdetails.uid
                  ? IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Alert(ds['blogId']);
                              },
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        color: isDarkMode! ? Colors.white : Colors.black,
                      ),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          SelectableLinkify(
            linkStyle: TextStyle(
              color: isDarkMode! ? primaryAccentColor : primaryColor,
              decoration: TextDecoration.none,
              fontSize: ds['description'].length > 100 ? 15 : 16.8,
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
            text: ds['description'],
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: ds['description'].length > 100 ? 14 : 16.8,
              height: 1.5,
              color: isDarkMode! ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: isDarkMode! ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  DatabaseMethods().likeBlog(
                    ds['blogId'],
                    ds['likes'],
                    ds,
                  );
                },
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                color: ds['likes'].contains(Userdetails.uid)
                    ? isDarkMode!
                        ? primaryAccentColor.withOpacity(0.1)
                        : primaryAccentColor.withOpacity(0.5)
                    : Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  child: Row(
                    children: [
                      LikeAnimation(
                        isAnimating: ds['likes'].contains(Userdetails.uid),
                        smallLike: true,
                        child: Icon(
                          ds['likes'].contains(Userdetails.uid)
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color:
                              isDarkMode! ? Colors.blue.shade100 : primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        ds['likes'].length.toString(),
                        style: GoogleFonts.openSans(
                          color:
                              isDarkMode! ? Colors.blue.shade100 : primaryColor,
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
                        blogId: ds['blogId'],
                        tokenId: ds['tokenId'],
                      ));
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
                        ds['comments'].toString() + ' Comments',
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
    );
  }
}
