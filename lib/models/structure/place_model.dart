import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/structure/address_model.dart';

class Place {
  final String id;
  final Address address;
  final DocumentReference categoryRef;
  final String description;
  final String name;
  final List<dynamic> photos;

  Place({
    required this.id,
    required this.address,
    required this.categoryRef,
    required this.description,
    required this.name,
    required this.photos,
  });

  factory Place.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Place(
      id: snapshot.id,
      address: Address.fromMap(data['address']),
      categoryRef: data['categoryRef'],
      description: data['description'],
      name: data['name'],
      photos: List<dynamic>.from(data['photos']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address.toMap(),
      'categoryRef': categoryRef,
      'description': description,
      'name': name,
      'photos': photos,
    };
  }
}
