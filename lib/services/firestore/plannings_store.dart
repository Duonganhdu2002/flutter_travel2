import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';

class PlanningStore {
  final CollectionReference planCollection =
      FirebaseFirestore.instance.collection('plannings');

  Stream<List<Plan>> streamPublicPlans() {
    return planCollection.where('public', isEqualTo: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Plan.fromSnapshot(doc)).toList());
  }

  Future<void> addPlan(Plan plan) async {
    try {
      await planCollection.add(plan.toMap());
      debugPrint('Plan added successfully');
    } catch (e) {
      debugPrint('Error adding plan: $e');
    }
  }

  Stream<List<Plan>> streamPlansByUserId(String userId) {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('auths').doc(userId);

    return planCollection
        .where('participants', arrayContains: userRef)
        .snapshots()
        .map((snapshot) {
      debugPrint('Fetched ${snapshot.docs.length} plans for user $userId');
      return snapshot.docs.map((doc) => Plan.fromSnapshot(doc)).toList();
    }).handleError((error) {
      debugPrint('Error streaming plans: $error');
      return [];
    });
  }

  Future<void> updatePlan(String id, Map<String, dynamic> updatedData) async {
    try {
      await planCollection.doc(id).update(updatedData);
      debugPrint('Plan updated successfully');
    } catch (e) {
      debugPrint('Error updating plan: $e');
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await planCollection.doc(id).delete();
      debugPrint('Plan deleted successfully');
    } catch (e) {
      debugPrint('Error deleting plan: $e');
    }
  }
}
