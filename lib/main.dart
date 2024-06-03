import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/pages/read_listview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    home: ReadListView(),
  ));
}