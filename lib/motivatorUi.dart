import 'package:blog_app/colors.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MotivatorUi extends StatefulWidget {
  final from;
  final snap;
  MotivatorUi({this.snap, this.from});

  @override
  State<MotivatorUi> createState() => _MotivatorUiState();
}

class _MotivatorUiState extends State<MotivatorUi> {
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
                        'Your',
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          color:
                              isDarkMode! ? Colors.grey.shade200 : Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Motivators',
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
                    .where('followers', arrayContains: widget.snap['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length == 0) {
                      return Center(
                        child: Text(
                          'No Users',
                          style: GoogleFonts.openSans(
                            color: Colors.blueGrey.shade200,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
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
                          trailing: widget.from == 'others'
                              ? null
                              : MaterialButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(ds['uid'])
                                        .update({
                                      'followers': FieldValue.arrayRemove(
                                          [Userdetails.uid]),
                                    });

                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(Userdetails.uid)
                                        .update({
                                      'following':
                                          FieldValue.arrayRemove([ds['uid']])
                                    });
                                  },
                                  elevation: 0,
                                  // color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      color: Colors.blueGrey.shade200,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: Text(
                                    'Unfollow',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode!
                                          ? Colors.blue.shade100
                                          : primaryColor,
                                      // fontSize: 16,
                                    ),
                                  ),
                                ),
                        );
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
