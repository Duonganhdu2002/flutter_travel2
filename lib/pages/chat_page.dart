// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';
import 'package:flutter_application_1/services/firestore/messages_store.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final List<DocumentReference> friendRefs;
  String groupName;
  final DocumentReference conversationId;

  ChatPage({
    super.key,
    required this.userId,
    required this.friendRefs,
    required this.groupName,
    required this.conversationId,
  });

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
  List<Map<String, String>> friends = [];
  List<Map<String, String>> filteredFriends = [];
  List<Map<String, String>> selectedFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });

    _fetchAvatars();
    _loadFriendList();
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

  Future<void> _loadFriendList() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('auths')
          .doc(widget.userId)
          .get();
      List<dynamic> friendRefs = userSnapshot['list_friend'];
      List<Map<String, String>> friendsList = [];
      for (var friendRef in friendRefs) {
        DocumentSnapshot friendSnapshot =
            await (friendRef as DocumentReference).get();
        friendsList.add({
          'id': friendSnapshot.id,
          'username': friendSnapshot['email'].split('@')[0],
          'avatar': friendSnapshot['avatar'],
        });
      }
      setState(() {
        friends = friendsList
            .where((friend) => !widget.friendRefs
                .any((friendRef) => friendRef.id == friend['id']))
            .toList();
        filteredFriends = friends;
      });
    } catch (e) {
      debugPrint("Failed to load friend list: $e");
    }
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

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Member'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selectedFriends.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selectedFriends.length,
                          itemBuilder: (context, index) {
                            final selectedFriend = selectedFriends[index];

                            return FutureBuilder<String>(
                              future: _getAvatarUrl(selectedFriend['avatar']!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: SizedBox(
                                    width: 70,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: Image.network(
                                            snapshot.data!,
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
                                              borderRadius:
                                                  BorderRadius.circular(40),
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
                                                  selectedFriends
                                                      .removeAt(index);
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
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search friends',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: onSearch,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends[index];
                          final isSelected = selectedFriends.any(
                              (selected) => selected['id'] == friend['id']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 25.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  toggleSelection(friend);
                                });
                              },
                              child: Row(
                                children: [
                                  FutureBuilder<String>(
                                    future: _getAvatarUrl(friend['avatar']!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image.network(
                                          snapshot.data!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _addSelectedFriends();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void toggleSelection(Map<String, String> friend) {
    setState(() {
      if (selectedFriends.any((selected) => selected['id'] == friend['id'])) {
        selectedFriends
            .removeWhere((selected) => selected['id'] == friend['id']);
      } else {
        selectedFriends.add(friend);
      }
    });
  }

  void onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = friends;
      } else {
        filteredFriends = friends
            .where((friend) =>
                friend['username']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addSelectedFriends() async {
    List<DocumentReference> newFriendRefs = selectedFriends
        .map(
            (friend) => FirebaseFirestore.instance.doc('auths/${friend['id']}'))
        .toList();

    await widget.conversationId.update({
      'participants': FieldValue.arrayUnion(newFriendRefs),
    });

    setState(() {
      widget.friendRefs.addAll(newFriendRefs);
      selectedFriends.clear();
    });
  }

  void _showRemoveMemberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Member'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: widget.friendRefs.length,
              itemBuilder: (context, index) {
                final friendRef = widget.friendRefs[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: friendRef.get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final friendData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final friendId = snapshot.data!.id;
                    final friendUsername = friendData['email'].split('@')[0];
                    final friendAvatar = friendData['avatar'];

                    return FutureBuilder<String>(
                      future: _getAvatarUrl(friendAvatar),
                      builder: (context, avatarSnapshot) {
                        if (!avatarSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              avatarSnapshot.data!,
                            ),
                          ),
                          title: Text(friendUsername),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              _removeMember(friendId);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMember(String friendId) async {
    DocumentReference friendRef =
        FirebaseFirestore.instance.collection('auths').doc(friendId);

    await widget.conversationId.update({
      'participants': FieldValue.arrayRemove([friendRef]),
    });

    setState(() {
      widget.friendRefs.remove(friendRef);
    });
  }

  void _showDeleteGroupConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: const Text('Are you sure you want to delete this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete group functionality
                await _deleteGroup();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit the chat page
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGroup() async {
    // Remove the group from participants' list of groups
    for (var friendRef in widget.friendRefs) {
      await friendRef.update({
        'groups': FieldValue.arrayRemove([widget.conversationId])
      });
    }

    // Delete all messages in the conversation
    var messagesSnapshot =
        await widget.conversationId.collection('messages').get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the conversation document
    await widget.conversationId.delete();
  }

  void _showChangeGroupNameDialog() {
    final TextEditingController _groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Group Name'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: 'Enter new group name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = _groupNameController.text;
                if (newName.isNotEmpty) {
                  // Update the group name in Firestore
                  await widget.conversationId.update({'name': newName});
                  setState(() {
                    widget.groupName = newName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _textEditingController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomBar(
        leftWidget: const BackIcon(),
        centerWidget1: Text(
          widget.groupName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        rightWidget: PopupMenuButton<int>(
          icon: const Icon(Icons.settings),
          onSelected: (item) {
            switch (item) {
              case 0:
                _showChangeGroupNameDialog();
                break;
              case 1:
                _showAddMemberDialog();
                break;
              case 2:
                _showRemoveMemberDialog();
                break;
              case 3:
                _showDeleteGroupConfirmation();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<int>(
              value: 0,
              child: Text('Change Group Name'),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text('Add Member'),
            ),
            const PopupMenuItem<int>(
              value: 2,
              child: Text('Remove Member'),
            ),
            const PopupMenuItem<int>(
              value: 3,
              child: Text('Delete Group'),
            ),
          ],
        ),
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
                                    color: const Color(0xFFFFD521),
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
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
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
