import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final DocumentReference senderId;
  final List<DocumentReference> receivedId;

  Message({
    required this.text,
    required this.senderId,
    required this.receivedId,
  });

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Message(
      text: data['message'],
      senderId: data['senderId'],
      receivedId: List<DocumentReference>.from(data['receivedId']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': text,
      'senderId': senderId,
      'receivedId': receivedId,
      'createdAt': Timestamp.now(),
    };
  }
}
