import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/category_model.dart';

class CategoryStore {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<void> addCategory(Category category) async {
    try {
      await categoryCollection.add(category.toMap());
      debugPrint('Category added successfully');
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }

  Stream<Category?> streamCategoryById(String id) {
    return categoryCollection.doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Category.fromSnapshot(snapshot);
      } else {
        debugPrint('Category not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming category: $error');
      return null;
    });
  }

  Future<void> updateCategory(
      String id, Map<String, dynamic> updatedData) async {
    try {
      await categoryCollection.doc(id).update(updatedData);
      debugPrint('Category updated successfully');
    } catch (e) {
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categoryCollection.doc(id).delete();
      debugPrint('Category deleted successfully');
    } catch (e) {
      debugPrint('Error deleting category: $e');
    }
  }
}
