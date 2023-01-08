import 'package:blog_app/screens/Home%20Screen/searchui.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../screens/BlogCard/blogCard.dart';
import 'colors.dart';

Widget SubLabel(BuildContext context, {required String text}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10, top: 15),
    child: Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: sdp(context, 12),
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class StatsCard extends StatelessWidget {
  final press, label, count;
  const StatsCard({Key? key, this.press, this.label, this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isDarkMode ? blueGreyColorDark : primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  count,
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
                  color: isDarkMode ? primaryAccentColor : primaryColor,
                ),
                child: FittedBox(
                  child: Text(
                    label.toString().toUpperCase(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: sdp(context, 10),
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
        style: TextStyle(
          fontFamily: 'Monospace',
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
    return Container(
      height: sdp(context, 15),
      width: sdp(context, 15),
      child: CircularProgressIndicator(
        backgroundColor: isDarkMode ? blueGreyColorDark : primaryAccentColor,
        color: isDarkMode ? primaryAccentColor : primaryColor,
        strokeWidth: 3,
      ),
    );
  }
}

ShowLoding(BuildContext context) {
  Dialog alert = Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      child: Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? primaryAccentColor : primaryColor,
        ),
      ),
    ),
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget NoBlogs(BuildContext context) {
  return Center(
    child: FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No',
            style: TextStyle(
              fontSize: sdp(context, 30),
              fontWeight: FontWeight.w900,
              color: isDarkMode ? blueGreyColorDark : greyColorAccent,
            ),
          ),
          Text(
            'Blogs !',
            style: TextStyle(
              fontSize: sdp(context, 50),
              fontWeight: FontWeight.w900,
              color: isDarkMode ? blueGreyColorDark : greyColorAccent,
            ),
          ),
        ],
      ),
    ),
  );
}
