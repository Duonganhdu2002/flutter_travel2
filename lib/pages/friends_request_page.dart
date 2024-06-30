import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';

class FriendsRequestPage extends StatefulWidget {
  const FriendsRequestPage({super.key});

  @override
  State<FriendsRequestPage> createState() => _FriendsRequestPageState();
}

class _FriendsRequestPageState extends State<FriendsRequestPage> {
  List<Map<String, String>> friendRequests = [
    {'userId': '1', 'username': 'user1'},
    {'userId': '2', 'username': 'user2'},
    {'userId': '3', 'username': 'user3'},
  ];
  String? currentUserId = '12345';

  @override
  void initState() {
    super.initState();
  }

  void _acceptFriendRequest(String friendId) {
    if (currentUserId == null) return;

    debugPrint('Accepting friend request from $friendId');
    setState(() {
      friendRequests.removeWhere((request) => request['userId'] == friendId);
    });
  }

  void _rejectFriendRequest(String friendId) {
    if (currentUserId == null) return;

    debugPrint('Rejecting friend request from $friendId');
    setState(() {
      friendRequests.removeWhere((request) => request['userId'] == friendId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomBar(
        leftWidget: BackButton(),
        centerWidget1: Text(
          "Friends Request",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: Text("               "),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Friends request",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  return itemMessage(
                    context,
                    "assets/images/User_img.png",
                    friendRequests[index]['userId']!,
                    friendRequests[index]['username']!,
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
    String senderId,
    String username,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Image.asset(
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
                      username,
                      style: const TextStyle(
                          color: Color(0xFF1B1E28),
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _acceptFriendRequest(senderId);
                          },
                          icon: const Icon(Icons.done),
                        ),
                        IconButton(
                          onPressed: () {
                            _rejectFriendRequest(senderId);
                          },
                          icon: const Icon(Icons.do_not_disturb),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
