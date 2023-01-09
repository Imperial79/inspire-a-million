import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/services/database.dart';
import 'package:blog_app/utilities/notification_function.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:formatted_text_hooks/formatted_text_hooks.dart';

import 'utilities/constants.dart';

class CreateBlogUi extends StatefulWidget {
  final Map? communityDetails;
  const CreateBlogUi({Key? key, this.communityDetails}) : super(key: key);

  @override
  State<CreateBlogUi> createState() => _CreateBlogUiState();
}

class _CreateBlogUiState extends State<CreateBlogUi> {
  final description = FormattedTextEditingController();
  int textCount = 0;
  bool isCommunity = false;

  @override
  void initState() {
    super.initState();
    if (widget.communityDetails != null) {
      isCommunity = true;
    }
  }

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

      var time = DateTime.now();

      // Creating a Map to upload in DB
      Map<String, dynamic> blogMap = {
        'userDisplayName': Userdetails.userDisplayName,
        'description': content.replaceAll(':', '/:'),
        'time': time,
        'blogId': time.toString(),
        'uid': Userdetails.uid,
        'profileImage': Userdetails.userProfilePic,
        'likes': [],
        'comments': 0,
        'tokenId': Userdetails.myTokenId,
        'tags': _extarctedTags,
      };
      if (isCommunity) {
        blogMap['communityId'] = widget.communityDetails!['communityId'];
        DatabaseMethods().uploadCommunityBlog(
          widget.communityDetails!['communityId'],
          time.toString(),
          blogMap,
        );
      } else {
        DatabaseMethods().uploadBlogs(blogMap, time.toString());
      }

      // print('Folowers: ' + Global.followersTokenId.toString());

      FocusScope.of(context)
          .unfocus(); //unfocussing the keyboard after uploading the blog

      description.clear(); // clearing the text field
      if (!isCommunity) {
        sendNotification(
          tokenIdList: Global.followersTokenId,
          contents: '"' + content + '"',
          heading: 'A new post from ${Userdetails.userDisplayName}',
          largeIconUrl: Userdetails.userProfilePic,
        );
      } else {
        Navigator.pop(context);
      }
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ThisHeader(),
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
                    selectionControls: FormattedTextSelectionControls(
                      actions: [
                        ...FormattedTextDefaults
                            .formattedTextToolbarDefaultActions,
                      ],
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
                      ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (description.text.isNotEmpty) {
                            uploadBlog(
                                context: context, content: description.text);
                          } else {
                            ShowSnackBar(
                              context,
                              'Write Something !!',
                              onPressed: () {},
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          backgroundColor:
                              isDarkMode ? primaryAccentColor : primaryColor,
                        ),
                        icon: Icon(
                          Icons.file_upload_outlined,
                          color: isDarkMode ? blackColor : whiteColor,
                        ),
                        label: Text(
                          '!nspire',
                          style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 16,
                            color: isDarkMode ? blackColor : whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment:
            isCommunity ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
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
            mainAxisSize: isCommunity ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: sdp(context, 10),
                child: CachedNetworkImage(
                  imageUrl: Userdetails.userProfilePic,
                  imageBuilder: (context, image) => CircleAvatar(
                    radius: sdp(context, 10),
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
                  color:
                      isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (isCommunity)
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: sdp(context, 10),
                    backgroundColor:
                        isDarkMode ? primaryAccentColor : primaryColor,
                    child: Icon(
                      Icons.group,
                      size: sdp(context, 11),
                      color: isDarkMode ? blackColor : whiteColor,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.communityDetails!['communityTitle'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
