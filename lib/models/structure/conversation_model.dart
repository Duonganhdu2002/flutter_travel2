import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final List<DocumentReference> participants;
  final String name;
  
  final bool isGroup;
  final DocumentReference? groupOwner;

  Conversation({
    required this.participants,
    required this.name,
    required this.isGroup,
    this.groupOwner,
  });

  factory Conversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Conversation(
      participants: List<DocumentReference>.from(data['participants']),
      name: data['name'],
      isGroup: data['isGroup'],
      groupOwner: data['groupOwner'] != null
          ? FirebaseFirestore.instance.doc(data['groupOwner'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants.map((ref) => ref.path).toList(),
      'name': name,
      'isGroup': isGroup,
      'groupOwner': groupOwner?.path,
      'createdAt': Timestamp.now(),
    };
  }
}
