import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_application_1/components/call_icon.dart';
import 'package:flutter_application_1/components/receiver_message.dart';
import 'package:flutter_application_1/components/sender_message.dart';
import 'package:flutter_application_1/components/text_input.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatPage extends StatefulWidget {
  final String userId;
  final String friendId;
  final String friendUsername;

  const ChatPage({
    super.key,
    required this.userId,
    required this.friendId,
    required this.friendUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, String>> messages = [];
  late io.Socket socket;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    connectToServer();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  void connectToServer() {
    socket = io.io('http://10.0.2.2:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      debugPrint('connected');
      socket
          .emit('join', {'userId': widget.userId, 'friendId': widget.friendId});
    });

    socket.on('initial_messages', (data) {
      try {
        List<Map<String, String>> fetchedMessages =
            (data as List).map((message) {
          return {
            'type':
                message['senderId'] == widget.userId ? 'sender' : 'receiver',
            'message': message['message'].toString(),
          };
        }).toList();

        setState(() {
          messages.clear();
          messages.addAll(fetchedMessages);
        });

        _scrollToBottom();
      } catch (e) {
        debugPrint('Error parsing initial messages: $e');
      }
    });

    socket.on('receive_message', (data) {
      try {
        setState(() {
          messages.add({
            'type': data['senderId'] == widget.userId ? 'sender' : 'receiver',
            'message': data['message'].toString(),
          });
        });

        _scrollToBottom();
      } catch (e) {
        debugPrint('Error receiving message: $e');
      }
    });

    socket.on('connect_error', (data) {
      debugPrint('Connection Error: $data');
    });

    socket.on('disconnect', (_) {
      debugPrint('Disconnected');
    });
  }

  void sendMessage(String message) {
    final msg = {
      'senderId': widget.userId,
      'receiverId': widget.friendId,
      'message': message,
    };
    socket.emit('send_message', msg);
    setState(() {
      messages.add({'type': 'sender', 'message': message});
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    _scrollController.dispose();
    _focusNode.dispose();
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
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (message["type"] == "sender") {
                    return SenderMessage(message: message["message"]!);
                  } else {
                    return ReceiverMessage(message: message["message"]!);
                  }
                },
              ),
            ),
          ),
          TextInput(
            onSendMessage: sendMessage,
            focusNode: _focusNode,
          ),
        ],
      ),
    );
  }
}
