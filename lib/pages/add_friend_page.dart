import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_bar.dart';
import 'package:flutter_application_1/models/structure/auth_model.dart';
import 'package:flutter_application_1/pages/user_detail_page.dart';
import 'package:flutter_application_1/services/firestore/auths_store.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final AuthStore _authStore = AuthStore();
  List<Auth> allUsers = [];
  List<Auth> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _authStore.getAllUsers().listen((users) {
      setState(() {
        allUsers = users.where((user) => user.uid != currentUserId).toList();
        filteredUsers = allUsers;
      });
    });
    searchController.addListener(() {
      filterUsers();
    });
  }

  void filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers
          .where((user) => user.email.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<String> _getAvatarUrl(String userId) async {
    try {
      String avatarPath = 'avatars/$userId.png'; // Assumed path based on userId
      String url =
          await FirebaseStorage.instance.ref(avatarPath).getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error fetching avatar for $userId: $e');
      // Returning URL for the default avatar image stored in Firebase Storage
      return await FirebaseStorage.instance
          .ref('avatars/default_avatar.png')
          .getDownloadURL();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBar(
        leftWidget: BackButton(),
        centerWidget1: Text(
          "Add friend",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        rightWidget: Text("               "),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search friends name',
                              hintStyle: TextStyle(
                                color: Color(0xFF7D848D),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  Auth user = filteredUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailPage(userId: user.uid),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          FutureBuilder<String>(
                            future: _getAvatarUrl(user.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Icon(Icons.error);
                              } else {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    snapshot.data!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.email.split('@')[0],
                                  style: const TextStyle(
                                    color: Color(0xFF1B1E28),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
