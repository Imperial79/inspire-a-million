import 'dart:developer';

import 'package:blog_app/loginUi.dart';
import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../dashboardUI.dart';
import '../utilities/constants.dart';
import 'database.dart';
import '../utilities/components.dart';

//creating an instance of Firebase Authentication
class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  signInWithgoogle(context) async {
    await Hive.openBox('User');
    final _UserBox = Hive.box('User');

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication!.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    Map<String, dynamic> userMap = {
      'uid': userDetails!.uid,
      "email": userDetails.email,
      "username": userDetails.email!.split('@').first,
      "name": userDetails.displayName,
      "imgUrl": userDetails.photoURL,
    };

    await _UserBox.put('userMap', userMap);

    //  Saving in local session ------->

    Userdetails.uid = userDetails.uid;
    Userdetails.userEmail = userDetails.email!;
    Userdetails.userDisplayName = userDetails.displayName!;
    Userdetails.uniqueName = userDetails.email!.split('@')[0];
    Userdetails.userProfilePic = userDetails.photoURL!;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userDetails.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        Userdetails.userDisplayName = value.data()!['name'];
        userMap.update('name', (value) => Userdetails.userDisplayName);
        _UserBox.put('userMap', userMap);

        await DatabaseMethods().setUserOnline();
        NavPushReplacement(context, DashboardUI());
      } else {
        Map<String, dynamic> userInfoMap = {
          'uid': userDetails.uid,
          "email": userDetails.email,
          "username": userDetails.email!.split('@')[0],
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          'tokenId': '',
          'followers': [],
          'following': [],
        };
        await databaseMethods
            .addUserInfoToDB(userDetails.uid, userInfoMap)
            .then((value) async {
          await DatabaseMethods().setUserOnline();
          NavPushReplacement(context, DashboardUI());
        });
      }
    });
  }

  switchAccount(context) async {
    Userdetails.userEmail = '';

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Userdetails.uid)
        .update({"active": "1"}).then((value) {});

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    await _googleSignIn.disconnect();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication!.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    final SharedPreferences prefs = await _prefs;

    prefs.setString('USERKEY', userDetails!.uid);
    prefs.setString('USERNAMEKEY', userDetails.email!.split('@')[0]);
    prefs.setString('USERDISPLAYNAMEKEY', userDetails.displayName!);
    prefs.setString('USEREMAILKEY', userDetails.email!);
    prefs.setString('USERPROFILEKEY', userDetails.photoURL!);

    Userdetails.uid = userDetails.uid;
    Userdetails.userEmail = userDetails.email!;
    Userdetails.userDisplayName = userDetails.displayName!;
    Userdetails.uniqueName = userDetails.email!.split('@')[0];
    Userdetails.userProfilePic = userDetails.photoURL!;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userDetails.uid)
        .get()
        .then((value) {
      if (value.exists) {
        Map<String, dynamic> userInfoMap = {
          'uid': userDetails.uid,
          "email": userDetails.email,
          "username": userDetails.email!.split('@')[0],
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
        };

        FirebaseFirestore.instance
            .collection("users")
            .doc(userDetails.uid)
            .update(userInfoMap)
            .then((value) {
          NavPushReplacement(context, DashboardUI());
        });
      } else {
        Map<String, dynamic> userInfoMap = {
          'uid': userDetails.uid,
          "email": userDetails.email,
          "username": userDetails.email!.split('@')[0],
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          'tokenId': '',
          'followers': [],
          'following': [],
        };
        databaseMethods
            .addUserInfoToDB(userDetails.uid, userInfoMap)
            .then((value) {
          NavPushReplacement(context, DashboardUI());
        });
      }
    });
  }

  signOut(BuildContext context) async {
    NavPopUntilPush(context, LoginUi());

    await Hive.openBox('userData');
    Hive.box('userData').delete('userMap');

    await auth.signOut().then((value) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(Userdetails.uid)
          .update({'tokenId': ''}).then((value) {});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(Userdetails.uid)
          .update({"active": "0"}).then((value) {});
    });
  }
}
