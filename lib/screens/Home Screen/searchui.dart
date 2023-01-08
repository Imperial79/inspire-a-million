import 'package:blog_app/utilities/colors.dart';
import 'package:blog_app/screens/Profile_Screen/othersProfileUi.dart';
import 'package:blog_app/utilities/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utilities/constants.dart';

class SearchUi extends StatefulWidget {
  const SearchUi({Key? key}) : super(key: key);

  @override
  State<SearchUi> createState() => _SearchUiState();
}

class _SearchUiState extends State<SearchUi> {
  final searchController = TextEditingController();
  bool isShowUsers = false;
  QuerySnapshot<Map<String, dynamic>>? users;
  List usersList = [];
  List usersFiltered = [];

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
    searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  fetchAllUsers() async {
    users = await FirebaseFirestore.instance.collection('users').get();

    usersList = users!.docs.map((e) {
      return e.data();
    }).toList();
    setState(() {});
  }

  filterUsers() {
    List _users = [];
    _users.addAll(usersList);
    if (searchController.text.isNotEmpty) {
      _users.retainWhere((prod) {
        // print(prod['title']);
        String searchTerm = searchController.text.toLowerCase().trim();
        String name = prod['name'].toString().toLowerCase();
        String username = prod['username'].toString().toLowerCase();
        String email = prod['username'].toString().toLowerCase();
        return username.contains(searchTerm) ||
            name.contains(searchTerm) ||
            email.contains(searchTerm);
      });

      setState(() {
        usersFiltered = _users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'SEARCH',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 15,
                        fontSize: 23,
                        color: isDarkMode
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 6),
                      child: Text(
                        'other users to motivate \'em and make more friends to !nspire - A Million',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          wordSpacing: 1,
                          letterSpacing: 1,
                          color:
                              isDarkMode ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                        controller: searchController,
                        cursorColor:
                            isDarkMode ? primaryAccentColor : primaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '  Search other Motivators ...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500,
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
                    Visibility(
                      visible: searchController.text.isNotEmpty,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                            isShowUsers = false;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: isDarkMode
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
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: isShowUsers,
                child: ListView.builder(
                  shrinkWrap: true,
                  // physics: NeverScrollableScrollPhysics(),
                  itemCount:
                      isSearching ? usersFiltered.length : usersList.length,
                  itemBuilder: (context, index) {
                    var usersData =
                        isSearching ? usersFiltered[index] : usersList[index];
                    if (usersData.isEmpty) {
                      return Text('No Data');
                    }
                    return UsersSearchTile(usersData);
                  },
                ),
                replacement: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text(
                      '!nspire',
                      style: TextStyle(
                        fontSize: 40,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Column(
              //   children: [

              //     // isShowUsers
              //     //     ? FutureBuilder<dynamic>(
              //     //         future: FirebaseFirestore.instance
              //     //             .collection('users')
              //     //             .where('uid', isNotEqualTo: Userdetails.uid)
              //     //             .get(),
              //     //         builder: (context, snapshot) {
              //     //           if (!snapshot.hasData) {
              //     //             return Center(child: CustomLoading());
              //     //           }
              //     //           return ListView.builder(
              //     //             padding: EdgeInsets.symmetric(vertical: 20),
              //     //             itemCount: snapshot.data.docs.length,
              //     //             physics: NeverScrollableScrollPhysics(),
              //     //             shrinkWrap: true,
              //     //             itemBuilder: (context, index) {
              //     //               DocumentSnapshot ds = snapshot.data.docs[index];
              //     //               if (ds['name']
              //     //                   .toString()
              //     //                   .toLowerCase()
              //     //                   .contains(searchController.text
              //     //                       .trim()
              //     //                       .toLowerCase())) {
              //     //                 return BuildListTile(ds);
              //     //               } else if (ds['username']
              //     //                   .toString()
              //     //                   .contains(searchController.text.trim())) {
              //     //                 return BuildListTile(ds);
              //     //               } else if (ds['email']
              //     //                   .toString()
              //     //                   .contains(searchController.text.trim())) {
              //     //                 return BuildListTile(ds);
              //     //               } else {
              //     //                 return Container();
              //     //               }
              //     //             },
              //     //           );
              //     //         },
              //     //       )
              //     //     : Padding(
              //     //         padding: EdgeInsets.only(top: 100),
              //     //         child: Center(
              //     //           child: Text(
              //     //             '!nspire',
              //     //             style: TextStyle(
              //     //               fontSize: 40,
              //     //               color: isDarkMode
              //     //                   ? Colors.white.withOpacity(0.5)
              //     //                   : Colors.grey.withOpacity(0.5),
              //     //               fontWeight: FontWeight.w500,
              //     //             ),
              //     //           ),
              //     //         ),
              //     //       ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget UsersSearchTile(var ds) {
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
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Text(
          '@' + ds['username'],
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? primaryAccentColor : primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        tileColor: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.6)
            : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          // side: BorderSide(
          //   color: isDarkMode ? primaryAccentColor : primaryColor,
          //   width: 1,
          // ),
        ),
      ),
    );
  }
}
