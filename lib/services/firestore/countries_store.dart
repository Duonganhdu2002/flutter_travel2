import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/structure/country_model.dart';

class CountryClaas {
  final CollectionReference countries =
      FirebaseFirestore.instance.collection("countries");

  // Add a new country
  Future<void> addCountry(Country country) {
    return countries.add(country.toMap());
  }

  // Retrieve all countries
  Stream<List<Country>> getCountries() {
    return countries.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Country.fromSnapshot(doc)).toList());
  }

  // Retrieve a single country by ID
  Stream<Country> getCountryById(String id) {
    return countries
        .doc(id)
        .snapshots()
        .map((snapshot) => Country.fromSnapshot(snapshot));
  }

  // Update a country
  Future<void> updateCountry(String id, Map<String, dynamic> updatedData) {
    return countries.doc(id).update(updatedData);
  }

  // Delete a country
  Future<void> deleteCountry(String id) {
    return countries.doc(id).delete();
  }
}
