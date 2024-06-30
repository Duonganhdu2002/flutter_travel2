import 'package:cloud_firestore/cloud_firestore.dart';

class RatingStore {
  final CollectionReference ratings =
      FirebaseFirestore.instance.collection("ratings");

  Future<void> addNewRating({
    required String comment,
    required DocumentReference placeRef,
    required int rating,
    required DocumentReference userRef,
  }) {
    return ratings.add({
      'comment': comment,
      'placeRef': placeRef,
      'rating': rating,
      'userRef': userRef,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateRating({
    required String ratingId,
    String? comment,
    int? rating,
  }) {
    return ratings.doc(ratingId).update({
      if (comment != null) 'comment': comment,
      if (rating != null) 'rating': rating,
    });
  }

  Future<void> deleteRating(String ratingId) {
    return ratings.doc(ratingId).delete();
  }

  Stream<List<Map<String, dynamic>>> streamRatingsForPlace(
      DocumentReference placeRef) {
    return ratings
        .where('placeRef', isEqualTo: placeRef)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'comment': doc['comment'],
                'rating': doc['rating'],
                'userRef': doc['userRef'],
                'createdAt': doc['createdAt'],
              })
          .toList();
    });
  }
}
