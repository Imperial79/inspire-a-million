import 'package:blog_app/colors.dart';
import 'package:blog_app/commentUi.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/like_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';

class InspiredUi extends StatefulWidget {
  final snap;
  InspiredUi({required this.snap});

  @override
  State<InspiredUi> createState() => _InspiredUiState();
}

class _InspiredUiState extends State<InspiredUi> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
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
                      Text(
                        'You',
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          color:
                              isDarkMode! ? Colors.grey.shade300 : Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Inspired',
                        style: GoogleFonts.openSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color:
                              isDarkMode! ? Colors.blue.shade100 : primaryColor,
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
                          style: GoogleFonts.openSans(
                            color: Colors.grey.shade300,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: CachedNetworkImage(
                              imageUrl: ds['imgUrl'],
                              imageBuilder: (context, image) => CircleAvatar(
                                backgroundImage: image,
                              ),
                            ),
                          ),
                          title: Text(
                            ds['name'] == Userdetails.userDisplayName
                                ? 'You'
                                : ds['name'],
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode!
                                  ? Colors.grey.shade200
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '@' + ds['username'],
                            style: GoogleFonts.openSans(
                              color: isDarkMode!
                                  ? Colors.blue.shade100
                                  : primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                        // Container(
                        //   padding: EdgeInsets.all(10),
                        //   margin: EdgeInsets.only(bottom: 10),
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey.withOpacity(0.05),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //       Text(
                        //         ds['description'],
                        //         style: GoogleFonts.openSans(
                        //           fontWeight: FontWeight.w600,
                        //           fontSize: 16.8,
                        //           height: 1.5,
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //       Divider(),
                        //       Row(
                        //         children: [
                        //           MaterialButton(
                        //             onPressed: () {
                        //               DatabaseMethods().likeBlog(
                        //                   ds['blogId'], ds['likes']);
                        //             },
                        //             padding: EdgeInsets.zero,
                        //             shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(7),
                        //             ),
                        //             color:
                        //                 primaryAccentColor.withOpacity(0.5),
                        //             elevation: 0,
                        //             highlightElevation: 0,
                        //             child: Container(
                        //               padding: EdgeInsets.symmetric(
                        //                   horizontal: 10, vertical: 9),
                        //               child: Row(
                        //                 children: [
                        //                   LikeAnimation(
                        //                     isAnimating: ds['likes'].contains(
                        //                         Userdetails.userProfilePic),
                        //                     smallLike: true,
                        //                     child: Icon(
                        //                       ds['likes'].contains(Userdetails
                        //                               .userProfilePic)
                        //                           ? Icons.favorite
                        //                           : Icons.favorite_outline,
                        //                       color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                        //                     ),
                        //                   ),
                        //                   SizedBox(
                        //                     width: 5,
                        //                   ),
                        //                   Text(
                        //                     ds['likes'].length.toString(),
                        //                     style: GoogleFonts.openSans(
                        //                       color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                        //                       fontWeight: FontWeight.w900,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: 20,
                        //           ),
                        //           MaterialButton(
                        //             onPressed: () {
                        //               PageRouteTransition.effect =
                        //                   TransitionEffect.bottomToTop;
                        //               PageRouteTransition.push(
                        //                   context,
                        //                   CommentUi(
                        //                     blogId: ds['blogId'],
                        //                   ));
                        //             },
                        //             padding: EdgeInsets.zero,
                        //             shape: RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(7),
                        //             ),
                        //             elevation: 0,
                        //             child: Container(
                        //               padding: EdgeInsets.symmetric(
                        //                   horizontal: 10, vertical: 9),
                        //               child: Row(
                        //                 children: [
                        //                   SvgPicture.asset(
                        //                     'lib/assets/icons/comment.svg',
                        //                     color: Colors.grey.shade600,
                        //                     height: 20,
                        //                   ),
                        //                   SizedBox(
                        //                     width: 7,
                        //                   ),
                        //                   Text(
                        //                     ds['comments'].toString() +
                        //                         ' Comments',
                        //                     style: GoogleFonts.openSans(
                        //                       color: Colors.grey.shade600,
                        //                       fontWeight: FontWeight.w700,
                        //                     ),
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
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
}
