import 'package:cloud_firestore/cloud_firestore.dart';

class SettingService {

  static DocumentReference _getDocumentByMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'timed':
        return FirebaseFirestore.instance.collection('settings').doc('timed');
      default:
        throw ArgumentError('Invalid mode: $mode');
    }
  }

  static DocumentReference getSetting(String mode){
    return _getDocumentByMode(mode);
  }

  static Future<dynamic> getField(String mode, String field) async {
    try {
      DocumentSnapshot documentSnapshot = await _getDocumentByMode(mode).get();
      if (documentSnapshot.exists) {
        return documentSnapshot[field];
      } else {
        throw Exception('Document does not exist');
      }
    } catch (e) {
      throw Exception('Error getting field: $e');
    }
  }

}
