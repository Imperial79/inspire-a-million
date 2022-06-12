import 'dart:ui';

import 'package:blog_app/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/services/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateBlogUi extends StatefulWidget {
  const CreateBlogUi({Key? key}) : super(key: key);

  @override
  State<CreateBlogUi> createState() => _CreateBlogUiState();
}

class _CreateBlogUiState extends State<CreateBlogUi> {
  final description = TextEditingController();
  int textCount = 0;

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  uploadBlog() {
    if (description.text.isNotEmpty) {
      textCount = 0;
      var time = DateTime.now();
      Map<String, dynamic> blogMap = {
        'userDisplayName': Userdetails.userDisplayName,
        'description': description.text,
        'time': time,
        'blogId': time.toString(),
        'uid': Userdetails.uid,
        'profileImage': Userdetails.userProfilePic,
        'likes': [],
        'comments': 0,
        'tokenId': Userdetails.myTokenId,
      };

      DatabaseMethods().uploadBlogs(blogMap, time.toString());
      print('Folowers: ' + Global.followersTokenId.toString());
      sendNotification(
        Global.followersTokenId,
        '"' + description.text + '"',
        'A new post from ${Userdetails.userDisplayName}',
        Userdetails.userProfilePic,
      );
      FocusScope.of(context).unfocus();
      description.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post Blog',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  color: isDarkMode! ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    radius: 10,
                    child: CachedNetworkImage(
                      imageUrl: Userdetails.userProfilePic,
                      imageBuilder: (context, image) => CircleAvatar(
                        radius: 10,
                        backgroundImage: image,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'as  ' + Userdetails.userDisplayName,
                    style: GoogleFonts.openSans(
                      color: isDarkMode!
                          ? Colors.grey.shade300
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 10,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 5,
                      sigmaY: 5,
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkMode!
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: description,
                        cursorColor:
                            isDarkMode! ? Colors.blue.shade100 : primaryColor,
                        style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.8,
                          color:
                              isDarkMode! ? Colors.grey.shade300 : Colors.black,
                        ),
                        maxLines: 30,
                        decoration: InputDecoration(
                          hintText: 'Let\'s Inspire ...',
                          hintStyle: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.8,
                            color: isDarkMode!
                                ? Colors.grey.shade400
                                : Colors.grey,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 0) {
                            textCount = 0;
                            setState(() {});
                          }
                          textCount = value.split(' ').length;
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    description.text.isEmpty
                        ? Container()
                        : Text(
                            'Characters: ' + textCount.toString(),
                            style: GoogleFonts.openSans(
                              color: isDarkMode!
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                    MaterialButton(
                      onPressed: () {
                        uploadBlog();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      child: Text(
                        '!nspire',
                        style: GoogleFonts.openSans(
                          color:
                              isDarkMode! ? Colors.blue.shade900 : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
