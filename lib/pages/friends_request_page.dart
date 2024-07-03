import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';

class FriendsRequestPage extends StatefulWidget {
  const FriendsRequestPage({super.key});

  @override
  State<FriendsRequestPage> createState() => _FriendsRequestPageState();
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  List<Map<String, String>> friendRequests = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendRequestRefs = List<DocumentReference>.from(currentUserData['invite_list'] ?? []);

      List<Map<String, String>> requests = [];
      for (DocumentReference requestRef in friendRequestRefs) {
        final requestSnapshot = await requestRef.get();
        final requestData = requestSnapshot.data() as Map<String, dynamic>;

        String avatarPath = requestData['avatar'] ?? 'default_avatar.png';
        String avatarUrl = await _getAvatarUrl(avatarPath);

        requests.add({
          'userId': requestRef.id,
          'username': requestData['email'].split('@')[0],
          'avatar': avatarUrl
        });
      }

      if (mounted) {
        setState(() {
          friendRequests = requests;
        });
      }
    } catch (e) {
      debugPrint('Error fetching friend requests: $e');
    }
  }

  Future<String> _getAvatarUrl(String avatarPath) async {
    try {
      String url = await FirebaseStorage.instance
          .ref('avatars/$avatarPath')
          .getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 'https://example.com/default_avatar.png'; // Provide a default image URL if needed
    }
  }

  Future<void> _acceptFriendRequest(String friendId) async {
    if (currentUserId.isEmpty) return;

    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> currentUserFriends = List<DocumentReference>.from(currentUserData['list_friend'] ?? []);
      List<DocumentReference> currentUserInvites = List<DocumentReference>.from(currentUserData['invite_list'] ?? []);
      DocumentReference friendRef = FirebaseFirestore.instance.collection('auths').doc(friendId);

      currentUserFriends.add(friendRef);
      currentUserInvites.remove(friendRef);

      await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .update({
        'list_friend': currentUserFriends,
        'invite_list': currentUserInvites,
      });

      final friendSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(friendId)
          .get();
      final friendData = friendSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendUserFriends = List<DocumentReference>.from(friendData['list_friend'] ?? []);
      friendUserFriends.add(FirebaseFirestore.instance.collection('auths').doc(currentUserId));

      await FirebaseFirestore.instance
          .collection('auths')
          .doc(friendId)
          .update({
        'list_friend': friendUserFriends,
      });

      if (mounted) {
        setState(() {
          friendRequests.removeWhere((request) => request['userId'] == friendId);
        });
      }

      debugPrint('Accepted friend request from $friendId');
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
    }
  }

  Future<void> _rejectFriendRequest(String friendId) async {
    if (currentUserId.isEmpty) return;

    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> currentUserInvites = List<DocumentReference>.from(currentUserData['invite_list'] ?? []);
      DocumentReference friendRef = FirebaseFirestore.instance.collection('auths').doc(friendId);
      currentUserInvites.remove(friendRef);

      await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .update({
        'invite_list': currentUserInvites,
      });

      if (mounted) {
        setState(() {
          friendRequests.removeWhere((request) => request['userId'] == friendId);
        });
      }

      debugPrint('Rejected friend request from $friendId');
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomBar(
        leftWidget: BackButton(),
        centerWidget1: Text(
          "Friends Request",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: Text("               "),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Friends request",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  return itemMessage(
                    context,
                    friendRequests[index]['avatar']!,
                    friendRequests[index]['userId']!,
                    friendRequests[index]['username']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemMessage(
    BuildContext context,
    String avatarUrl,
    String senderId,
    String username,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                          color: Color(0xFF1B1E28),
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _acceptFriendRequest(senderId);
                          },
                          icon: const Icon(Icons.done),
                        ),
                        IconButton(
                          onPressed: () {
                            _rejectFriendRequest(senderId);
                          },
                          icon: const Icon(Icons.do_not_disturb),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
