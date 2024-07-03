import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/user_detail_page.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  List<Map<String, String>> friendList = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriendList();
  }

  Future<void> _fetchFriendList() async {
    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendRefs =
          List<DocumentReference>.from(currentUserData['list_friend'] ?? []);

      List<Map<String, String>> friends = [];
      for (DocumentReference friendRef in friendRefs) {
        final friendSnapshot = await friendRef.get();
        final friendData = friendSnapshot.data() as Map<String, dynamic>;

        String avatarPath = friendData['avatar'] ?? 'default_avatar.png';
        String avatarUrl = await _getAvatarUrl(avatarPath);

        friends.add({
          'userId': friendRef.id,
          'username': friendData['email'].split('@')[0],
          'avatar': avatarUrl
        });
      }

      setState(() {
        friendList = friends;
      });
    } catch (e) {
      debugPrint('Error fetching friend list: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Friend List'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: friendList.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: SizedBox(
                      width: 50, // Chiều rộng của ảnh
                      height: 50, // Chiều cao của ảnh
                      child: friendList[index]['avatar'] != null
                          ? ClipOval(
                              child: Image.network(
                                friendList[index]['avatar']!,
                                fit: BoxFit.cover,
                                width: 80, // Chiều rộng của ảnh
                                height: 80, // Chiều cao của ảnh
                              ),
                            )
                          : ClipOval(
                              child: Container(
                                color: Colors
                                    .grey, // Màu nền mặc định nếu không có ảnh
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons
                                      .person, // Biểu tượng mặc định nếu không có ảnh
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                    ),
                    title: Text(
                      friendList[index]['username']!,
                      style: const TextStyle(
                          color: Color(0xFF1B1E28),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      // Navigate to UserDetailPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(
                            userId: friendList[index]['userId']!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
