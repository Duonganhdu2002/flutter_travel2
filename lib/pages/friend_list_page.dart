import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/add_friend_page.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final List<Map<String, String>> friendList = [
    {'userId': '1', 'username': 'user1', 'avatar': 'User_img1.png'},
    {'userId': '2', 'username': 'user2', 'avatar': 'User_img2.png'},
    {'userId': '3', 'username': 'user3', 'avatar': 'User_img3.png'},
  ];
  String? currentUserId = '12345';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Friend List'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: friendList.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: SizedBox(
                      child: friendList[index]['avatar'] != null
                          ? Image.asset(
                              "assets/images/${friendList[index]['avatar']}")
                          : null,
                    ),
                    title: Text(
                      friendList[index]['username']!,
                      style: const TextStyle(
                          color: Color(0xFF1B1E28),
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      // Navigate to UserDetailPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(
                            userId: friendList[index]['userId']!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
