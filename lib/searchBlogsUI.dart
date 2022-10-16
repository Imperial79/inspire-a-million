import 'package:blog_app/BlogCard/blogCard.dart';
import 'package:blog_app/services/globalVariable.dart';
import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unicons/unicons.dart';

class SearchBlogsUI extends StatefulWidget {
  const SearchBlogsUI({Key? key}) : super(key: key);

  @override
  State<SearchBlogsUI> createState() => _SearchBlogsUIState();
}

class _SearchBlogsUIState extends State<SearchBlogsUI>
    with AutomaticKeepAliveClientMixin {
  bool isSearching = false;
  final _searchController = TextEditingController();
  bool isPrivate = false;
  final _communityNameController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool communityNameExist = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _communityNameController.dispose();
  }

  create(StateSetter setState) async {
    if (_communityNameController.text.isNotEmpty) {
      await _firestore
          .collection('community')
          .where('communityTitle', isEqualTo: _communityNameController.text)
          .get()
          .then((value) async {
        if (value.docs.length > 0) {
          communityNameExist = true;
          setState(() {});
        } else {
          communityNameExist = false;
          setState(() {});

          Map<String, dynamic> communityMap = {
            'communityTitle': _communityNameController.text,
            'createdOn': DateTime.now(),
            'isPrivate': isPrivate,
          };
          await _firestore.collection('community').add(communityMap).then((_) {
            Navigator.pop(context);
            ShowSnackBar(context, 'Community created !!');
          });

          _communityNameController.clear();
          isPrivate = false;
        }
      });
    }
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: isDarkMode
                      ? primaryAccentColor
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
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
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
              ),

              //////////////////    WHEN NOT SEARCHING  ///////////////////////////
              Visibility(
                visible: !isSearching,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('tags')
                            .doc('tags')
                            .snapshots(),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Communities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          IconButton(
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
                              radius: 30,
                              backgroundColor:
                                  isDarkMode ? Colors.black : Colors.white,
                              child: Icon(
                                Icons.add,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                        duration: Duration(seconds: 1),
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
                      create(setState);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                    highlightElevation: 0,
                    color: isDarkMode
                        ? primaryAccentColor.withOpacity(0.5)
                        : primaryAccentColor,
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
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
