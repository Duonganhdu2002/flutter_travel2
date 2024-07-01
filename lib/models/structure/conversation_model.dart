import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final List<DocumentReference> participants;
  final DocumentReference messages;
  final String name;
  final bool isGroup; 
  final DocumentReference? groupOwner; 

  Conversation({
    required this.participants,
    required this.messages,
    required this.name,
    required this.isGroup, 
    this.groupOwner,  
  });

  factory Conversation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Conversation(
      participants: List<DocumentReference>.from(data['participants']),
      messages: data['messages'],
      name: data['name'],
      isGroup: data['isGroup'],  
      groupOwner: data['groupOwner'],  
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'messages': messages,
      'name': name,
      'isGroup': isGroup,  
      'groupOwner': groupOwner,  
      'createdAt': Timestamp.now(),
    };
  }
}
