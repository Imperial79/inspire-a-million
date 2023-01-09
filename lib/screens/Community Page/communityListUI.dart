import 'dart:ffi';
import 'dart:math';

import 'package:blog_app/screens/BlogCard/blogCard.dart';
import 'package:blog_app/screens/Community%20Page/ccommunity-homePageUI.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/sdp.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

import '../../utilities/constants.dart';

class CommunityListUI extends StatefulWidget {
  const CommunityListUI({Key? key}) : super(key: key);

  @override
  State<CommunityListUI> createState() => _CommunityListUIState();
}

class _CommunityListUIState extends State<CommunityListUI> {
  bool isSearching = false;
  final _searchController = TextEditingController();
  bool isPrivate = false;
  final _communityNameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool communityNameExist = false;
  List communityList = [];
  // Random r = new Random();

  // List<Color> iconColors = [
  //   Colors.redAccent,
  //   Colors.purple.shade200,
  //   Colors.blueAccent,
  //   Colors.greenAccent,
  //   Colors.amber,
  //   Colors.blue.shade100,
  //   Colors.red.shade300,
  //   Colors.green.shade300,
  //   Colors.deepPurple.shade100,
  //   Colors.orange.shade100,
  // ];

  @override
  void initState() {
    super.initState();
    fetchCommunitiesList();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _communityNameController.dispose();
  }

  Future<List> fetchCommunitiesList() async {
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('community')
        // .where('isPrivate', isEqualTo: false)
        .get();
    communityList = data.docs.map((DocumentSnapshot docSnapshot) {
      return docSnapshot.data();
    }).toList();
    return communityList;
  }

