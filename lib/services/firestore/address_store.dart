import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/structure/address_model.dart';

class AddressStore {
  final CollectionReference addressCollection =
      FirebaseFirestore.instance.collection('addresses');

  Future<void> addAddress(Address address) async {
    try {
      await addressCollection.add(address.toMap());
      debugPrint('Address added successfully');
    } catch (e) {
      debugPrint('Error adding address: $e');
    }
  }

  Stream<Address?> streamAddressById(String id) {
    return addressCollection.doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Address.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        debugPrint('Address not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming address: $error');
      return null;
    });
  }

  Future<void> updateAddress(
      String id, Map<String, dynamic> updatedData) async {
    try {
      await addressCollection.doc(id).update(updatedData);
      debugPrint('Address updated successfully');
    } catch (e) {
      debugPrint('Error updating address: $e');
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await addressCollection.doc(id).delete();
      debugPrint('Address deleted successfully');
    } catch (e) {
      debugPrint('Error deleting address: $e');
    }
  }
}
