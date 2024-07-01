import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SenderMessage extends StatelessWidget {
  final String message;
  final String avatar;

  const SenderMessage({
    super.key,
    required this.message,
    required this.avatar,
  });

  Future<String> _getAvatarUrl(String avatarPath) async {
    try {
      String url = await FirebaseStorage.instance
          .ref('avatars/$avatarPath')
          .getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
      return 'https://example.com/default_avatar.png'; // Default avatar URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getAvatarUrl(avatar),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const CircleAvatar(
            backgroundImage:
                NetworkImage('https://example.com/default_avatar.png'),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD521),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!),
              ),
            ],
          ),
        );
      },
    );
  }
}
