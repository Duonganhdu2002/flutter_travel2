import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceStore {
  final CollectionReference places =
      FirebaseFirestore.instance.collection("places");
  final CollectionReference ratings =
      FirebaseFirestore.instance.collection("ratings");

  Future<void> addNewPlace({
    required Map<String, dynamic> address,
    required DocumentReference categoryRef,
    required String description,
    required DocumentReference userRef,
    required String name,
    required List<dynamic> photos,
  }) {
    return places.add({
      'address': address,
      'categoryRef': categoryRef,
      'description': description,
      'userRef': userRef,
      'name': name,
      'photos': photos,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamTop10Places() {
    return places.snapshots().asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> placesWithRatings = [];

      for (var placeDoc in querySnapshot.docs) {
        var ratingsQuery = await ratings
            .where('placeRef', isEqualTo: placeDoc.reference)
            .get();

        double averageRating = 0;
        if (ratingsQuery.docs.isNotEmpty) {
          int totalRatings = ratingsQuery.docs.length;
          int sumRatings = ratingsQuery.docs.fold<int>(
            0,
            (sumRatings, ratingDoc) =>
                sumRatings + (ratingDoc['rating'] as int),
          );
          averageRating = sumRatings / totalRatings;
        }

        var placeData = placeDoc.data() as Map<String, dynamic>;
        placeData['averageRating'] = averageRating;
        placeData['documentId'] = placeDoc.id; // Include the document ID

        placesWithRatings.add(placeData);
      }

      placesWithRatings.sort((a, b) => (b['averageRating'] as double)
          .compareTo(a['averageRating'] as double));
      return placesWithRatings.take(10).toList();
    });
  }

  Future<DocumentSnapshot> getPlaceById(String placeId) async {
    return await places.doc(placeId).get();
  }

  Future<void> updatePlace({
    required String placeId,
    Map<String, dynamic>? address,
    DocumentReference? categoryRef,
    String? description,
    String? name,
    List<dynamic>? photos,
  }) {
    return places.doc(placeId).update({
      if (address != null) 'address': address,
      if (categoryRef != null) 'categoryRef': categoryRef,
      if (description != null) 'description': description,
      if (name != null) 'name': name,
      if (photos != null) 'photos': photos,
    });
  }

  Future<void> deletePlace(String placeId) {
    return places.doc(placeId).delete();
  }
}
