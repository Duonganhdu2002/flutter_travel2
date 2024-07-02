import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/components/create_group.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class MessageComponent extends StatefulWidget {
  const MessageComponent({super.key});

  @override
  State<MessageComponent> createState() => _MessageComponentState();
}

class _MessageComponentState extends State<MessageComponent> {
  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController<List<Map<String, dynamic>>>();
  List<Map<String, dynamic>> conversations = [];
  List<Map<String, dynamic>> filteredConversations = [];
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (userId.isNotEmpty) {
      _streamConversations().listen((data) {
        conversations = data;
        _updateFilteredConversations('');
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
        for (String participantPath
            in List<String>.from(data['participants'] ?? [])) {
          DocumentSnapshot participantSnapshot =
              await FirebaseFirestore.instance.doc(participantPath).get();
          Map<String, dynamic>? participantData =
              participantSnapshot.data() as Map<String, dynamic>?;

          String avatarUrl =
              await _getAvatarUrl(participantData?['avatar'] ?? '');

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
        Timestamp? latestTimestamp;
        if (messageSnapshot.docs.isNotEmpty) {
          DocumentSnapshot latestMessageDoc = messageSnapshot.docs.first;
          Map<String, dynamic> messageData =
              latestMessageDoc.data() as Map<String, dynamic>;
          latestMessageText = messageData['text'] ?? 'No message text';
          Timestamp timestamp = messageData['createdAt'] ?? Timestamp.now();
          latestMessageTime =
              DateFormat('hh:mm').format(timestamp.toDate());
          latestTimestamp = timestamp;
        }

        fetchedConversations.add({
          'participants': participants,
          'latestMessageText': latestMessageText,
          'latestMessageTime': latestMessageTime,
          'latestTimestamp': latestTimestamp,
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
    _updateFilteredConversations(query);
  }

  void _updateFilteredConversations(String query) {
    filteredConversations = conversations
        .where((conversation) =>
            conversation['name'].toLowerCase().contains(query.toLowerCase()) ||
            conversation['participants'].any((participant) =>
                (participant as Map<String, String>)['username']
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ?? false))
        .toList();
    filteredConversations.sort((a, b) {
      Timestamp aTimestamp = a['latestTimestamp'] ?? Timestamp.now();
      Timestamp bTimestamp = b['latestTimestamp'] ?? Timestamp.now();
      return bTimestamp.compareTo(aTimestamp);
    });
    _streamController.add(filteredConversations);
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
  void dispose() {
    _streamController.close();
    super.dispose();
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
                          builder: (context) => const CreateGroup()),
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
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F9),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  ImageFiltered(
                    imageFilter: const ColorFilter.mode(
                      Color(0xFF7D848D),
                      BlendMode.srcATop,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/Search.svg",
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: _searchConversations,
                      decoration: const InputDecoration(
                        hintText: 'Search for chats & messages',
                        hintStyle: TextStyle(
                          color: Color(0xFF7D848D),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: const ColorFilter.mode(
                      Color(0xFF7D848D),
                      BlendMode.srcATop,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/RightArrow.svg",
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _streamController.stream,
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

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final conversation = snapshot.data![index];
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
                        conversation['isGroup']
                            ? conversation['name']
                            : friend['username'],
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
            SizedBox(
              width: 60,
              child: ClipOval(
                child: Image.network(
                  pathImage,
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
                  Text(
                    nameUser,
                    style: const TextStyle(
                        color: Color(0xFF1B1E28),
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    showMessage,
                    style: const TextStyle(color: Color(0xFF7D848D)),
                  ),
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
