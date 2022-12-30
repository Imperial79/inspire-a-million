import 'package:blog_app/utilities/utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    final SharedPreferences prefs = await _prefs;

    prefs.setString('USERKEY', userDetails!.uid);
    prefs.setString('USERNAMEKEY', userDetails.email!.split('@')[0]);
    prefs.setString('USERDISPLAYNAMEKEY', userDetails.displayName!);
    prefs.setString('USEREMAILKEY', userDetails.email!);
    prefs.setString('USERPROFILEKEY', userDetails.photoURL!);
    // prefs.setString('TOKENID', tokenId);

    Userdetails.uid = userDetails.uid;
    Userdetails.userEmail = userDetails.email!;
    Userdetails.userDisplayName = userDetails.displayName!;
    Userdetails.userName = userDetails.email!.split('@')[0];
    Userdetails.userProfilePic = userDetails.photoURL!;
    // Userdetails.myTokenId = tokenId;

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

  switchAccount(context) async {
    Userdetails.userEmail = '';

    await FirebaseFirestore.instance
        .collection("users")
        .doc(Userdetails.uid)
        .update({"active": "1"}).then((value) {});

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    // final GoogleSignInAccount? googleSignInAccount =
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
    // prefs.setString('TOKENID', tokenId);

    Userdetails.uid = userDetails.uid;
    Userdetails.userEmail = userDetails.email!;
    Userdetails.userDisplayName = userDetails.displayName!;
    Userdetails.userName = userDetails.email!.split('@')[0];
    Userdetails.userProfilePic = userDetails.photoURL!;
    // Userdetails.myTokenId = tokenId;

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

  signOut() async {
    Userdetails.userEmail = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
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
