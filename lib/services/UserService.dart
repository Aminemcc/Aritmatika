import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserService{

  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> addUser() {
    return users.doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'bestStage' : 0
    });
  }

  Future<void> updateBestStage(int bestStage) {
    return users.doc(user.uid).update({
      'bestStage': bestStage,
    });
  }

}