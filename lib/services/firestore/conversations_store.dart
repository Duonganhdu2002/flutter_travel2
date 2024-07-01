import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/conversation_model.dart';

class ConversationStore {
  final CollectionReference conversationCollection =
      FirebaseFirestore.instance.collection('conversations');

  Future<DocumentReference> addConversation(Conversation conversation) async {
    try {
      DocumentReference docRef =
          await conversationCollection.add(conversation.toMap());
      debugPrint('Conversation added successfully');
      return docRef;
    } catch (e) {
      debugPrint('Error adding conversation: $e');
      rethrow;
    }
  }

  Stream<Conversation?> streamConversationById(String id) {
    return conversationCollection.doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Conversation.fromSnapshot(snapshot);
      } else {
        debugPrint('Conversation not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming conversation: $error');
      return null;
    });
  }

  Future<void> updateConversation(
      String id, Map<String, dynamic> updatedData) async {
    try {
      await conversationCollection.doc(id).update(updatedData);
      debugPrint('Conversation updated successfully');
    } catch (e) {
      debugPrint('Error updating conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await conversationCollection.doc(id).delete();
      debugPrint('Conversation deleted successfully');
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      rethrow;
    }
  }
}
