import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aritmatika/services/UserService.dart';

class HistoryService {
  final maxEntry = 1000;
  final userService = UserService();
  late final User user;
  late final CollectionReference stageHistory, timer_20_29_History;
  late final CollectionReference classicHistory, bitwiseHistory, randomHistory, solverHistory;

  HistoryService() {
    user = FirebaseAuth.instance.currentUser!;

    stageHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stageHistory');

    timer_20_29_History = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('timer20-29History');

    classicHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('classicHistory');
    bitwiseHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bitwiseHistory');
    randomHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('randomHistory');
    solverHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('solverHistory');
  }

  CollectionReference _getCollectionByMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'classic':
        return classicHistory;
      case 'bitwise':
        return bitwiseHistory;
      case 'random':
        return randomHistory;
      case 'solver':
        return solverHistory;
      case 'timer20-29':
        return timer_20_29_History;
      default:
        throw ArgumentError('Invalid mode: $mode');
    }
  }

  Future<String> addHistoryEntry(String mode, Map<String, dynamic> data) async {
    CollectionReference collection = _getCollectionByMode(mode);
    DocumentReference docRef = await collection.add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id; // Return the document ID
  }

  Future<void> addSubHistoryEntries(String mode, List<Map<String, dynamic>> dataList, String docId, String collectionName) async {
    CollectionReference collection = _getCollectionByMode(mode);
    CollectionReference subCollection = collection.doc(docId).collection(collectionName);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (Map<String, dynamic> data in dataList) {
      DocumentReference docRef = subCollection.doc();
      batch.set(docRef, data);
    }
    await batch.commit();
  }


  Future<void> updateHistoryEntry(String mode, String documentId, Map<String, dynamic> data) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.doc(documentId).update({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteHistoryEntry(String mode, String docId) async {
    CollectionReference collection = _getCollectionByMode(mode);
    await collection.doc(docId).delete();
  }

  Future<void> deleteAllHistoryEntries(String mode) async {
    CollectionReference collection = _getCollectionByMode(mode);

    // Get all documents in the collection
    QuerySnapshot snapshot = await collection.get();

    // Create a batch to delete all documents
    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (DocumentSnapshot doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch
    await batch.commit();
  }

  Stream<QuerySnapshot> getHistoryStream(String mode) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getSubHistoryStream(String mode, String docId, String collectionName) {
    CollectionReference collection = _getCollectionByMode(mode);
    CollectionReference subCollection = collection.doc(docId).collection(collectionName);
    return subCollection.orderBy('timestamp', descending: false).snapshots();
  }

  Future<QuerySnapshot> getHistoryEntries(String mode) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy('timestamp', descending: true).get();
  }

  //-----Timed Mode-----//
  Stream<QuerySnapshot> getTimedAttemptStream(String mode) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<List<Map<String, dynamic>>> getTimedAttemptDetail(String mode, String docId) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.doc(docId).snapshots().map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['datas']);
      } else {
        return [];
      }
    });
  }



  //-----Stage Mode-----//
  Future<void> addStageEntry(int stage, Map<String, dynamic> data) async {
    await stageHistory.add({
      ...data,
      'stage': stage,
      'timestamp': FieldValue.serverTimestamp(),
    });

    DocumentSnapshot userDoc = await userService.users.doc(user.uid).get();
    int currentBestStage = userDoc['bestStage'] ?? 0;

    if (stage > currentBestStage) {
      await userService.updateBestStage(stage);
    }
  }

}
