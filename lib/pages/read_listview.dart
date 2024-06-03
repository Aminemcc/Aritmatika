import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadListView extends StatefulWidget {
  const ReadListView({super.key});

  @override
  State<ReadListView> createState() => _ReadListViewState();
}

class _ReadListViewState extends State<ReadListView> {
  final _userStream = 
    FirebaseFirestore.instance.collection('leaderboard').snapshots();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read from Firestore'),
      ),
      body: StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Text('Connection Error');
          }

          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          var docs = snapshot.data!.docs;
          // return Text('${docs.length}');
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(docs[index]['name']),
                subtitle: Text('${docs[index]['score']} seconds'),
              );
            }
          );
        },
      ),
    );
  }
}