import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypt/crypt.dart';
import 'package:flutter/material.dart';

class AuthStore {
  // get collectuion of Notess
  final CollectionReference auths =
      FirebaseFirestore.instance.collection("auths");

  // CREATE: add a new user
  Future<void> addUser({
    required String uid,
    required String email,
    required String password,
    List<dynamic>? bookMarkList = const [],
    List<dynamic>? inviteList = const [],
    List<dynamic>? listFriend = const [],
    List<dynamic>? waitingList = const [],
    String? avatar = 'default_avatar.png',
    String? fullname = '',
    String? location = '',
    String? phone = '',
    List<dynamic>? planList = const [],
  }) {
    // Hash the password before saving it
    String hashedPassword = Crypt.sha256(password).toString();

    return auths.doc(uid).set({
      'uid': uid,
      'email': email,
      'password': hashedPassword,
      'book_mark_list': bookMarkList ?? [],
      'invite_list': inviteList ?? [],
      'list_friend': listFriend ?? [],
      'waiting_list': waitingList ?? [],
      'avatar': avatar ?? 'default_avatar.png',
      'fullname': fullname ?? '',
      'location': location ?? '',
      'phone': phone ?? '',
      'plan_list': planList ?? [],
      'timestamp': Timestamp.now(),
    });
  }

  // Function to get user information by userId (excluding password)
  Stream<Map<String, dynamic>?> getUserById(String userId) {
    try {
      return auths.doc(userId).snapshots().map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic>? userData =
              snapshot.data() as Map<String, dynamic>?;
          if (userData != null) {
            // Remove password from user data
            userData.remove('password');
            return userData;
          }
        }
        return null; // Return null if user not found or snapshot doesn't exist
      });
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return Stream.value(null); // Return a null stream on error
    }
  }

  //UPDATE:
  Future<void> updateUser(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await auths.doc(userId).update(updatedData);
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  //READ:
  Future<void> deteleNote(String docID) {
    return auths.doc(docID).delete();
  }
}
