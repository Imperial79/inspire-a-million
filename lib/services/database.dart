import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'globalVariable.dart';

class DatabaseMethods {
  //Adding user to database QUERY
  addUserInfoToDB(String uid, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userInfoMap);
  }

  uploadComments(String blogId, commentMap) async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add(commentMap)
        .then((value) => updateCommentCount(blogId));
  }

  updateCommentCount(String blogId) async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .update({'comments': FieldValue.increment(1)});
  }

  getFollowersAndFollowing(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();
  }

  getBlogs(List uidList) async {
    return await FirebaseFirestore.instance
        .collection('blogs')
        .where('uid', whereIn: uidList)
        .orderBy('time', descending: true)
        .snapshots();
  }

  deletePostDetails(String blogId) async {
    FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .limit(1)
        .get()
        .then((value) async {
      if (value.docs.isEmpty) {
        print('no collection');
        deletePost(blogId);
      } else {
        await FirebaseFirestore.instance
            .collection('blogs')
            .doc(blogId)
            .collection('comments')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
            deletePost(blogId);
          }
        });
      }
    });
  }

  Future<void> deletePost(String blogId) async {
    try {
      await FirebaseFirestore.instance.collection('blogs').doc(blogId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  uploadBlogs(blogMap, String blogId) {
    FirebaseFirestore.instance.collection('blogs').doc(blogId).set(blogMap);
  }

  Future<void> likeBlog(String blogId, List likes) async {
    try {
      if (likes.contains(Userdetails.uid)) {
        await FirebaseFirestore.instance
            .collection('blogs')
            .doc(blogId)
            .update({
          'likes': FieldValue.arrayRemove([Userdetails.uid]),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('blogs')
            .doc(blogId)
            .update({
          'likes': FieldValue.arrayUnion([Userdetails.uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getUsersIAmFollowing() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  getlabel() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.userName)
        .collection('labelList')
        .get();
  }

  updatelabel(List labelList) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.userName)
        .collection('labelList')
        .doc('list')
        .set({'labelList': labelList});
  }

  fetchLabel() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.userName)
        .collection('labelList')
        .snapshots();
  }

  updateNote(String time, Map<String, dynamic> updatedNoteMap) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(Userdetails.userName)
        .collection('notes')
        .doc(time)
        .update(updatedNoteMap);
  }

  //Delete all transacts
  // deleteAllTransacts(String username) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(username)
  //       .collection('transacts')
  //       .get()
  //       .then((snapshot) {
  //     for (DocumentSnapshot ds in snapshot.docs) {
  //       ds.reference.delete();
  //     }
  //   });
  // }

  //Delete all transacts
  deleteNote(String username, String time, String labelName) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .collection('notes')
        .where('time', isEqualTo: time)
        .limit(1)
        .get()
        .then(
      (snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      },
    );
  }
}
