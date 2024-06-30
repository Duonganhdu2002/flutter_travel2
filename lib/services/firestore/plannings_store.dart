import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/plan_model.dart';

class PlanningStore {
  final CollectionReference planCollection =
      FirebaseFirestore.instance.collection('plannings');

  Future<void> addPlan(Plan plan) async {
    try {
      await planCollection.add(plan.toMap());
      debugPrint('Plan added successfully');
    } catch (e) {
      debugPrint('Error adding plan: $e');
    }
  }

  Stream<Plan?> streamPlanById(String id) {
    return planCollection.doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Plan.fromSnapshot(snapshot);
      } else {
        debugPrint('Plan not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming plan: $error');
      return null;
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
