import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/components/create_group.dart';
import 'package:flutter_application_1/components/search_input.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateMessage extends StatefulWidget {
  const CreateMessage({super.key});

  @override
  State<CreateMessage> createState() => _CreateMessageState();
}

class _CreateMessageState extends State<CreateMessage> {
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(currentUserId)
          .get();
      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;

      List<DocumentReference> friendRefs =
          List<DocumentReference>.from(currentUserData['list_friend'] ?? []);

      List<Map<String, String>> friendsList = [];
      for (DocumentReference friendRef in friendRefs) {
        final friendSnapshot = await friendRef.get();
        final friendData = friendSnapshot.data() as Map<String, dynamic>;

        String avatarPath = friendData['avatar'] ?? 'default_avatar.png';
        String avatarUrl = await _getAvatarUrl(avatarPath);

        friendsList.add({
          'userId': friendRef.id,
          'username': friendData['email'].split('@')[0],
          'avatar': avatarUrl
        });
      }

      setState(() {
        friends = friendsList;
        filteredFriends = friendsList;
      });
    } catch (e) {
      debugPrint('Error fetching friends: $e');
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

  void _handleSearch(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) =>
              friend['username']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _navigateToChat(String userId, String username, String avatar, bool isGroupChat) {
    // Navigate to chat page with the selected user
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userId: currentUserId,
          friendId: userId,
          friendUsername: username,
          isGroupChat: isGroupChat,
          participants: isGroupChat ? friends : [{'userId': userId, 'username': username, 'avatar': avatar}], // Add friends for group chat or the friend for one-on-one chat
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomBar(
        leftWidget: BackIcon(),
        centerWidget1: Text(
          "New Messages",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        rightWidget: Text("           "),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchInput(
              hintText: 'Search friends',
              onSearch: _handleSearch,
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateGroup()),
                );
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Stack(
                      children: [
                        IconButton(
                          icon: ImageFiltered(
                            imageFilter: const ColorFilter.mode(
                                Colors.black12, BlendMode.srcATop),
                            child: SvgPicture.asset(
                              "assets/images/UserGroup.svg",
                              width: 24,
                              height: 24,
                            ),
                          ),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              // Trang hiện tại là trang gốc, không thực hiện pop
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Create a group chat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 200),
                  SvgPicture.asset(
                    "assets/images/RightArrow.svg",
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Suggested",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return itemMessage(
                    context,
                    friend['avatar']!,
                    friend['username']!,
                    friend['userId']!,
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
    String pathImage,
    String nameUser,
    String userId,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: () {
          _navigateToChat(userId, nameUser, pathImage, false);
        },
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Image.network(
                      pathImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
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
                              nameUser,
                              style: const TextStyle(
                                  color: Color(0xFF1B1E28),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const ImageFiltered(
                              imageFilter: ColorFilter.mode(
                                Color(0xFF7D848D),
                                BlendMode.srcATop,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget itemGroupMessage(
    BuildContext context,
    String userImage,
    String friendImage,
    String groupName,
    String membersName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: () {
          // Implement navigation to group chat here
        },
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(children: [
                      Positioned(
                        child: SizedBox(
                          width: 55,
                          child: Image.network(
                            userImage,
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: SizedBox(
                          width: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white70),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Image.network(
                              friendImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ]),
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
                              groupName,
                              style: const TextStyle(
                                  color: Color(0xFF1B1E28),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                            const ImageFiltered(
                              imageFilter: ColorFilter.mode(
                                Color(0xFF7D848D),
                                BlendMode.srcATop,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          membersName,
                          style: const TextStyle(color: Color(0xFF7D848D)),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/images/RightArrow.svg",
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
