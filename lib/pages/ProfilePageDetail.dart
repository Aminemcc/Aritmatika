import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox(
      {super.key,
        required this.text,
        required this.sectionName,
        required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // section name
              Text(
                sectionName,
                style: TextStyle(color: Colors.grey[500]),
              ),

            ],
          ),

          // text
          Text(text),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final uid;

  const ProfilePage(this.uid, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.camera.request();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(widget.uid);
      final uploadTask = await storageRef.putFile(_profileImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'profileImageUrl': imageUrl});

      print('Profile image uploaded successfully: $imageUrl');
    } catch (e) {
      print('Error uploading profile image: $e');
      showErrorMessage('Failed to upload profile image');
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'profileImageUrl': FieldValue.delete()});

      setState(() {
        _profileImage = null;
      });

      print('Profile image deleted successfully');
    } catch (e) {
      print('Error deleting profile image: $e');
      showErrorMessage('Failed to delete profile image');
    }
  }

  Future<void> editField(String field) async {
    String newValue = '';
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
                if (field == 'username' && newValue.contains('@')) {
                  showErrorMessage('Username tidak boleh mengandung "@"');
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
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

  void _createNewPost() async {
    String newText = '';
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Post'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        newText = value;
                      });
                    },
                    decoration: InputDecoration(hintText: "Enter your post"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          imageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Text('Choose Image'),
                  ),
                ],
              );
            },
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
                Navigator.pop(context);
                await _savePost(newText, imageFile);
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePost(String text, File? imageFile) async {
    if (text.isEmpty && imageFile == null) {
      showErrorMessage('Post cannot be empty');
      return;
    }

    String? imageUrl;
    if (imageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(widget.uid)
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        final uploadTask = await storageRef.putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
        print('Image uploaded successfully: $imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
        showErrorMessage('Failed to upload image');
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('posts')
          .add({
        'text': text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Post saved successfully');
    } catch (e) {
      print('Error saving post: $e');
      showErrorMessage('Failed to save post');
    }
  }

  Future<void> _deletePost(String postId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('posts')
        .doc(postId)
        .delete();
  }

  void _editPost(String postId, Map<String, dynamic> postData) async {
    String newText = postData['text'] ?? '';
    File? newImageFile;
    bool removeImage = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: newText),
                    onChanged: (value) {
                      setState(() {
                        newText = value;
                      });
                    },
                    decoration: InputDecoration(hintText: "Edit your post"),
                  ),
                ],
              );
            },
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
                Navigator.pop(context);
                await _updatePost(postId, newText, newImageFile, removeImage);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePost(String postId, String newText, File? newImageFile,
      bool removeImage) async {
    String? newImageUrl;
    if (newImageFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('posts')
            .child(widget.uid)
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        final uploadTask = await storageRef.putFile(newImageFile);
        newImageUrl = await uploadTask.ref.getDownloadURL();
        print('New image uploaded successfully: $newImageUrl');
      } catch (e) {
        print('Error uploading new image: $e');
        showErrorMessage('Failed to upload new image');
        return;
      }
    }

    final postRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('posts')
        .doc(postId);

    try {
      if (removeImage) {
        await postRef.update({
          'text': newText,
          'imageUrl': FieldValue.delete(),
        });
      } else {
        await postRef.update({
          'text': newText,
          if (newImageUrl != null) 'imageUrl': newImageUrl,
        });
      }
      print('Post updated successfully');
    } catch (e) {
      print('Error updating post: $e');
      showErrorMessage('Failed to update post');
    }
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
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final username = userData['username'] ?? '';
          final bio = userData['bio'] ?? '';
          final profileImageUrl = userData['profileImageUrl'] ?? '';
          final email = userData['email'];

          return ListView(
            children: [
              SizedBox(height: 50),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                    ),
                  ],
                ),
              ),
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text('My Details', style: TextStyle(color: Colors.grey[600])),
              ),
              MyTextBox(
                text: username,
                sectionName: 'username',
                onPressed: () => editField('username'),
              ),
              MyTextBox(
                text: bio,
                sectionName: 'My Bio',
                onPressed: () => editField('bio'),
              ),
              SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text('My Posts', style: TextStyle(color: Colors.grey[600])),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .collection('posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final posts = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;
                        return _buildPostItem(post.id, postData, username);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ' + snapshot.error.toString()));
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostItem(String postId, Map<String, dynamic> postData, String username) {
    final timestamp = postData['timestamp'] as Timestamp?;
    final postTime = timestamp != null ? timestamp.toDate() : DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15, top: 15, right: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    '${postTime.toLocal()}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            postData['text'] ?? '',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 10),
          if (postData['imageUrl'] != null)
            Container(
              constraints: BoxConstraints(
                maxHeight: 200,
                maxWidth: double.infinity,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  postData['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

