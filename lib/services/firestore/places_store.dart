import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceStore {
  final CollectionReference places =
      FirebaseFirestore.instance.collection("places");

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
    return places.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) {
            var placeData = doc.data() as Map<String, dynamic>;
            placeData['documentId'] = doc.id; // Include the document ID
            return placeData;
          })
          .take(10)
          .toList();
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

  // New method to stream all places without ratings
  Stream<List<Map<String, dynamic>>> streamAllPlaces() {
    return places.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var placeData = doc.data() as Map<String, dynamic>;
        placeData['documentId'] = doc.id; // Include the document ID
        return placeData;
      }).toList();
    });
  }
  
}
