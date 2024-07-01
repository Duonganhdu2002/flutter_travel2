import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';
import 'package:flutter_application_1/services/firestore/messages_store.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final List<DocumentReference> friendRefs;
  final String groupName;
  final DocumentReference conversationId;

  const ChatPage({
    Key? key,
    required this.userId,
    required this.friendRefs,
    required this.groupName,
    required this.conversationId,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final MessageStore messageStore = MessageStore();
  Map<String, String> userAvatars = {};
  late Stream<List<Message>> _messageStream;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });

    _fetchAvatars();
    _messageStream =
        messageStore.streamMessagesForConversation(widget.conversationId);
  }

  Future<void> _fetchAvatars() async {
    final userRefs = [widget.userId, ...widget.friendRefs.map((ref) => ref.id)];
    final usersSnapshots = await Future.wait(userRefs.map(
        (id) => FirebaseFirestore.instance.collection('auths').doc(id).get()));

    for (var snapshot in usersSnapshots) {
      final avatarPath = snapshot['avatar'] ?? 'default_avatar_path_here';
      final avatarUrl = await _getAvatarUrl(avatarPath);
      userAvatars[snapshot.id] = avatarUrl;
    }

    setState(() {});
  }

  Future<String> _getAvatarUrl(String avatarPath) async {
    try {
      return await FirebaseStorage.instance
          .ref('avatars/$avatarPath')
          .getDownloadURL();
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/avatars%2Fdefault_avatar.png?alt=media&token=21eb4ed4-489a-409c-9dbe-1cfa5b96b1af'; // Default avatar URL
    }
  }

  void _sendMessage() {
    if (_textEditingController.text.isNotEmpty) {
      final message = Message(
        text: _textEditingController.text,
        senderId:
            FirebaseFirestore.instance.collection('auths').doc(widget.userId),
        receivedId: widget.friendRefs,
        createdAt: Timestamp.now(),
        conversationId: widget.conversationId,
      );

      messageStore.addMessage(message);

      _textEditingController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder<List<Message>>(
                stream: _messageStream,
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
                      final avatarUrl = userAvatars[message.senderId.id] ??
                          'https://firebasestorage.googleapis.com/v0/b/travel-app-2f56c.appspot.com/o/avatars%2Fdefault_avatar.png?alt=media&token=21eb4ed4-489a-409c-9dbe-1cfa5b96b1af';

                      bool showAvatar = true;
                      if (index > 0 &&
                          messages[index - 1].senderId.id ==
                              message.senderId.id) {
                        showAvatar = false;
                      }

                      if (message.senderId.id == widget.userId) {
                        return IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(message.text),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (showAvatar)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        CachedNetworkImageProvider(avatarUrl),
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        return IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showAvatar)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        CachedNetworkImageProvider(avatarUrl),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(message.text),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Type your message',
                                hintStyle: TextStyle(
                                  color: Color(0xFF7D848D),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF7D848D),
                              BlendMode.srcATop,
                            ),
                            child: SvgPicture.asset(
                              "assets/images/file.svg",
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD521),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/images/send.svg",
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
