// import 'package:blog_app/services/database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'blogCard.dart';
// import 'colors.dart';
// import 'services/globalVariable.dart';

// class HomeUI extends StatefulWidget {
//   const HomeUI({Key? key}) : super(key: key);

//   @override
//   State<HomeUI> createState() => _HomeUIState();
// }

// class _HomeUIState extends State<HomeUI> {
//   late ScrollController _scrollController;
//   List followingUsers = [];
//   List followers = [];
//   Stream? blogStream;
//   DocumentSnapshot<Map<String, dynamic>>? users;
//   bool dark = false;
//   String tokenId = '';

//   @override
//   void initState() {
//     super.initState();
//     // _scrollController =
//     //     new ScrollController(initialScrollOffset: 1011.636363636364)
//     //       ..addListener(_scrollListener);

//     getFollowingUsersPosts();
//   }

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) async {
//   //   if (state == AppLifecycleState.resumed) {
//   //     await FirebaseFirestore.instance
//   //         .collection("users")
//   //         .doc(Userdetails.uid)
//   //         .update({"active": "1"});
//   //   } else {
//   //     await FirebaseFirestore.instance
//   //         .collection("users")
//   //         .doc(Userdetails.uid)
//   //         .update({"active": "0"});
//   //   }
//   //   super.didChangeAppLifecycleState(state);
//   // }

//   // onPageLoad() async {
//   //   if (Userdetails.userName == '') {
//   //     SharedPreferences prefs = await SharedPreferences.getInstance();
//   //     Userdetails.userName = prefs.getString('USERNAMEKEY')!;
//   //     Userdetails.userEmail = prefs.getString('USEREMAILKEY')!;
//   //     Userdetails.uid = prefs.getString('USERKEY')!;
//   //     Userdetails.userDisplayName = prefs.getString('USERDISPLAYNAMEKEY')!;
//   //     Userdetails.userProfilePic = prefs.getString('USERPROFILEKEY')!;
//   //     Userdetails.myTokenId = prefs.getString('TOKENID')!;
//   //     setState(() {});
//   //     print(Userdetails.userEmail.split('@')[0]);
//   //   }

//   //   await FirebaseFirestore.instance
//   //       .collection("users")
//   //       .doc(Userdetails.uid)
//   //       .update({"active": "1"});
//   // }

//   Future<void> getFollowingUsersPosts() async {
//     await DatabaseMethods().getUsersIAmFollowing().then((value) {
//       setState(() {
//         users = value;
//         followingUsers = users!.data()!['following'];
//         followers = users!.data()!['followers'];
//         followingUsers.add(FirebaseAuth.instance.currentUser!.uid);

//         print('followers --------- ' + followers.toString());
//         DatabaseMethods().getBlogs(followingUsers).then((value) {
//           blogStream = value;
//         });
//       });
//     });
//     getFollowersToken();
//   }

//   // getTokenID() async {
//   //   var status = await OneSignal.shared.getDeviceState();
//   //   tokenId = status!.userId!;
//   //   print('My Token ID ---> ' + tokenId);

//   //   FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(Userdetails.uid)
//   //       .update({'tokenId': tokenId});

//   //   Userdetails.myTokenId = tokenId;
//   //   setState(() {});
//   // }

//   getFollowersToken() async {
//     ///////////////  GETTING FOLLOWER'S TOKEN ID LIST //////////////////////////////

//     if (followers.isNotEmpty) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .where('uid', whereIn: followers)
//           .get()
//           .then((user) {
//         if (user.size > 0) {
//           for (int i = 0; i < user.size; i++) {
//             print('Followers TokenId ------- ' + user.docs[i]['tokenId']);
//             Global.followersTokenId.add(user.docs[i]['tokenId']);
//           }
//         } else {
//           Global.followersTokenId = [];
//           print('No followers hence no tokenID');
//         }
//         // print('Followers TokenId ------- ' + followersTokenId.toString());

//         setState(() {});
//       });
//     }
//   }

//   _scrollListener() {
//     // print("Scroll Offset: " + _scrollController.offset.toString());
//     // print("Scroll Max Extent: " +
//     //     _scrollController.position.maxScrollExtent.toString());
//     // print("Scroll Out Range: " +
//     //     _scrollController.position.outOfRange.toString());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: StreamBuilder<dynamic>(
//         stream: blogStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             if (snapshot.data.docs.length == 0) {
//               return Container();
//             }
//             // print(snapshot.data.docs.length);

//             return ListView.builder(
//               // controller: _scrollController,
//               itemCount: snapshot.data.docs.length,
//               shrinkWrap: true,
//               physics: ClampingScrollPhysics(),
//               scrollDirection: Axis.vertical,
//               itemBuilder: (context, index) {
//                 DocumentSnapshot ds = snapshot.data.docs[index];
//                 return BlogCard(snap: ds);
//               },
//             );
//           }
//           return Padding(
//             padding: EdgeInsets.only(top: 100),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: isDarkMode! ? primaryAccentColor : primaryColor,
//                 strokeWidth: 1.6,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
