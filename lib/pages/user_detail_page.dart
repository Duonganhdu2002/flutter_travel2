import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({required this.userId, super.key});

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool? areFriends = false;
  bool isRequestPending = false;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? userDetail;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserDetail();
  }

  Future<void> _fetchUserDetail() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('auths')
        .doc(widget.userId)
        .get();
    setState(() {
      userDetail = userSnapshot;
      areFriends = (userSnapshot['list_friend'] as List)
          .map((e) => (e is DocumentReference ? e.id : e))
          .contains(currentUserId);
      isRequestPending = (userSnapshot['invite_list'] as List)
          .map((e) => (e is DocumentReference ? e.id : e))
          .contains(currentUserId);
    });

    _fetchAvatar(userSnapshot['avatar']);
  }

  Future<void> _fetchAvatar(String avatarPath) async {
    try {
      String url = await FirebaseStorage.instance
          .ref('avatars/$avatarPath')
          .getDownloadURL();
      setState(() {
        avatarUrl = url;
      });
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
    }
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    if (currentUserId.isEmpty) return;
    setState(() {
      isRequestPending = true;
    });

    try {
      final receiverSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(receiverId)
          .get();
      final receiverData = receiverSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> inviteList =
          List<DocumentReference>.from(receiverData['invite_list'] ?? []);
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('auths').doc(currentUserId);

      if (!inviteList.contains(currentUserRef)) {
        inviteList.add(currentUserRef);
        await FirebaseFirestore.instance
            .collection('auths')
            .doc(receiverId)
            .update({
          'invite_list': inviteList,
        });
        debugPrint('Friend request sent from $currentUserId to $receiverId');
      }
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      setState(() {
        isRequestPending = false;
      });
    }
  }

  Future<void> _unfriend(String friendId) async {
    if (currentUserId.isEmpty) return;

    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> currentUserFriends =
          List<DocumentReference>.from(currentUserData['list_friend'] ?? []);
      DocumentReference friendRef =
          FirebaseFirestore.instance.collection('auths').doc(friendId);

      currentUserFriends.remove(friendRef);

      await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .update({
        'list_friend': currentUserFriends,
      });

      final friendSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(friendId)
          .get();
      final friendData = friendSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendUserFriends =
          List<DocumentReference>.from(friendData['list_friend'] ?? []);
      DocumentReference currentUserRef =
          FirebaseFirestore.instance.collection('auths').doc(currentUserId);

      friendUserFriends.remove(currentUserRef);

      await FirebaseFirestore.instance
          .collection('auths')
          .doc(friendId)
          .update({
        'list_friend': friendUserFriends,
      });

      setState(() {
        areFriends = false;
      });

      debugPrint('Unfriended $friendId');
    } catch (e) {
      debugPrint('Error unfriending: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userDetail == null) {
      return const Scaffold(
        appBar: CustomBar(
          leftWidget: BackIcon(),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final userData = userDetail!.data() as Map<String, dynamic>;
    final String username = userData['email'].split('@')[0];

    return Scaffold(
      appBar: const CustomBar(
        leftWidget: BackIcon(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            if (avatarUrl != null)
              ClipOval(
                child: Image.network(
                  avatarUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            else
              const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                username,
                style: const TextStyle(
                  color: Color(0xFF1B1E28),
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle button press
                        },
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Color(0xFF7D848D), BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/Caht.svg",
                            width: 20,
                            height: 30,
                          ),
                        ),
                        label: const Text(
                          'Message',
                          style: TextStyle(
                            color: Color(0xFF7D848D),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (areFriends == false && !isRequestPending)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/add-friend.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed: () {
                          _sendFriendRequest(widget.userId);
                        },
                      ),
                    ),
                  if (isRequestPending)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/pending-request.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed:
                            null, // Disable button when request is pending
                      ),
                    ),
                  if (areFriends == true)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/remove-friend.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed: () {
                          _unfriend(widget.userId);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
