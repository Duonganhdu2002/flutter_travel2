import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final DocumentReference senderId;
  final List<DocumentReference> receivedId;
  final Timestamp createdAt;
  final DocumentReference conversationId;

  Message({
    required this.text,
    required this.senderId,
    required this.receivedId,
    required this.createdAt,
    required this.conversationId,
  });

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message(
      text: data['text'],
      senderId: data['senderId'],
      receivedId: (data['receivedId'] as List)
          .map((path) => FirebaseFirestore.instance.doc(path as String))
          .toList(),
      createdAt: data['createdAt'],
      conversationId: data['conversationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'receivedId': receivedId.map((ref) => ref.path).toList(),
      'createdAt': createdAt,
      'conversationId': conversationId,
    };
  }
}
