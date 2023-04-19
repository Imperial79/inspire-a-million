import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/screens/BlogCard/blogCard.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utilities/components.dart';
import '../../utilities/utility.dart';

class CommunityHomeUI extends StatefulWidget {
  final data;
  const CommunityHomeUI({Key? key, this.data}) : super(key: key);

  @override
  State<CommunityHomeUI> createState() => _CommunityHomeUIState();
}

class _CommunityHomeUIState extends State<CommunityHomeUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: sdp(context, 110),
            collapsedHeight: sdp(context, 60),
            // automaticallyImplyLeading: !isMainView,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(bottom: 14.0, left: 55.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // InkWell(
                  //   onTap: () {},
                  //   child: Icon(
                  //     Icons.info_outline,
                  //     color: isDarkMode ? blueGreyColor : greyColor,
                  //     size: sdp(context, 10),
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      widget.data['communityTitle'],
                      style: TextStyle(
                        color: !isDarkMode ? blackColor : whiteColor,
                        fontSize: sdp(context, 15),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFromMilliseconds(widget.data['createdOn']) +
                        ' | ' +
                        TimeFromMilliseconds(widget.data['createdOn']),
                    style: TextStyle(
                      fontSize: sdp(context, 7),
                      color: greyColor,
                    ),
                  ),
                  Text(
                    'Created By - @' + widget.data['createdBy'],
                    style: TextStyle(
                      fontSize: sdp(context, 7),
                      color: (isDarkMode ? primaryAccentColor : primaryColor)
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.scrolledUnder)
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).canvasColor,
            ),
            actions: [
              widget.data['members'].contains(Userdetails.uid)
                  ? TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('community')
                            .doc(widget.data['communityId'])
                            .update({
                          'members': FieldValue.arrayRemove([Userdetails.uid])
                        }).then((value) {
                          Navigator.pop(context);
                        });
                      },
                      style: ElevatedButton.styleFrom(),
                      child: Text(
                        'Leave',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.red.shade300
                              : Colors.red.shade700,
                          fontSize: sdp(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(),
                      child: Text(
                        'Join',
                        style: TextStyle(
                          color: isDarkMode ? primaryAccentColor : primaryColor,
                          fontSize: sdp(context, 13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                FutureBuilder<dynamic>(
                  future: FirebaseFirestore.instance
                      .collection('community')
                      .doc(widget.data['communityId'])
                      .collection('blogs')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length == 0) {
                        return NoBlogs(context);
                      }
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 100),
                        itemBuilder: (context, index) {
                          return BlogCard(
                            snap: snapshot.data.docs[index],
                            isHome: false,
                            isCommunity: true,
                          );
                        },
                      );
                    }
                    return Center(
                      child: CustomLoading(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.data['members'].contains(Userdetails.uid)
          ? FloatingActionButton(
              onPressed: () {
                NavPush(context, CreateBlogUi(communityDetails: widget.data));
              },
              backgroundColor: isDarkMode ? primaryAccentColor : primaryColor,
              elevation: 2,
              child: Icon(
                Icons.add,
                color: isDarkMode ? blackColor : whiteColor,
              ),
            )
          : null,
    );
  }
}
