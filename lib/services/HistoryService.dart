import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aritmatika/services/UserService.dart';

class HistoryService {
  final userService = UserService();
  late final User user;
  late final CollectionReference stageHistory;
  late final CollectionReference classicHistory, binaryHistory, randomHistory, solverHistory;

  HistoryService() {
    user = FirebaseAuth.instance.currentUser!;

    stageHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stageHistory');

    classicHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('classicHistory');
    binaryHistory = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('binaryHistory');
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
    switch (mode) {
      case 'classic':
        return classicHistory;
      case 'binary':
        return binaryHistory;
      case 'random':
        return randomHistory;
      case 'solver':
        return solverHistory;
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

  Future<void> updateHistoryEntry(String mode, String documentId, Map<String, dynamic> data) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.doc(documentId).update({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  Stream<QuerySnapshot> getHistoryStream(String mode) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<QuerySnapshot> getHistoryEntries(String mode) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy('timestamp', descending: true).get();
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
