import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserImage extends StatefulWidget {
  final String userId;
  final double width;
  final double height;

  const UserImage({
    super.key,
    required this.userId,
    required this.width,
    required this.height,
  });

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {

  Future<String?> fetchImageUrl() async {
    try {
      String imageName = await getImageNameFromFirestore();
      String url = await FirebaseStorage.instance
          .ref()
          .child("avatars/$imageName")
          .getDownloadURL();
      return url;
    } catch (e) {
      debugPrint("Error fetching image URL: $e");
      return null;
    }
  }

  Future<String> getImageNameFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('auths')  // Sửa thành 'auths'
        .doc(widget.userId)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      String imageName = snapshot['avatar'];
      return imageName;
    } else {
      throw Exception("User does not exist or has no avatar");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData) {
          return ClipOval(
            child: Image.network(
              snapshot.data!,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return const Icon(Icons.account_circle); // Default placeholder
        }
      },
    );
  }
}
