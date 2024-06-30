import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String icon;
  final String name;

  Category({
    required this.id,
    required this.icon,
    required this.name,
  });

  factory Category.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Category(
      id: snapshot.id,
      icon: data['icon'],
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'name': name,
    };
  }
}