  createCommunity() async {
    if (_communityNameController.text.isNotEmpty) {
      ShowLoding(context); //  for loading
      await _firestore
          .collection('community')
          .where('communityTitle', isEqualTo: _communityNameController.text)
          .get()
          .then((value) async {
        if (value.docs.length > 0) {
          Navigator.pop(context);
          communityNameExist = true;
          setState(() {});
        } else {
          FocusScope.of(context).unfocus();
          communityNameExist = false;
          setState(() {});
          String uniqueCommunityId =
              "COM" + DateTime.now().millisecondsSinceEpoch.toString();
          Map<String, dynamic> communityMap = {
            'communityTitle': _communityNameController.text,
            'createdOn': DateTime.now().millisecondsSinceEpoch,
            'isPrivate': isPrivate,
            'createdBy': Userdetails.uniqueName,
            'communityId': uniqueCommunityId,
            'members': [Userdetails.uid],
          };
          await FirebaseFirestore.instance
              .collection('community')
              .doc(uniqueCommunityId)
              .set(communityMap);
          Navigator.pop(context); //  for loading
          Navigator.pop(context); //  for modal
          ShowSnackBar(
            context,
            'Community Created',
            showAction: true,
            actionLabel: 'Open',
            onPressed: () {
              NavPush(context, CommunityHomeUI(data: communityMap));
            },
          );
          _communityNameController.clear();
          isPrivate = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: isDarkMode ? blueGreyColor : whiteColor,
          color: isDarkMode ? primaryAccentColor : primaryColor,
          onRefresh: () {
            setState(() {});
            return fetchCommunitiesList();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),

                SearchBar(),

                //////////////////    WHEN NOT SEARCHING  ///////////////////////////
                Visibility(
                  visible: !isSearching,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SubLabel(context, text: 'Popular Tags'),
                        FutureBuilder<dynamic>(
                          future: FirebaseFirestore.instance
                              .collection('tags')
                              .doc('tags')
                              .get(),
                          builder: (context, snapshot) {
                            return AnimatedSwitcher(
                              duration: Duration(seconds: 1),
                              child: snapshot.hasData
                                  ? Wrap(
                                      children: List.generate(
                                        1,
                                        (index) {
                                          if (snapshot.data['tags'].isEmpty) {
                                            return Container();
                                          }
                                          return TagsCard(
                                            snapshot.data['tags'][0],
                                            context,
                                            true,
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox(
                                      height: 10,
                                      width: 10,
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: !isSearching,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SubLabel(context, text: 'Communities'),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            CreateCommunityButton(context),
                            Container(
                              height: 20,
                              width: 1,
                              color: isDarkMode ? blueGreyColor : greyColor,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            FutureBuilder<dynamic>(
                              future: fetchCommunitiesList(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.length == 0) {
                                    return SizedBox();
                                  }

                                  return Row(
                                    children: List.generate(
                                      snapshot.data.length,
                                      (index) => CommunityPreviewIcon(
                                        snapshot.data[index],
                                        index,
                                      ),
                                    ),
                                  );
                                }
                                return CustomLoading();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /////////////////////   WHEN SEARCHING    ///////////////////////////

                Visibility(
                  visible: isSearching,
                  child: Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: StreamBuilder<dynamic>(
                      stream: FirebaseFirestore.instance
                          .collection('blogs')
                          .snapshots(),
                      builder: (context, snapshot) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: snapshot.hasData
                              ? ListView.builder(
                                  itemCount: snapshot.data.docs.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    DocumentSnapshot ds =
                                        snapshot.data.docs[index];
                                    if (ds['description']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchController.text
                                            .trim()
                                            .toLowerCase())) {
                                      return BlogCard(
                                        snap: ds,
                                        isHome: true,
                                        isCommunity: false,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  },
                                )
                              : Center(
                                  child: CustomLoading(),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget CommunityPreviewIcon(var data, int index) {
    return Container(
      width: sdp(context, 60),
      // padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(right: 10),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: greyColorAccent,
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              GestureDetector(
                onTap: () {
                  NavPush(
                      context,
                      CommunityHomeUI(
                        data: data,
                      ));
                },
                child: Container(
                  height: sdp(context, 40),
                  width: sdp(context, 40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        index % 2 == 0 ? primaryColor : primaryAccentColor,
                        index % 2 != 0 ? primaryColor : primaryAccentColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(
                    data['communityTitle'][0],
                    style: TextStyle(
                      fontSize: sdp(context, 17),
                      color: whiteColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              data['isPrivate']
                  ? Positioned(
                      bottom: -5,
                      left: 15,
                      child: CircleAvatar(
                        radius: sdp(context, 8),
                        backgroundColor:
                            isDarkMode ? scaffoldDarkColor : scaffoldLightColor,
                        child: Icon(
                          Icons.lock,
                          color: isDarkMode ? primaryAccentColor : primaryColor,
                          size: sdp(context, 11),
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            data['communityTitle'],
            style: TextStyle(fontSize: sdp(context, 10)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  IconButton CreateCommunityButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return CreateCommunitySheet();
          },
        );
      },
      icon: CircleAvatar(
        radius: 27,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        child: Icon(
          Icons.add,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Container SearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: isDarkMode
            ? Colors.blueGrey.shade800
            : primaryAccentColor.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Icon(
            UniconsLine.search,
            size: 20,
          ),
          Flexible(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                border: InputBorder.none,
                hintText: 'Search Blogs, Tags etc',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  isSearching = true;
                  setState(() {});
                } else {
                  isSearching = false;
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget CreateCommunitySheet() {
    return SafeArea(
      child: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Create',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Product',
                            color:
                                isDarkMode ? primaryAccentColor : primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: '\nYour Own Community of Special!sts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Product',
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPrivate = !isPrivate;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: EdgeInsets.only(left: 10, top: 7, bottom: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isDarkMode
                            ? isPrivate
                                ? primaryColor
                                : Colors.grey.shade800
                            : isPrivate
                                ? primaryAccentColor
                                : Colors.grey.shade200,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'isPrivate',
                            style: TextStyle(fontSize: 17),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            isPrivate ? Icons.lock : Icons.lock_open,
                            size: 17,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          Spacer(),
                          Switch.adaptive(
                            value: isPrivate,
                            activeColor:
                                isDarkMode ? primaryAccentColor : primaryColor,
                            onChanged: (newValue) {
                              isPrivate = newValue;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        child: FittedBox(
                          child: Text(
                            '!',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' /',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: TextField(
                          controller: _communityNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: communityNameExist,
                    child: Text(
                      'Name already exists',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.red.shade300
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      createCommunity();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                    highlightElevation: 0,
                    color: isDarkMode ? primaryAccentColor : primaryColor,
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: isDarkMode ? blackColor : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
