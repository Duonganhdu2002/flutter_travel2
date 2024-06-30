import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/structure/landmark_model.dart';

class LandmarkStore {
  final CollectionReference landmarks = FirebaseFirestore.instance.collection("landmarks");

  // Add a new landmark
  Future<void> addLandmark(Landmark landmark) {
    return landmarks.add(landmark.toMap());
  }

  // Stream of all landmarks
  Stream<List<Landmark>> getLandmarks() {
    return landmarks.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Landmark.fromSnapshot(doc)).toList());
  }

  // Stream of a single landmark by ID
  Stream<Landmark> getLandmarkById(String id) {
    return landmarks.doc(id).snapshots().map((snapshot) => Landmark.fromSnapshot(snapshot));
  }

  // Update a landmark
  Future<void> updateLandmark(String id, Map<String, dynamic> updatedData) {
    return landmarks.doc(id).update(updatedData);
  }

  // Delete a landmark
  Future<void> deleteLandmark(String id) {
    return landmarks.doc(id).delete();
  }
}
