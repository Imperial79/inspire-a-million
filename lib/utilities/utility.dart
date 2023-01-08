import 'package:blog_app/screens/BlogCard/commentCard.dart';
import 'package:blog_app/screens/BlogCard/tagsUI.dart';
import 'package:blog_app/screens/Community%20Page/ccommunity-homePageUI.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formatted_text/formatted_text.dart';
import 'package:intl/intl.dart';

import 'package:unicons/unicons.dart';
import '../services/database.dart';

Widget MenuModal(String blogId) {
  return SafeArea(
    child: StatefulBuilder(builder: (context, StateSetter setModalState) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.grey.shade700,
                  fontSize: 50,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                onPressed: () {
                  deletePost(context, blogId);
                  Navigator.pop(context);
                },
                color: isDarkMode
                    ? Colors.blueGrey.shade600
                    : Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        UniconsLine.trash_alt,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                      Text(
                        'Delete Blog',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.7,
                          color: isDarkMode
                              ? Colors.grey.shade100
                              : Colors.grey.shade800,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

deletePost(BuildContext context, final blogId) async {
  ShowLoding(context);
  await DatabaseMethods().deletePostDetails(blogId);
  Navigator.pop(context);
}

Future NavPush(context, screen) async {
  await Navigator.push(
      context, MaterialPageRoute(builder: (context) => screen));
}

Future NavPushReplacement(BuildContext context, screen) async {
  await Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}

Widget CommentList(String blogId) {
  return FutureBuilder<dynamic>(
    future: FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('time', descending: true)
        .get(),
    builder: (context, snapshot) {
      var primaryColor;
      return (snapshot.hasData)
          ? (snapshot.data.docs.length == 0)
              ? Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_rounded,
                        size: 70,
                        color: isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      Text(
                        'No Comments',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode
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

                    return CommentCard(
                      blogId: blogId,
                      snap: ds,
                      context: context,
                    );
                  },
                )
          : Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(
                  color: isDarkMode ? primaryAccentColor : primaryColor,
                  strokeWidth: 1.6,
                ),
              ),
            );
    },
  );
}

Widget TagsCard(String tag, BuildContext context, bool isHome) {
  return Padding(
    padding: EdgeInsets.only(right: 6),
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        if (isHome) {
          NavPush(context, TagsUI(tag: tag));
        }
      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.165),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    ),
  );
}

Widget DummyBlogCard() {
  return Column(
    children: List.generate(
      10,
      (index) => Container(
        margin: EdgeInsets.only(bottom: 10),
        width: double.infinity,
        // height: 200,
        color: Colors.grey.withOpacity(0.2),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        height: 20,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 100,
                        height: 10,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey.withOpacity(0.5),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    color: Colors.grey.withOpacity(0.5),
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

ShowSnackBar(
  BuildContext context,
  String text, {
  final bool showAction = false,
  final String actionLabel = '',
  void Function()? onPressed,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isDarkMode ? primaryAccentColor : blueGreyColorDark,
      content: Text(
        text,
        style: TextStyle(
          color: isDarkMode ? blackColor : whiteColor,
          fontFamily: 'Product',
          fontWeight: FontWeight.w600,
        ),
      ),
      action: showAction
          ? SnackBarAction(
              label: actionLabel,
              onPressed: onPressed!,
              textColor: isDarkMode ? blackColor : whiteColor,
            )
          : null,
    ),
  );
}

SnackBarThemeData SnackBarTheme() {
  return SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
    contentTextStyle: TextStyle(
      fontFamily: 'Product',
    ),
  );
}

String DateFromMilliseconds(int millisecondsSinceEpoch) {
  return DateFormat('d-MMM, y')
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
}

String TimeFromMilliseconds(int millisecondsSinceEpoch) {
  return DateFormat('hh:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch));
}

SystemColors({
  Brightness? statusBrightness,
  Brightness? statusIconBrightness,
  Brightness? navBrightness,
  Color? navColor,
  Color? statusColor,
}) {
  statusIconBrightness = isDarkMode ? Brightness.light : Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: statusColor,
      statusBarBrightness: statusBrightness,
      statusBarIconBrightness: statusIconBrightness,
      systemNavigationBarColor: navColor,
      systemNavigationBarIconBrightness: navBrightness,
    ),
  );
}

Widget FormatedBlog(BuildContext context, String description) {
  return FormattedText(
    description,
    style: TextStyle(
      letterSpacing: 0.5,
      color: isDarkMode ? whiteColor : darkGreyColor,
      fontWeight: FontWeight.w400,
      fontSize: description.length > 100 ? sdp(context, 11) : sdp(context, 17),
    ),
    formatters: [
      // ...FormattedTextDefaults.formattedTextDefaultFormatters,
      description.toString().endsWith('#')
          ? FormattedTextFormatter(
              patternChars: '#',
              style: TextStyle(
                color: isDarkMode ? whiteColor : blackColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                fontSize: description.length > 100
                    ? sdp(context, 13)
                    : sdp(context, 17),
                decoration: TextDecoration.underline,
              ),
            )
          : FormattedTextFormatter(
              patternChars: '#',
              style: TextStyle(
                color: isDarkMode ? primaryAccentColor : primaryColor,
                letterSpacing: 0.5,
                fontWeight: isDarkMode ? FontWeight.w500 : FontWeight.w600,
                fontSize: description.length > 100
                    ? sdp(context, 13)
                    : sdp(context, 17),
              ),
            ),
      FormattedTextFormatter(
        patternChars: '==',
        style: TextStyle(
          color: isDarkMode ? primaryAccentColor : primaryColor,
          letterSpacing: 0.5,
          fontWeight: isDarkMode ? FontWeight.w500 : FontWeight.w600,
          fontSize: description.length > 100 ? 14 : 20,
        ),
      ),
      FormattedTextFormatter(
        patternChars: '*',
        style: TextStyle(
          color: isDarkMode ? whiteColor : blackColor,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
          fontSize:
              description.length > 100 ? sdp(context, 13) : sdp(context, 17),
        ),
      ),
      FormattedTextFormatter(
        patternChars: '*/',
        style: TextStyle(
          color: isDarkMode ? whiteColor : blackColor,
          letterSpacing: 0.5,
          fontWeight: isDarkMode ? FontWeight.w500 : FontWeight.w600,
          fontFamily: 'Monospace',
          fontSize: description.length > 100 ? 14 : 20,
        ),
      ),
      FormattedTextFormatter(
        patternChars: '-h-',
        style: TextStyle(
          color: blackColor,
          letterSpacing: 0.5,
          fontWeight: isDarkMode ? FontWeight.w500 : FontWeight.w600,
          fontSize: description.length > 100 ? 14 : 20,
          backgroundColor:
              isDarkMode ? Colors.amber.withOpacity(0.7) : Colors.amber,
        ),
      ),
    ],
  );
}
