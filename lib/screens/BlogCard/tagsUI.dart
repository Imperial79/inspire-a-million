import 'package:blog_app/screens/BlogCard/blogCard.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utilities/constants.dart';

class TagsUI extends StatefulWidget {
  final tag;
  const TagsUI({Key? key, this.tag}) : super(key: key);

  @override
  State<TagsUI> createState() => _TagsUIState();
}

class _TagsUIState extends State<TagsUI> {
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.tag,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: Colors.blue.withOpacity(0.2),
              ),
              child: Text(
                'Tag is a label attached to someone or something for the purpose of identification or to give other information.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<dynamic>(
                      stream: FirebaseFirestore.instance
                          .collection('blogs')
                          .where('tags', arrayContains: widget.tag)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          child: snapshot.hasData
                              ? snapshot.data.docs.length == 0
                                  ? Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 50, left: 20, right: 20),
                                        child: Text(
                                          'No blogs with this tag',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 40,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: snapshot.data.docs.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot ds =
                                            snapshot.data.docs[index];
                                        return BlogCard(
                                          snap: ds,
                                          isHome: false,
                                        );
                                      },
                                    )
                              : Center(
                                  child: CustomLoading(),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
