import 'package:cloud_firestore/cloud_firestore.dart';

class Province {
  final String id;
  final DocumentReference countryRef;
  final String description;
  final String icon;
  final String name;
  final List<dynamic> photos;

  Province({
    required this.id,
    required this.countryRef,
    required this.description,
    required this.icon,
    required this.name,
    required this.photos,
  });

  factory Province.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Province(
      id: snapshot.id,
      countryRef: data['countryRef'],
      description: data['description'],
      icon: data['icon'],
      name: data['name'],
      photos: List<dynamic>.from(data['photos']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'countryRef': countryRef,
      'description': description,
      'icon': icon,
      'name': name,
      'photos': photos,
    };
  }
}
