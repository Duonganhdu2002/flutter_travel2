import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/structure/province_model.dart';

class ProvinceStore {
  final CollectionReference provinces = FirebaseFirestore.instance.collection("provinces");

  // Add a new province
  Future<void> addProvince(Province province) {
    return provinces.add(province.toMap());
  }

  // Stream of all provinces
  Stream<List<Province>> getProvinces() {
    return provinces.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Province.fromSnapshot(doc)).toList());
  }

  // Stream of a single province by ID
  Stream<Province> getProvinceById(String id) {
    return provinces.doc(id).snapshots().map((snapshot) => Province.fromSnapshot(snapshot));
  }

  // Update a province
  Future<void> updateProvince(String id, Map<String, dynamic> updatedData) {
    return provinces.doc(id).update(updatedData);
  }

  // Delete a province
  Future<void> deleteProvince(String id) {
    return provinces.doc(id).delete();
  }
}
