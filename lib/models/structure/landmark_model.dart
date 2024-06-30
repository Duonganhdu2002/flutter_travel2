import 'package:cloud_firestore/cloud_firestore.dart';

class Landmark {
  final String id;
  final String description;
  final String icon;
  final String name;
  final List<dynamic> photos;
  final DocumentReference provinceRef;

  Landmark({
    required this.id,
    required this.description,
    required this.icon,
    required this.name,
    required this.photos,
    required this.provinceRef,
  });

  factory Landmark.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Landmark(
      id: snapshot.id,
      description: data['description'],
      icon: data['icon'],
      name: data['name'],
      photos: List<dynamic>.from(data['photos']),
      provinceRef: data['provinceRef'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'icon': icon,
      'name': name,
      'photos': photos,
      'provinceRef': provinceRef,
    };
  }
}
