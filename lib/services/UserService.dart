import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserService{

  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> addUser(String username) {
    return users.doc(user.uid).set({
      'username' : username,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'bestStage' : 0,
      'bestDisplayTime' : "??:??:??:??",
      'bestTimeTaken' : -1
    });
  }


  static Future<bool> usernameAvailable(String username) async {
    final users = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await users.where('username', isEqualTo: username).get();
    return querySnapshot.docs.isEmpty;
  }
  static Future<String?> getEmailByUsername(String username) async {
    final users = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await users.where('username', isEqualTo: username).get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['email'] as String?;
    } else {
      return null; // Username not found
    }
  }

  Future<void> updateBestStage(int bestStage) {
    return users.doc(user.uid).update({
      'bestStage': bestStage,
    });
  }

  Future<int?> getBestTimeTaken() async {
    try {
      final userData = await users.doc(user.uid).get();
      return userData['bestTimeTaken'] as int?;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateBestTime(int bestTimeTaken, String bestDisplayTime) {
    return users.doc(user.uid).update({
      'bestTimeTaken' : bestTimeTaken,
      'bestDisplayTime': bestDisplayTime,
    });
  }

}