import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String id;
  final Timestamp dayEnd;
  final Timestamp dayStart;
  final int fund;
  final String name;
  final List<dynamic> participants;
  final DocumentReference placeRef;
  final DocumentReference planOwner;
  final bool public;
  final Map<DocumentReference, int> contributions;
  final int desiredParticipants;
  final DocumentReference conversationRef; // Thêm thuộc tính conversationRef

  Plan({
    required this.id,
    required this.dayEnd,
    required this.dayStart,
    required this.fund,
    required this.name,
    required this.participants,
    required this.placeRef,
    required this.planOwner,
    required this.public,
    required this.contributions,
    required this.desiredParticipants,
    required this.conversationRef, // Thêm vào constructor
  });

  factory Plan.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Plan(
      id: snapshot.id,
      dayEnd: data['dayEnd'],
      dayStart: data['dayStart'],
      fund: data['fund'],
      name: data['name'],
      participants: List<dynamic>.from(data['participants']),
      placeRef: data['placeRef'],
      planOwner: data['planOwner'],
      public: data['public'],
      contributions: (data['contributions'] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(FirebaseFirestore.instance.doc(key), value as int)),
      desiredParticipants: data['desiredParticipants'],
      conversationRef: data['conversationRef'], // Lấy giá trị từ snapshot
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayEnd': dayEnd,
      'dayStart': dayStart,
      'fund': fund,
      'name': name,
      'participants': participants,
      'placeRef': placeRef,
      'planOwner': planOwner,
      'public': public,
      'contributions': contributions.map((key, value) => MapEntry(key.path, value)),
      'desiredParticipants': desiredParticipants,
      'conversationRef': conversationRef, // Thêm vào map
    };
  }

  int get currentFund => contributions.values.fold(0, (sum, value) => sum + value);
}
