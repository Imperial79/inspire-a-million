import 'dart:ui';

import 'package:blog_app/colors.dart';
import 'package:blog_app/othersProfileUi.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_route_transition/page_route_transition.dart';

class SearchUi extends StatefulWidget {
  const SearchUi({Key? key}) : super(key: key);

  @override
  State<SearchUi> createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {
  final searchController = TextEditingController();
  bool isShowUsers = false;
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search!',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              Text(
                'Users',
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: searchController,
                              cursorColor: isDarkMode!
                                  ? Colors.blue.shade100
                                  : primaryColor,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                                border: InputBorder.none,
                                hintText: 'Search other Motivators',
                                hintStyle: GoogleFonts.openSans(
                                  color: Colors.grey,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isShowUsers = true;
                                });
                                if (value.isEmpty) {
                                  setState(() {
                                    isShowUsers = false;
                                  });
                                }
                              },
                            ),
                          ),
                          searchController.text.isEmpty
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      searchController.clear();
                                      isShowUsers = false;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: isDarkMode!
                                        ? Colors.blueGrey.shade600
                                        : primaryColor,
                                    radius: 13,
                                    child: Icon(
                                      Icons.close,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      isShowUsers
                          ? FutureBuilder<dynamic>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: isDarkMode!
                                          ? Colors.blue.shade100
                                          : primaryColor,
                                      strokeWidth: 1.6,
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  itemCount: snapshot.data.docs.length,
                                  // scrollDirection: Axis.vertical,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot ds =
                                        snapshot.data.docs[index];
                                    if (ds['name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchController.text
                                            .trim()
                                            .toLowerCase())) {
                                      return ds['email'] ==
                                              Userdetails.userEmail
                                          ? Container()
                                          : BuildListTile(ds);
                                    } else if (ds['username']
                                        .toString()
                                        .contains(
                                            searchController.text.trim())) {
                                      return BuildListTile(ds);
                                    } else if (ds['email'].toString().contains(
                                        searchController.text.trim())) {
                                      return BuildListTile(ds);
                                    } else {
                                      return Container();
                                    }
                                  },
                                );
                              },
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(
                                child: Text(
                                  '!nspire',
                                  style: GoogleFonts.josefinSans(
                                    fontSize: 30,
                                    color: Colors.grey.shade300,
                                    fontWeight: FontWeight.w900,
                                  ),
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

  Widget BuildListTile(DocumentSnapshot<Object?> ds) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          FocusScope.of(context).unfocus();
          PageRouteTransition.push(context, OthersProfileUi(uid: ds['uid']));
        },
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Hero(
            tag: ds['imgUrl'],
            child: CachedNetworkImage(
              imageUrl: ds['imgUrl'],
              imageBuilder: (context, image) => CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                backgroundImage: image,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ds['name'],
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            // SizedBox(
            //   height: 4,
            // ),
            // Text(
            //   '@' + ds['username'],
            //   style: GoogleFonts.openSans(
            //     fontSize: 13,
            //     color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
        subtitle: Text(
          '@' + ds['username'],
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDarkMode! ? Colors.blue.shade100 : primaryColor,
            width: 1,
          ),
        ),
      ),
    );
  }
}
