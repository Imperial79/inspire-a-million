import 'package:blog_app/Home%20Screen/searchui.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../BlogCard/blogCard.dart';
import 'colors.dart';

class StatsCard extends StatefulWidget {
  final press, label, count;
  const StatsCard({Key? key, this.press, this.label, this.count})
      : super(key: key);

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.press,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDarkMode
                ? primaryAccentColor.withOpacity(0.2)
                : primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  widget.count,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: isDarkMode
                      ? primaryAccentColor.withOpacity(0.7)
                      : primaryColor,
                ),
                child: FittedBox(
                  child: Text(
                    widget.label.toString().toUpperCase(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

StreamBuilder<dynamic> BlogList({final isMe, name, uid}) {
  return StreamBuilder<dynamic>(
    stream: FirebaseFirestore.instance
        .collection('blogs')
        .where('uid', isEqualTo: uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data.docs.length == 0) {
          return Center(
            child: isMe
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Write Blogs',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey.shade300 : Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '&\n!nspire a Million',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.grey.shade300 : Colors.grey,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Text(
                    'No Blogs',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey,
                      fontSize: 20,
                      letterSpacing: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        }

        return Column(
          children: [
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           isMe ? 'Your' : name + '\'s',
            //           style: TextStyle(
            //             letterSpacing: 1,
            //             fontSize: 15,
            //             color: isDarkMode ? Colors.grey.shade300 : Colors.black,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //         Text(
            //           'INSPIRATIONS',
            //           style: TextStyle(
            //             fontSize: 20,
            //             letterSpacing: 10,
            //             fontWeight: FontWeight.w600,
            //             color: isDarkMode
            //                 ? primaryAccentColor.withOpacity(0.8)
            //                 : primaryColor,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            ListView.builder(
              itemCount: snapshot.data.docs.length,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.docs[index];
                return BlogCard(snap: ds, isHome: true);
              },
            ),
          ],
        );
      }
      return Center(
        child: CustomLoading(),
      );
    },
  );
}

Widget Header(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        '!nspire',
        style: GoogleFonts.playfairDisplay(
          // color: isDarkMode ? primaryAccentColor : primaryColor,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          fontSize: sdp(context, 20),
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (ctx) => SearchUi()));
        },
        borderRadius: BorderRadius.circular(50),
        splashColor: primaryAccentColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: primaryAccentColor,
          ),
          child: SvgPicture.asset(
            'lib/assets/icons/search.svg',
            height: 18,
            color: Colors.black,
          ),
        ),
      ),
    ],
  );
}

class CustomLoading extends StatelessWidget {
  const CustomLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      backgroundColor:
          isDarkMode ? primaryAccentColor.withOpacity(0.3) : primaryAccentColor,
      color: isDarkMode ? primaryAccentColor : primaryColor,
      strokeWidth: 3,
    );
  }
}