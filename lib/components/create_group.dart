// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/models/structure/conversation_model.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/services/firestore/conversations_store.dart';
import 'package:flutter_application_1/services/firestore/messages_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  List<String> selectedFriends = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final ConversationStore _conversationStore = ConversationStore();
  final MessageStore _messageStore = MessageStore();

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
      return 'assets/images/placeholder_avatar.jpg'; // Provide a default image URL if needed
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

  void toggleSelection(String friendId) {
    setState(() {
      if (selectedFriends.contains(friendId)) {
        selectedFriends.remove(friendId);
      } else {
        selectedFriends.add(friendId);
      }
    });
  }

  Future<void> _createGroup() async {
    if (selectedFriends.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 friends to create a group'),
        ),
      );
      return;
    }

    try {
      // Add the current user to the selected friends list if not already present
      if (!selectedFriends.contains(currentUserId)) {
        selectedFriends.add(currentUserId);
      }

      // Create the conversation with a default name and group details
      final conversation = Conversation(
        participants: selectedFriends
            .map((userId) => FirebaseFirestore.instance.doc('auths/$userId'))
            .toList(),
        name: 'New Group', // Set a default name for the group
        isGroup: true, // Indicate that this is a group conversation
        groupOwner: FirebaseFirestore.instance.doc(
            'auths/$currentUserId'), // Set the current user as the group owner
      );

      DocumentReference conversationRef =
          await _conversationStore.addConversation(conversation);

      // Create a message in the messages collection
      final message = Message(
        text: 'Group has been created.',
        senderId: FirebaseFirestore.instance.doc('auths/$currentUserId'),
        receivedId: selectedFriends
            .map((userId) => FirebaseFirestore.instance.doc('auths/$userId'))
            .toList(),
        createdAt: Timestamp.now(),
        conversationId: conversationRef, // Assign the conversation ID
      );

      await _messageStore.addMessage(message);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully')),
      );

      // Navigate to the chat page for the new group
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            userId: currentUserId,
            friendRefs: conversation.participants,
            groupName: conversation.name,
            conversationId: conversationRef,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
      debugPrint('Error creating group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomBar(
        leftWidget: BackIcon(),
        centerWidget1: Text(
          "New Group",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        rightWidget: Text("           "),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: InkWell(
          onTap: _createGroup,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFD521), // Background color
              borderRadius: BorderRadius.circular(12), // BorderRadius
            ),
            height: 55,
            width: double.infinity,
            child: const Center(
              child: Text(
                'Create Group',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            if (selectedFriends.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFriends.length,
                  itemBuilder: (context, index) {
                    final selectedFriendId = selectedFriends[index];
                    final friend = friends.firstWhere(
                        (friend) => friend['userId'] == selectedFriendId);

                    return Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: SizedBox(
                        width: 70,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                friend['avatar']!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: SvgPicture.asset(
                                    "assets/images/delete.svg",
                                    width: 16,
                                    height: 16,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedFriends.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                  final isSelected = selectedFriends.contains(friend['userId']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: InkWell(
                      onTap: () => toggleSelection(friend['userId']!),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              friend['avatar']!,
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
                                Text(
                                  friend['username']!,
                                  style: const TextStyle(
                                    color: Color(0xFF1B1E28),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey,
                                width: 2,
                              ),
                              color: isSelected
                                  ? const Color(0xFFFFD521)
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
