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
    };
  }
}
