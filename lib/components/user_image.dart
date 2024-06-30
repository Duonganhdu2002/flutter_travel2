// ignore_for_file: assetsrary_private_types_in_public_api

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
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchImageUrl();
  }

  Future<void> fetchImageUrl() async {
    String imageName = await getImageNameFromFirestore();
    String url = await FirebaseStorage.instance
        .ref()
        .child("avatars/$imageName")
        .getDownloadURL();
    setState(() {
      imageUrl = url;
    });
  }

  Future<String> getImageNameFromFirestore() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('auths')
        .doc(widget.userId)
        .get();
    String imageName = snapshot['avatar'];
    return imageName;
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl == null
          ? const CircularProgressIndicator()
          : Image.network(
              imageUrl!,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
    );
  }
}
