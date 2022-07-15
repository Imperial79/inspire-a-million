import 'dart:ui';

import 'package:blog_app/colors.dart';
import 'package:blog_app/othersProfileUi.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: isDarkMode! ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode!
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'SEARCH',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 20,
                      fontSize: 23,
                      color: isDarkMode!
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 6),
                    child: Text(
                      'other users to motivate \'em and make more friends to !nspire - A Million',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        wordSpacing: 1,
                        letterSpacing: 1,
                        color: isDarkMode! ? Colors.grey.shade400 : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        autofocus: true,
                        enableSuggestions: true,
                        enableIMEPersonalizedLearning: true,
                        style: TextStyle(
                          color: isDarkMode! ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        controller: searchController,
                        cursorColor:
                            isDarkMode! ? Colors.blue.shade100 : primaryColor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          border: InputBorder.none,
                          hintText: '  Search other Motivators ...',
                          hintStyle: GoogleFonts.manrope(
                            color: Colors.grey,
                            fontSize: 15,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w600,
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
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    isShowUsers
                        ? FutureBuilder<dynamic>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .where('uid', isNotEqualTo: Userdetails.uid)
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
                                    return BuildListTile(ds);
                                  } else if (ds['username']
                                      .toString()
                                      .contains(searchController.text.trim())) {
                                    return BuildListTile(ds);
                                  } else if (ds['email']
                                      .toString()
                                      .contains(searchController.text.trim())) {
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
                                  fontSize: 40,
                                  color: isDarkMode!
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.grey.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
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
    );
  }

  Widget BuildListTile(DocumentSnapshot<Object?> ds) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: ListTile(
        onTap: () {
          FocusScope.of(context).unfocus();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OthersProfileUi(
                        uid: ds['uid'],
                        heroTag: ds['uid'],
                      )));
        },
        leading: Hero(
          tag: ds['imgUrl'],
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: CachedNetworkImage(
              imageUrl: ds['imgUrl'],
              imageBuilder: (context, image) => CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.4),
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
                color: isDarkMode! ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '@' + ds['username'],
          style: GoogleFonts.openSans(
            fontSize: 13,
            color: isDarkMode! ? primaryAccentColor : primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        tileColor:
            isDarkMode! ? Colors.grey.withOpacity(0.5) : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          // side: BorderSide(
          //   color: isDarkMode! ? primaryAccentColor : primaryColor,
          //   width: 1,
          // ),
        ),
      ),
    );
  }
}
