import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../BlogCard/blogCard.dart';
import '../utilities/colors.dart';
import '../dashboardUI.dart';
import '../services/database.dart';
import '../services/globalVariable.dart';
import '../utilities/utility.dart';

Stream? blogStream;
Future updateFollowingUsersList() async {
  await DatabaseMethods().getUsersIAmFollowing().then((value) {
    users = value;
    followingUsers = users!.data()!['following'];

    followers = users!.data()!['followers'];

    if (!followingUsers.contains(Userdetails.uid)) {
      followingUsers.add(FirebaseAuth.instance.currentUser!.uid);
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
  }

  getFollowersToken() async {
    ///////////////  GETTING FOLLOWER'S TOKEN ID LIST //////////////////////////////
    setState(() {});
    if (followers.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: followers)
          .get()
          .then((user) {
        if (user.size > 0) {
          for (int i = 0; i < user.size; i++) {
            Global.followersTokenId.add(user.docs[i]['tokenId']);
          }
        } else {
          Global.followersTokenId = [];
        }

        setState(() {});
      });
    } else {
      print('Followers empty');
    }
  }

  Future<void> getFollowingUsersPosts() async {
    await updateFollowingUsersList();

    DatabaseMethods().getBlogs(followingUsers).then((value) {
      blogStream = value;
      setState(() {});
    });

    getFollowersToken();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: primaryAccentColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        title: Header(context),
      ),
      body: followingUsers.isEmpty
          ? Container()
          : AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: followingUsers.isNotEmpty
                  ? RefreshIndicator(
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
                            return AnimatedSwitcher(
                              duration: Duration(seconds: 1),
                              child: snapshot.hasData
                                  ? ListView.builder(
                                      itemCount: snapshot.data.docs.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      addAutomaticKeepAlives: false,
                                      addRepaintBoundaries: false,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot ds =
                                            snapshot.data.docs[index];
                                        return BlogCard(
                                          snap: ds,
                                          isHome: true,
                                        );
                                      },
                                    )
                                  : Shimmer(
                                      child: DummyBlogCard(),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.grey.shade100,
                                          Colors.grey.shade400
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    )
                  : Container(),
            ),
    );
  }
}
