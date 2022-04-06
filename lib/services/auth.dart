import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homeUi.dart';
import 'database.dart';
import 'globalVariable.dart';

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

    print('Display name : ' + Userdetails.userDisplayName);

    Userdetails.uid = userDetails.uid;
    Userdetails.userEmail = userDetails.email!;
    Userdetails.userDisplayName = userDetails.displayName!;
    Userdetails.userName = userDetails.email!.split('@')[0];
    Userdetails.userProfilePic = userDetails.photoURL!;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userDetails.uid)
        .get()
        .then((value) {
      if (value.exists) {
        print('does exist -------------');
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
          PageRouteTransition.pushReplacement(context, HomeUi());
        });
      } else {
        print('does not exist --------- ');

        Map<String, dynamic> userInfoMap = {
          'uid': userDetails.uid,
          "email": userDetails.email,
          "username": userDetails.email!.split('@')[0],
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          'followers': [],
          'following': [],
        };
        databaseMethods
            .addUserInfoToDB(userDetails.uid, userInfoMap)
            .then((value) {
          PageRouteTransition.pushReplacement(context, HomeUi());
        });
      }
    });
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}
