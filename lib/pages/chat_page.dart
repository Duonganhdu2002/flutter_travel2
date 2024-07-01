import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/components/call_icon.dart';
import 'package:flutter_application_1/components/receiver_message.dart';
import 'package:flutter_application_1/components/sender_message.dart';
import 'package:flutter_application_1/components/text_input.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';
import 'package:flutter_application_1/services/firestore/messages_store.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String friendId;
  final String friendUsername;
  final bool isGroupChat;
  final List<Map<String, String>> participants;

  const ChatPage({
    super.key,
    required this.userId,
    required this.friendId,
    required this.friendUsername,
    this.isGroupChat = false,
    this.participants = const [],
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  final MessageStore _messageStore = MessageStore();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;
    final message = Message(
      text: messageText,
      senderId: FirebaseFirestore.instance.doc('auths/${widget.userId}'),
      receivedId: widget.participants
          .map((p) => FirebaseFirestore.instance.doc('auths/${p['userId']}'))
          .toList(),
    );
    await _messageStore.addMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  String getAvatar(String userId) {
    final participant = widget.participants.firstWhere(
        (participant) => participant['userId'] == userId,
        orElse: () => {});
    return participant['avatar'] ?? 'default_avatar.png';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: Text(widget.friendUsername,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerWidget2: const Text("Active now",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        rightWidget: const CallIcon(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('receivedId',
                        arrayContains: FirebaseFirestore.instance
                            .doc('auths/${widget.userId}'))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading messages'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages found'));
                  }

                  final messages = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final senderId = (data['senderId'] as DocumentReference).id;
                    return {
                      'type': senderId == widget.userId ? 'sender' : 'receiver',
                      'message': data['message'],
                      'avatar': getAvatar(senderId),
                    };
                  }).toList();

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      if (message["type"] == "sender") {
                        return SenderMessage(
                          message: message["message"],
                          avatar: message['avatar'],
                        );
                      } else {
                        return ReceiverMessage(
                          message: message["message"],
                          avatar: message['avatar'],
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          TextInput(
            onSendMessage: sendMessage,
            controller: _messageController,
            focusNode: _focusNode,
          ),
        ],
      ),
    );
  }
}
