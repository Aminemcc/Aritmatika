import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aritmatika/components/text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.storage.request();
    await Permission.camera.request();
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
                    .doc(currentUser.uid)
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
            .child(currentUser.uid)
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
          .doc(currentUser.uid)
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
        .doc(currentUser.uid)
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          newImageFile = File(pickedFile.path);
                        });
                      }
                    },
                    child: Text('Change Image'),
                  ),
                  if (postData['imageUrl'] != null)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          removeImage = true;
                          newImageFile = null;
                        });
                      },
                      child: Text('Remove Image'),
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
            .child(currentUser.uid)
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
        .doc(currentUser.uid)
        .collection('posts')
        .doc(postId);

    final updates = <String, dynamic>{
      'text': newText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (removeImage) {
      updates['imageUrl'] = FieldValue.delete();
    } else if (newImageUrl != null) {
      updates['imageUrl'] = newImageUrl;
    }

    try {
      await postRef.update(updates);
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
            .doc(currentUser.uid)
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

          return ListView(
            children: [
              SizedBox(height: 50),
              Icon(Icons.person, size: 72),
              SizedBox(height: 50),
              Text(
                currentUser.email!,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: ElevatedButton(
                  onPressed: _createNewPost,
                  child: Text('Create New Post'),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
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
                        return _buildPostItem(post.id, postData);
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

  Widget _buildPostItem(String postId, Map<String, dynamic> postData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            postData['text'] ?? '',
            style: TextStyle(color: Colors.grey[500]),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editPost(postId, postData),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePost(postId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: ProfilePage()));
