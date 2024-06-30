import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/components/back_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserDetailPage extends StatefulWidget {
  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool? areFriends = false;
  bool isRequestPending = false;
  String currentUserId = "12345";
  String currentUsername = "current_user";

  final userDetail = {
    'id': '67890',
    'username': 'static_user',
    'image': 'assets/images/image1.png'
  };

  @override
  void initState() {
    super.initState();
  }

  void _sendFriendRequest(String receiverId) {
    if (currentUserId.isEmpty || currentUsername.isEmpty) return;
    setState(() {
      isRequestPending = true;
    });

    try {
      debugPrint('Sending friend request from $currentUserId to $receiverId');
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      setState(() {
        isRequestPending = false;
      });
    }
  }

  void _unfriend(String friendId) {
    if (currentUserId.isEmpty) return;

    try {
      debugPrint('Unfriending $friendId');
      setState(() {
        areFriends = false;
      });
    } catch (e) {
      debugPrint('Error unfriending: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBar(
        leftWidget: BackIcon(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                userDetail['image']!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                userDetail['username'] ?? "No username",
                style: const TextStyle(
                  color: Color(0xFF1B1E28),
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
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
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle button press
                        },
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Color(0xFF7D848D), BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/Caht.svg",
                            width: 20,
                            height: 30,
                          ),
                        ),
                        label: const Text(
                          'Message',
                          style: TextStyle(
                            color: Color(0xFF7D848D),
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  if (areFriends == false && !isRequestPending)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/add-friend.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed: () {
                          _sendFriendRequest(userDetail['id']!);
                        },
                      ),
                    ),
                  if (isRequestPending)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/pending-request.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed:
                            null, // Disable button when request is pending
                      ),
                    ),
                  if (areFriends == true)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD521),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: IconButton(
                        icon: ImageFiltered(
                          imageFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcATop),
                          child: SvgPicture.asset(
                            "assets/images/remove-friend.svg",
                            width: 24,
                            height: 24,
                          ),
                        ),
                        onPressed: () {
                          _unfriend(userDetail['id']!);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
