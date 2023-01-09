import 'package:blog_app/screens/BlogCard/commentCard.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../Profile_Screen/othersProfileUi.dart';
import '../../services/database.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/like_animation.dart';
import '../../utilities/utility.dart';
import 'commentUi.dart';
import 'likesUI.dart';

class BlogPreviewUI extends StatefulWidget {
  final DocumentSnapshot snap;
  final bool isCommunity;
  const BlogPreviewUI({Key? key, required this.snap, required this.isCommunity})
      : super(key: key);

  @override
  State<BlogPreviewUI> createState() => _BlogPreviewUIState();
}

class _BlogPreviewUIState extends State<BlogPreviewUI> {
  String _timeAgo = '';
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchComments() {
    return FirebaseFirestore.instance
        .collection('blogs')
        .doc(widget.snap['blogId'])
        .collection('comments')
        .orderBy('time', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          StreamBuilder<dynamic>(
            stream: widget.isCommunity
                ? FirebaseFirestore.instance
                    .collection('community')
                    .doc(widget.snap['communityId'])
                    .collection('blogs')
                    .doc(widget.snap['blogId'])
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('blogs')
                    .doc(widget.snap['blogId'])
                    .snapshots(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return buildBlogCard(snap: snapshot.data);
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
          ),
          // buildBlogCard(),
          StreamBuilder<dynamic>(
            stream: fetchComments(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.docs.length != 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: sdp(context, 15),
                          ),
                        ),
                      ),
                      ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: snapshot.data.docs.length,
                        shrinkWrap: true,
                        reverse: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];

                          return CommentCard(
                            blogId: widget.snap['blogId'],
                            snap: ds,
                            context: context,
                          );
                        },
                      ),
                    ],
                  );
                }
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No Comments Yet'),
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: isDarkMode
                      ? primaryAccentColor.withOpacity(0.3)
                      : primaryAccentColor,
                  color: isDarkMode ? primaryAccentColor : primaryColor,
                  strokeWidth: 3,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildBlogCard({required final DocumentSnapshot snap}) {
    _timeAgo = timeago
        .format(
          widget.snap['time'].toDate(),
          locale: 'en_short',
        )
        .replaceAll('~', '');
    _timeAgo = _timeAgo.contains('now') ? _timeAgo : _timeAgo + ' ago';
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode
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
                          if (snap['uid'] != Userdetails.uid) {
                            NavPush(
                                context,
                                OthersProfileUi(
                                  uid: snap['uid'],
                                )).then((value) => setState(() {}));
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: primaryAccentColor,
                          radius: 22,
                          backgroundImage: NetworkImage(
                            snap['profileImage'],
                          ),
                        ),
                      ),
                      StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('uid', isEqualTo: snap['uid'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            DocumentSnapshot ds = snapshot.data.docs[0];

                            var activeStatus = ds['active'];

                            return CircleAvatar(
                              radius: 7,
                              backgroundColor:
                                  isDarkMode ? Colors.black : Colors.white,
                              child: CircleAvatar(
                                radius: 5,
                                backgroundColor: activeStatus == '1'
                                    ? isDarkMode
                                        ? Colors.green.shade800
                                        : Colors.green
                                    : isDarkMode
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
                            if (snap['uid'] != Userdetails.uid) {
                              NavPush(
                                  context, OthersProfileUi(uid: snap['uid']));
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Text(
                              snap['uid'] == Userdetails.uid
                                  ? 'You'
                                  : snap['userDisplayName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 14,
                                color: isDarkMode
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
                          DateFormat('h:m a').format(snap['time'].toDate()) +
                              ' • ' +
                              _timeAgo +
                              ' • ' +
                              DateFormat('d-MMM, y')
                                  .format(snap['time'].toDate()),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: snap['uid'] == Userdetails.uid,
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return MenuModal(snap['blogId']);
                          },
                        );
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 13,
            ),

            ///////////////////// DESCRIPTION AREA ///////////////////////
            // Visibility(
            //   visible: !Uri.parse(snap['description']).isAbsolute,
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 10),
            //     child: SelectableLinkify(
            //       // toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
            //       linkStyle: TextStyle(
            //         color: isDarkMode ? primaryAccentColor : primaryColor,
            //         fontWeight: FontWeight.w500,
            //         fontSize: 14,
            //         letterSpacing: 0.4,
            //       ),
            //       onOpen: (link) async {
            //         if (await canLaunchUrl(Uri.parse(link.url))) {
            //           await launchUrl(
            //             Uri.parse(link.url),
            //             mode: LaunchMode.externalApplication,
            //           );
            //         } else {
            //           throw 'Could not launch $link';
            //         }
            //       },
            //       text: snap['description'].toString().replaceAll('/:', ':'),
            //       style: TextStyle(
            //         letterSpacing: 0.5,
            //         fontWeight: FontWeight.w500,
            //         fontSize: snap['description'].length > 100 ? 14 : 20,
            //         color: isDarkMode
            //             ? Colors.grey.shade300
            //             : Colors.grey.shade800,
            //       ),
            //     ),
            //   ),
            // ),
            FormatedBlog(context, widget.snap['description']),

            ////////////////////////////  TAGS AREA ////////////////////////////
            Visibility(
              visible: snap['tags'] != '',
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Wrap(
                  children: List.generate(
                    snap['tags'].length,
                    (index) {
                      return TagsCard(
                        snap['tags'][index],
                        context,
                        false,
                      );
                    },
                  ),
                ),
              ),
            ),

            ///////////////////// LIKE STATUS ///////////////////////

            snap['likes'].length == 0
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Be the first one to like the blog',
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(bottom: 10, top: 10),
                    child: Row(
                      children: [
                        snap['likes'].length == 1
                            ? StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('uid', isEqualTo: snap['likes'][0])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data.docs.length == 0) {
                                      return SingleLikePreview(profileImg: '');
                                    } else {
                                      DocumentSnapshot ds =
                                          snapshot.data.docs[0];
                                      return GestureDetector(
                                        onTap: () {
                                          if (ds['uid'] != Userdetails.uid) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OthersProfileUi(
                                                          uid: ds['uid'],
                                                        ))).then(
                                                (value) => setState(() {}));
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
                                    backgroundColor: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  );
                                },
                              )
                            : StreamBuilder<dynamic>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('uid', whereIn: snap['likes'])
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
                            NavPush(
                                context,
                                LikesUI(
                                  snap: snap,
                                ));
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Text(
                              snap['likes'].length == 1 &&
                                      snap['likes'].contains(Userdetails.uid)
                                  ? 'You liked it '
                                  : snap['likes'].length == 1
                                      ? ' Liked it'
                                      : snap['likes'].contains(Userdetails.uid)
                                          ? 'You and ' +
                                              (snap['likes'].length - 1)
                                                  .toString() +
                                              ' more have liked'
                                          : snap['likes'].length.toString() +
                                              ' people liked it',
                              style: TextStyle(
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

            Row(
              children: [
                ///////////////////// LIKE BUTTON ///////////////////////
                InkWell(
                  onTap: () {
                    DatabaseMethods().likeBlog(
                      snap['blogId'],
                      snap['likes'],
                      snap,
                    );
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      color: snap['likes'].contains(Userdetails.uid)
                          ? primaryAccentColor.withOpacity(0.2)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        LikeAnimation(
                          isAnimating: snap['likes'].contains(Userdetails.uid),
                          smallLike: true,
                          child: SvgPicture.asset(
                            snap['likes'].contains(Userdetails.uid)
                                ? 'lib/assets/icons/heart-fill.svg'
                                : 'lib/assets/icons/heart.svg',
                            color:
                                isDarkMode ? primaryAccentColor : primaryColor,
                          ),
                        ),
                        Visibility(
                          visible: snap['likes'].length != 0,
                          child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              snap['likes'].length.toString(),
                              style: TextStyle(
                                color: isDarkMode
                                    ? primaryAccentColor
                                    : primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Spacer(),
                ///////////////////// COMMENT BUTTON ///////////////////////
                MaterialButton(
                  onPressed: () {
                    NavPush(
                        context,
                        CommentUi(
                          blogId: snap['blogId'],
                          tokenId: snap['tokenId'],
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
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          height: 20,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          snap['comments'].toString() + ' ',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
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
    return Transform.scale(
      scale: 0.8,
      child: Container(
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
                          builder: (context) => OthersProfileUi(
                                uid: press1,
                              ))).then((value) => setState(() {}));
              },
              child: CircleAvatar(
                backgroundColor: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.2)
                    : Colors.grey.shade100,
                radius: 15,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor:
                      isDarkMode ? primaryAccentColor : primaryColor,
                  child: CachedNetworkImage(
                    imageUrl: img1,
                    imageBuilder: (context, image) => CircleAvatar(
                      radius: 13,
                      backgroundColor:
                          isDarkMode ? primaryAccentColor : primaryColor,
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
                                  uid: press2,
                                ))).then((value) => setState(() {}));
                },
                child: CircleAvatar(
                  backgroundColor: isDarkMode
                      ? Colors.grey.shade800.withOpacity(0.2)
                      : Colors.grey.shade100,
                  radius: 15,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor:
                        isDarkMode ? primaryAccentColor : primaryColor,
                    child: CachedNetworkImage(
                      imageUrl: img2,
                      imageBuilder: (context, image) => CircleAvatar(
                        radius: 13,
                        backgroundColor:
                            isDarkMode ? primaryAccentColor : primaryColor,
                        backgroundImage: image,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DummyDoubleLikePreview() {
    return Transform.scale(
      scale: 0.8,
      child: Container(
        width: 55,
        child: Stack(
          alignment: Alignment.topLeft,
          children: [
            CircleAvatar(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              radius: 15,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: isDarkMode ? primaryAccentColor : primaryColor,
              ),
            ),
            Positioned(
              left: 20,
              child: CircleAvatar(
                backgroundColor: isDarkMode ? Colors.black : Colors.white,
                radius: 15,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor:
                      isDarkMode ? primaryAccentColor : primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget SingleLikePreview({final profileImg}) {
    return Transform.scale(
      scale: 0.8,
      child: CircleAvatar(
        backgroundColor: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        radius: 17,
        child: profileImg == ''
            ? CircleAvatar(
                radius: 15,
                backgroundColor: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.grey.shade100,
              )
            : CircleAvatar(
                radius: 15,
                backgroundColor: isDarkMode ? primaryAccentColor : primaryColor,
                child: CachedNetworkImage(
                  imageUrl: profileImg,
                  imageBuilder: (context, image) => CircleAvatar(
                    radius: 15,
                    backgroundColor:
                        isDarkMode ? primaryAccentColor : primaryColor,
                    backgroundImage: image,
                  ),
                ),
              ),
      ),
    );
  }
}
