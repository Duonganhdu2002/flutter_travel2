import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/auth_model.dart';

class AuthStore {
  final CollectionReference auths =
      FirebaseFirestore.instance.collection("auths");

  Stream<List<Auth>> getAllUsers() {
    return auths.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Auth.fromSnapshot(doc)).toList();
    });
  }

  Future<void> addUser(String uid, String email, String password) async {
    final auth = Auth(
        uid: uid,
        email: email,
        password: password,
        avatar: 'default_avatar.png');
    final Map<String, dynamic> userData = auth.toMap();
    await auths.doc(uid).set(userData);
  }

  Stream<Auth?> getUserById(String uid) {
    return auths.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Auth.fromSnapshot(snapshot);
      } else {
        debugPrint('User not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming user: $error');
      return null;
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updatedData) async {
    try {
      await auths.doc(uid).update(updatedData);
      debugPrint('User updated successfully');
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await auths.doc(uid).delete();
      debugPrint('User deleted successfully');
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
  }

  Future<bool> toggleBookmark(String uid, String placeId) async {
    try {
      DocumentReference userDoc = auths.doc(uid);
      DocumentSnapshot userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        List<dynamic> bookmarks = userSnapshot.get('book_mark_list') ?? [];
        DocumentReference placeRef =
            FirebaseFirestore.instance.collection('places').doc(placeId);
        bool isBookmarked = bookmarks.contains(placeRef);
        if (isBookmarked) {
          bookmarks.remove(placeRef);
        } else {
          bookmarks.add(placeRef);
        }
        await userDoc.update({'book_mark_list': bookmarks});
        debugPrint('Bookmark list updated');
        return !isBookmarked;
      } else {
        debugPrint('User not found');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating bookmark list: $e');
      return false;
    }
  }

  Stream<List<DocumentReference>> getUserBookmarks(String uid) {
    return auths.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return (snapshot.get('book_mark_list') as List<dynamic>)
            .cast<DocumentReference>();
      } else {
        return [];
      }
    });
  }
}
