import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String id;
  final String currency;
  final String icon;
  final List<dynamic> languages;
  final String name;

  Country({
    required this.id,
    required this.currency,
    required this.icon,
    required this.languages,
    required this.name,
  });

  factory Country.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Country(
      id: snapshot.id,
      currency: data['currency'],
      icon: data['icon'],
      languages: List<dynamic>.from(data['languages']),
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'icon': icon,
      'languages': languages,
      'name': name,
    };
  }
}
