import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aritmatika/services/UserService.dart';

class LeaderboardService {
  final maxListed = 100; // maximum displayed player in top leaderboards
  late final CollectionReference stageLeaderboard, timer_20_29Leaderboard;

  LeaderboardService() {

    stageLeaderboard = FirebaseFirestore.instance
        .collection('leaderboard')
        .doc('stage')
        .collection('stageLeaderboard');

    timer_20_29Leaderboard = FirebaseFirestore.instance
        .collection('leaderboard')
        .doc('timer_20_29')
        .collection('timer20-29Leaderboard');
  }

  CollectionReference _getCollectionByMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'stage':
        return stageLeaderboard;
      case 'timer_20_29':
        return timer_20_29Leaderboard;
      default:
        throw ArgumentError('Invalid mode: $mode');
    }
  }

  Map<String, dynamic> _getOrderSetting(String mode){
    switch(mode.toLowerCase()) {
      case 'stage':
        return {"orderBy": "stage", "descending": true}; // ganti ntar
      case 'timer_20_29':
        return {"orderBy": "timeTaken", "descending": false};
      default:
    throw ArgumentError('Invalid mode: $mode');
    }
  }

  Future<void> addLeaderboardEntry(String mode, String uid, Map<String, dynamic> data) async {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.doc(uid).set({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLeaderboardEntry(String mode, String uid, Map<String, dynamic> data) {
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.doc(uid).update({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getHistoryStream(String mode) {
    Map<String, dynamic> orderSetting = _getOrderSetting(mode);
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy(orderSetting["orderBy"], descending: orderSetting["descending"]).snapshots();
  }

  Future<QuerySnapshot> getHistoryEntries(String mode) {
    Map<String, dynamic> orderSetting = _getOrderSetting(mode);
    CollectionReference collection = _getCollectionByMode(mode);
    return collection.orderBy(orderSetting["orderBy"], descending: orderSetting["descending"]).get();
  }

  Future<void> deleteLeaderboardEntry(String mode, String uid) async {
    CollectionReference collection = _getCollectionByMode(mode);
    await collection.doc(uid).delete();
  }

  Future<void> deleteAllLeaderboardEntries(String mode) async {
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

  Future<void> syncLeaderboardWithUsers(String mode) async {
    print("a");
  }

}
