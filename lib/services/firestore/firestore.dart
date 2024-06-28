import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collectuion of Notess
  final CollectionReference notes =
      FirebaseFirestore.instance.collection("notes");

  // CREATE: add a new note
  Future<void> addNote(String note) {
    return notes.add({'note': note, 'timestamp': Timestamp.now()});
  }

  //READ: get note from database
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //UPDATE:
  Future<void> updateNote(String docID, String newNote) {
    return notes
        .doc(docID)
        .update({'note': newNote, 'timestamp': Timestamp.now()});
  }

  //READ:
  Future<void> deteleNote(String docID) {
    return notes.doc(docID).delete();
  }
}
