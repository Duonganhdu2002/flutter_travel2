import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/components/create_message.dart';
import 'package:flutter_application_1/components/search_input.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class MessageComponent extends StatefulWidget {
  const MessageComponent({super.key});

  @override
  State<MessageComponent> createState() => _MessageComponentState();
}

class _MessageComponentState extends State<MessageComponent> {
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (userId.isNotEmpty) {
      _streamConversations().listen((data) {
        setState(() {
          conversations = data;
          filteredConversations = data;
        });
      });
    } else {
      debugPrint('User not logged in');
    }
  }

  Stream<List<Map<String, dynamic>>> _streamConversations() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: 'auths/$userId')
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> fetchedConversations = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<Map<String, String>> participants = [];
        for (String participantPath in List<String>.from(data['participants'] ?? [])) {
          DocumentSnapshot participantSnapshot =
              await FirebaseFirestore.instance.doc(participantPath).get();
          Map<String, dynamic>? participantData =
              participantSnapshot.data() as Map<String, dynamic>?;

          String avatarUrl = await _getAvatarUrl(participantData?['avatar'] ?? '');

          participants.add({
            '_id': participantSnapshot.id,
            'username': (participantData?['email'] ?? 'unknown').split('@')[0],
            'avatar': avatarUrl,
          });
        }

        QuerySnapshot messageSnapshot = await doc.reference
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        String latestMessageText = 'No messages yet';
        String latestMessageTime = '';
        if (messageSnapshot.docs.isNotEmpty) {
          DocumentSnapshot latestMessageDoc = messageSnapshot.docs.first;
          Map<String, dynamic> messageData =
              latestMessageDoc.data() as Map<String, dynamic>;
          latestMessageText = messageData['text'] ?? 'No message text';
          Timestamp timestamp = messageData['createdAt'] ?? Timestamp.now();
          latestMessageTime = DateFormat('hh:mm').format(timestamp.toDate());
        }

        fetchedConversations.add({
          'participants': participants,
          'latestMessageText': latestMessageText,
          'latestMessageTime': latestMessageTime,
          'name': data['name'] ?? 'Unknown',
          'isGroup': data['isGroup'] ?? false,
          'docRef': doc.reference,
        });
      }
      debugPrint('Fetched Conversations: $fetchedConversations');
      return fetchedConversations;
    });
  }

  Future<String> _getAvatarUrl(String avatarPath) async {
    try {
      if (avatarPath.isNotEmpty) {
        String url = await FirebaseStorage.instance
            .ref('avatars/$avatarPath')
            .getDownloadURL();
        return url;
      }
      return 'assets/images/placeholder_avatar.jpg';
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 'assets/images/placeholder_avatar.jpg';
    }
  }

  void _searchConversations(String query) {
    setState(() {
      filteredConversations = conversations
          .where((conversation) => conversation['participants'].any(
              (participant) =>
                  participant['username']
                      .toLowerCase()
                      .contains(query.toLowerCase()) &&
                  participant['_id'] != userId))
          .toList();
    });
  }

  void _navigateToChat(
    String groupName,
    List<DocumentReference> friendRefs,
    DocumentReference conversationId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          userId: userId,
          friendRefs: friendRefs,
          groupName: groupName,
          conversationId: conversationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Messages",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateMessage()),
                    );
                  },
                  child: ImageFiltered(
                    imageFilter: const ColorFilter.mode(
                        Color(0xFF1B1E28), BlendMode.srcATop),
                    child: SvgPicture.asset(
                      "assets/images/writer.svg",
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SearchInput(onSearch: _searchConversations),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _streamConversations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error loading conversations: ${snapshot.error.toString()}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No conversations found'));
                  }

                  conversations = snapshot.data!;
                  filteredConversations = conversations;

                  return ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final friend = conversation['participants'].firstWhere(
                        (participant) => participant['_id'] != userId,
                        orElse: () => <String, String>{},
                      );

                      if (friend.isEmpty) {
                        return Container();
                      }

                      List<DocumentReference> friendRefs =
                          conversation['participants']
                              .map<DocumentReference>((participant) {
                        return FirebaseFirestore.instance
                            .doc('auths/${participant['_id']}');
                      }).toList();

                      return itemMessage(
                        context,
                        friend['avatar'] ??
                            'assets/images/placeholder_avatar.jpg',
                        conversation['name'],
                        conversation['latestMessageText'],
                        conversation['latestMessageTime'],
                        conversation['docRef'],
                        conversation['isGroup'],
                        friendRefs,
                      );
                    },
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
    String showMessage,
    String timeSend,
    DocumentReference docRef,
    bool isGroupChat,
    List<DocumentReference> friendRefs,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: () {
          _navigateToChat(nameUser, friendRefs, docRef);
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          showMessage,
                          style: const TextStyle(color: Color(0xFF7D848D)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                timeSend,
                style: const TextStyle(
                  color: Color(0xFF7D848D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
