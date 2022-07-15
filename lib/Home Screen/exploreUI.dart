import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../blogCard.dart';
import '../colors.dart';
import '../dashboardUI.dart';
import '../services/database.dart';
import '../services/globalVariable.dart';

Stream? blogStream;
Future updateFollowingUsersList() async {
  await DatabaseMethods().getUsersIAmFollowing().then((value) {
    users = value;
    followingUsers = users!.data()!['following'];
    print('Following => ' + followingUsers.toString());
    followers = users!.data()!['followers'];

    if (!followingUsers.contains(Userdetails.uid)) {
      followingUsers.add(FirebaseAuth.instance.currentUser!.uid);
      print('My UID => ' + Userdetails.uid);
    }
  });
  return print('Following Users [' +
      followingUsers.length.toString() +
      '] ---------> ' +
      followingUsers.toString());
}

class ExploreUI extends StatefulWidget {
  const ExploreUI({Key? key}) : super(key: key);

  @override
  State<ExploreUI> createState() => _ExploreUIState();
}

class _ExploreUIState extends State<ExploreUI> {
  @override
  void initState() {
    super.initState();

    getFollowingUsersPosts();
    // _scrollController =
    //     new ScrollController(initialScrollOffset: savedScrollOffset)
    //       ..addListener(_scrollListener);
  }

  // jumpToScrollOffset() {
  //   _scrollController.animateTo(
  //     savedScrollOffset,
  //     duration: Duration(seconds: 1),
  //     curve: Curves.decelerate,
  //   );
  // }

  // _scrollListener() {
  //   savedScrollOffset = _scrollController.offset;
  // }

  getFollowersToken() async {
    ///////////////  GETTING FOLLOWER'S TOKEN ID LIST //////////////////////////////

    if (followers.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: followers)
          .get()
          .then((user) {
        if (user.size > 0) {
          for (int i = 0; i < user.size; i++) {
            print('Followers TokenId ------- ' + user.docs[i]['tokenId']);
            Global.followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          Global.followersTokenId = [];
          print('No followers thus no tokenID');
        }
        // print('Followers TokenId ------- ' + followersTokenId.toString());

        setState(() {});
      });
    }
  }

  Future<void> getFollowingUsersPosts() async {
    updateFollowingUsersList().then((res) => setState(() {
          print(res);
        }));

    getFollowersToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        surfaceTintColor: primaryAccentColor,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              isDarkMode! ? Brightness.light : Brightness.dark,
        ),
        title: Header(context),
      ),
      body: followingUsers.isEmpty
          ? Center(child: CustomLoading())
          : RefreshIndicator(
              onRefresh: () {
                return updateFollowingUsersList()
                    .then((value) => setState(() {}));
              },
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: StreamBuilder<dynamic>(
                  stream: FirebaseFirestore.instance
                      .collection('blogs')
                      .where('uid', whereIn: followingUsers)
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.docs.length == 0) {
                        return Container();
                      }
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return BlogCard(snap: ds);
                        },
                      );
                    }
                    return Center(child: CustomLoading());
                  },
                ),
              ),
            ),
    );
  }
}
