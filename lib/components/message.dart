import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/create_message.dart';
import 'package:flutter_application_1/components/search_input.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  }

  Stream<List<Map<String, dynamic>>> _streamConversations() {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('participants',
            arrayContains: FirebaseFirestore.instance.doc('auths/$userId'))
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> fetchedConversations = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Fetch participant details
        List<Map<String, dynamic>> participants = [];
        for (DocumentReference participantRef in data['participants']) {
          DocumentSnapshot participantSnapshot = await participantRef.get();
          Map<String, dynamic> participantData =
              participantSnapshot.data() as Map<String, dynamic>;

          // Fetch the avatar URL from Firebase Storage
          String avatarUrl = await _getAvatarUrl(participantData['avatar']);

          participants.add({
            '_id': participantSnapshot.id,
            'username': participantData['email'].split('@')[0],
            'avatar': avatarUrl,
          });
        }

        // Fetch messages details
        DocumentSnapshot messageSnapshot = await data['messages'].get();
        List<Map<String, dynamic>> messages = [];
        if (messageSnapshot.exists) {
          Map<String, dynamic> messageData =
              messageSnapshot.data() as Map<String, dynamic>;
          messages.add({
            'message': messageData['message'],
            'createdAt': messageData['createdAt']
          });
        }

        fetchedConversations.add({
          'participants': participants,
          'messages': messages,
          'name': data['name'], // Add this line to include the name field
        });
      }
      return fetchedConversations;
    });
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
                    return const Center(
                        child: Text('Error loading conversations'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No conversations found'));
                  }

                  conversations = snapshot.data!;
                  filteredConversations =
                      conversations; // Ensure the filter is updated

                  return ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final latestMessage = conversation['messages'].isNotEmpty
                          ? conversation['messages'][0]['message']
                          : 'No messages yet';
                      final friend = conversation['participants'].firstWhere(
                        (participant) => participant['_id'] != userId,
                        orElse: () => <String,
                            dynamic>{}, // Return an empty map with the correct type
                      );

                      if (friend.isEmpty) {
                        return Container(); // or handle the empty case as needed
                      }

                      return itemMessage(
                        context,
                        friend['avatar'] ??
                            'assets/images/placeholder_avatar.jpg',
                        conversation['name'], // Use conversation name here
                        latestMessage,
                        1, // Replace with actual status if available
                        '07:76', // Replace with actual time if available
                        friend['_id'],
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
    int statusMessage,
    String timeSend,
    String friendId,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                userId: userId, // Use the actual user ID
              ),
            ),
          );
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
                            ImageFiltered(
                              imageFilter: const ColorFilter.mode(
                                Color(0xFF7D848D),
                                BlendMode.srcATop,
                              ),
                              child: SvgPicture.asset(
                                statusMessage == 1
                                    ? "assets/images/sent.svg"
                                    : statusMessage == 2
                                        ? "assets/images/received.svg"
                                        : "assets/images/seen.svg",
                                width: 14,
                                height: 14,
                              ),
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
