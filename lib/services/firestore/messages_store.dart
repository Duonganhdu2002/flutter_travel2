import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/structure/message_model.dart';

class MessageStore {
  Future<void> addMessage(Message message) async {
    final messageData = message.toMap();
    await message.conversationId.collection('messages').add(messageData);
  }

  Stream<List<Message>> streamMessagesForConversation(
      DocumentReference conversationId) {
    return conversationId
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromSnapshot(doc)).toList())
        .handleError((error) {
      debugPrint('Error streaming messages: $error');
    });
  }

  Future<void> updateMessage(DocumentReference conversationId, String messageId,
      Map<String, dynamic> updatedData) async {
    try {
      await conversationId
          .collection('messages')
          .doc(messageId)
          .update(updatedData);
      debugPrint('Message updated successfully');
    } catch (e) {
      debugPrint('Error updating message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(
      DocumentReference conversationId, String messageId) async {
    try {
      await conversationId.collection('messages').doc(messageId).delete();
      debugPrint('Message deleted successfully');
    } catch (e) {
      debugPrint('Error deleting message: $e');
      rethrow;
    }
  }
}
