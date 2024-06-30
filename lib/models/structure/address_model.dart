import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  final DocumentReference countryId;
  final String district;
  final DocumentReference landmarkId;
  final DocumentReference provinceId;
  final String street;
  final String ward;

  Address({
    required this.countryId,
    required this.district,
    required this.landmarkId,
    required this.provinceId,
    required this.street,
    required this.ward,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      countryId: map['country_id'],
      district: map['district'],
      landmarkId: map['landmark_id'],
      provinceId: map['province_id'],
      street: map['street'],
      ward: map['ward'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'country_id': countryId,
      'district': district,
      'landmark_id': landmarkId,
      'province_id': provinceId,
      'street': street,
      'ward': ward,
    };
  }
}
