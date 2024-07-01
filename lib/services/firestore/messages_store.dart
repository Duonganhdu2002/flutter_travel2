import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';

class MessageStore {
  final CollectionReference messageCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<void> addMessage(Message message) async {
    try {
      await messageCollection.add(message.toMap());
      debugPrint('Message added successfully');
    } catch (e) {
      debugPrint('Error adding message: $e');
      rethrow;
    }
  }

  Stream<Message?> streamMessageById(String id) {
    return messageCollection.doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Message.fromSnapshot(snapshot);
      } else {
        debugPrint('Message not found');
        return null;
      }
    }).handleError((error) {
      debugPrint('Error streaming message: $error');
      return null;
    });
  }

  Future<void> updateMessage(
      String id, Map<String, dynamic> updatedData) async {
    try {
      await messageCollection.doc(id).update(updatedData);
      debugPrint('Message updated successfully');
    } catch (e) {
      debugPrint('Error updating message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await messageCollection.doc(id).delete();
      debugPrint('Message deleted successfully');
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }
}
