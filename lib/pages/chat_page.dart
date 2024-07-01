import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<DocumentReference> friendRefs;
  final String groupName;
  final DocumentReference conversationId; // Added conversationId

  const ChatPage({
    super.key,
    required this.userId,
    required this.friendRefs,
    required this.groupName,
    required this.conversationId, // Added conversationId
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final MessageStore messageStore = MessageStore();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void sendMessage(String messageText) {
    final message = Message(
      text: messageText,
      senderId:
          FirebaseFirestore.instance.collection('auths').doc(widget.userId),
      receivedId: widget.friendRefs,
      createdAt: Timestamp.now(),
      conversationId: widget.conversationId, // Assign the conversation ID
    );

    messageStore.addMessage(message);

    _textEditingController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: Text(widget.groupName,
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
              child: StreamBuilder<List<Message>>(
                stream: messageStore
                    .streamMessagesForConversation(widget.conversationId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      if (message.senderId.id == widget.userId) {
                        return SenderMessage(
                          message: message.text,
                          avatar:
                              'your_avatar_path_here', // Replace with actual avatar path
                        );
                      } else {
                        return ReceiverMessage(
                          message: message.text,
                          avatar:
                              'default_avatar_path_here', // Replace with actual avatar path
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
            controller: _textEditingController,
            focusNode: _focusNode,
          ),
        ],
      ),
    );
  }
}
