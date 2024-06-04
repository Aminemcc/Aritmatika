import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aritmatika/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;

  // edit field
  Future<void> editField(String field) async {
    String newValue = '';
    // Tampilkan dialog untuk mengedit field
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            onChanged: (value) {
              newValue = value;
            },
            decoration: InputDecoration(hintText: "Enter new $field"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (field == 'username') {
                  // Validasi untuk memastikan username tidak mengandung domain email
                  if (newValue.contains('@')) {
                    showErrorMessage('Username tidak boleh mengandung "@"');
                    return;
                  }
                }
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('profile')
                    .doc('details')
                    .update({field: newValue});
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('profile')
            .doc('details')
            .snapshots(),
        builder: (context, snapshot) {
          // get user data
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            // Handle the case where userData might be null
            if (userData == null) {
              return Center(
                child: Text('No user data available'),
              );
            }

            // Retrieve fields with null safety checks
            final username = userData['username'] ?? 'No username';
            final bio = userData['bio'] ?? 'No bio';

            return ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                // profile pic
                Icon(
                  Icons.person,
                  size: 72,
                ),

                const SizedBox(
                  height: 50,
                ),

                // user email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(
                  height: 50,
                ),

                // user detail
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                // username
                MyTextBox(
                  text: username,
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                // bio
                MyTextBox(
                  text: bio,
                  sectionName: 'My Bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(
                  height: 50,
                ),

                // user post
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'My Posts',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ' + snapshot.error.toString()),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
