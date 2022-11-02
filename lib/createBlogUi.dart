import 'dart:ui';

import 'package:blog_app/Models/blogModel.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateBlogUi extends StatefulWidget {
  const CreateBlogUi({Key? key}) : super(key: key);

  @override
  State<CreateBlogUi> createState() => _CreateBlogUiState();
}

class _CreateBlogUiState extends State<CreateBlogUi> {
  final description = TextEditingController();
  int textCount = 0;

  List extractTags(String content) {
    var contentArr = content.split(' ');

    List tags = [];
    for (int i = 0; i < contentArr.length; i++) {
      if (contentArr[i].toString().startsWith('#')) {
        tags.add(contentArr[i]);
      }
    }

    FirebaseFirestore.instance.collection('tags').doc('tags').update({
      'tags': FieldValue.arrayUnion(tags),
    });
    return tags;
  }

  uploadBlog({required String content, required BuildContext context}) {
    if (content.isNotEmpty) {
      List _extarctedTags = [];
      _extarctedTags = extractTags(content);
      // print('Extarcted tags = ' + _extarctedTags.toString());

      var time = DateTime.now();

      // Creating a Map to upload in DB
      Blog newBlog = Blog(
        userDisplayName: Userdetails.userDisplayName,
        description: content.replaceAll(":", "/:"),
        time: time,
        blogId: time.toString(),
        uid: Userdetails.uid,
        profileImage: Userdetails.userProfilePic,
        likes: [],
        comments: 0,
        tokenId: Userdetails.myTokenId,
        tags: _extarctedTags,
      );

      DatabaseMethods().uploadBlogs(newBlog.toMap(), time.toString());

      FocusScope.of(context)
          .unfocus(); //unfocussing the keyboard after uploading the blog

      description.clear(); // clearing the text field

      sendNotification(
        tokenIdList: Global.followersTokenId,
        contents: '"' + content + '"',
        heading: 'A new post from ${Userdetails.userDisplayName}',
        largeIconUrl: Userdetails.userProfilePic,
      );
    }
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        title: ThisHeader(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.5),
                  ),
                  child: TextField(
                    controller: description,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      cut: true,
                      paste: true,
                      selectAll: true,
                    ),
                    dragStartBehavior: DragStartBehavior.down,
                    autocorrect: false,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    cursorColor:
                        isDarkMode ? Colors.blue.shade100 : primaryColor,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      fontSize: 16.8,
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                    ),
                    maxLines: 30,
                    decoration: InputDecoration(
                      hintText: ' Let\'s Inspire ...',
                      hintStyle: TextStyle(
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.8,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
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
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: description.text.isNotEmpty,
                        child: Text(
                          'Words: ' + textCount.toString(),
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade200
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (description.text.isNotEmpty) {
                            uploadBlog(
                                context: context, content: description.text);
                          }
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode ? primaryAccentColor : primaryColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '!nspire',
                            style: TextStyle(
                              letterSpacing: 1,
                              fontSize: 16,
                              color: isDarkMode ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // MaterialButton(
                      //   onPressed: () {
                      //     if (description.text.isNotEmpty) {
                      //       uploadBlog(
                      //           context: context, content: description.text);
                      //     }
                      //   },
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(50),
                      //   ),
                      //   color: isDarkMode ? primaryAccentColor : primaryColor,
                      //   padding: EdgeInsets.symmetric(vertical: 12),
                      //   elevation: 0,
                      //   child: Text(
                      //     '!nspire',
                      //     style: TextStyle(
                      //       letterSpacing: 0.5,
                      //       fontSize: 20,
                      //       color: isDarkMode ? primaryColor : Colors.white,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ThisHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          '!NSPIRE A MILLION!',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.grey.shade800,
            letterSpacing: 4,
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
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
              Userdetails.userDisplayName,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
