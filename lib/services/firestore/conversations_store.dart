import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Stream<Conversation?> streamConversationById(
      DocumentReference conversationId) {
    return conversationId.snapshots().map((snapshot) {
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

  Future<void> updateConversation(DocumentReference conversationId,
      Map<String, dynamic> updatedData) async {
    try {
      await conversationId.update(updatedData);
      debugPrint('Conversation updated successfully');
    } catch (e) {
      debugPrint('Error updating conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(DocumentReference conversationId) async {
    try {
      await conversationId.delete();
      debugPrint('Conversation deleted successfully');
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
      rethrow;
    }
  }
}
