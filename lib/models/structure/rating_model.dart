import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String comment;
  final DocumentReference placeRef;
  final int rating;
  final DocumentReference userRef;

  Rating({
    required this.id,
    required this.comment,
    required this.placeRef,
    required this.rating,
    required this.userRef,
  });

  factory Rating.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Rating(
      id: snapshot.id,
      comment: data['comment'],
      placeRef: data['placeRef'],
      rating: data['rating'],
      userRef: data['userRef'],
    );
  }
}
