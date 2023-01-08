import 'package:blog_app/createBlogUi.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/constants.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                    Text(
                      widget.data['communityTitle'],
                      style: TextStyle(
                        color: !isDarkMode ? blackColor : whiteColor,
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
                      'Created By - ' + widget.data['communityTitle'],
                      style: TextStyle(
                        fontSize: sdp(context, 7),
                        color: greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.scrolledUnder)
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).canvasColor,
              ),
              actions: [
                TextButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      // backgroundColor:
                      //     isDarkMode ? primaryAccentColor : primaryColor,
                      ),
                  child: Text(
                    'Join',
                    style: TextStyle(
                      fontSize: sdp(context, 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                NoBlogs(context),
                // ListView.builder(
                //   itemCount: 500,
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   itemBuilder: (context, index) {
                //     return Text('data');
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.data['members'].contains(Userdetails.uid)
          ? FloatingActionButton(
              onPressed: () {
                NavPush(context, CreateBlogUi());
              },
              elevation: 2,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
