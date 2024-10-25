import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminWebborad extends StatefulWidget {
  final String userId;

  const AdminWebborad({Key? key, required this.userId}) : super(key: key);

  @override
  State<AdminWebborad> createState() => _AdminWebboradState();
}

class _AdminWebboradState extends State<AdminWebborad> {
  String? _profile;
  String? _textPost;
  File? _image;

  TextEditingController _textPostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        String? imageUrl = snapshot.get('image_url');

        setState(() {
          _profile = imageUrl;
        });
      } else {
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          _profile = null;
        });
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _adminPost();
            },
            icon: Icon(Icons.edit_document),
          ),
        ],
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        title: const Text(
          "กระทู้",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 255, 94, 0)
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('post')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      data['id'] = document.id; // Adding the document ID
                      return PostItem(data: data);
                    }).toList(),
                  );
                } else {
                  return Center(child: Text("ยังไม่มีโพสต์"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
   Future<void> _pickImage() async {
    try {
      final imagepicker = ImagePicker();
      final image = await imagepicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _adminPost() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('สร้างโพสของคุณ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async { 
                        await _pickImage();
                        setState(() {}); // Update the state to show the selected image
                      },
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(width: 2, color: Color.fromARGB(255, 179, 178, 177)),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _image == null
                            ? Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 120,
                                color: Colors.grey[800],
                              )
                            : null,
                      ),
                    ),
                    TextField(
                      controller: _textPostController,
                      maxLines: null,
                      decoration:
                          InputDecoration(hintText: 'คำอธิบายของคุณ'),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () async {
                    // Your function to handle the post submission
                    await _submitPost();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('ยืนยัน'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<String> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('posts/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("เกิดข้อผิดพลาดในการอัปโหลดภาพ: $e");
      return '';
    }
  }

  Future<void> _submitPost() async {
    setState(() {
      _textPost = _textPostController.text;
    });

    if (_textPost != null && _textPost!.isNotEmpty && _image != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userId)
            .get();

        if (userSnapshot.exists) {
          String username = userSnapshot.get('username');
          String profileUrl = userSnapshot.get('image_url');
          String imageUrl = await uploadImage(_image!);

          await FirebaseFirestore.instance.collection('post').add({
            'textPost': _textPost,
            'usernamepost': username,
            'profileuserpost': profileUrl,
            'imageUrl': imageUrl, // Replace with actual image URL
            'timestamp': FieldValue.serverTimestamp(),
            'likes': 0,
          });

          // Clear the text field and image after submission
          _textPostController.clear();
          setState(() {
            _textPost = null;
            _image = null;
          });
        }
      } catch (e) {
        print("เกิดข้อผิดพลาดในการบันทึกโพสต์: $e");
      }
    }
  }
}

class Comment {
  final String username;
  final String profileUrl;
  final dynamic timestamp;
  final String commentText;

  Comment({
    required this.username,
    required this.profileUrl,
    required this.timestamp,
    required this.commentText,
  });
}

class PostItem extends StatefulWidget {
  final Map<String, dynamic> data;

  const PostItem({Key? key, required this.data}) : super(key: key);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.data['likes'] ?? 0;
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });

    // Update the like count in Firestore
    FirebaseFirestore.instance
        .collection('post')
        .doc(widget.data['id'])
        .update({'likes': _likeCount});
  }

  void _comment() {
    TextEditingController _commentController =
        TextEditingController(); // Controller for comment text field

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เพิ่มความคิดเห็น'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('post')
                    .doc(widget.data['id'])
                    .collection('comments')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<Comment> comments =
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Comment(
                      username: data['usernamecomment'],
                      profileUrl: data['profileusercomment'],
                      timestamp: data['timestamp'],
                      commentText: data['commentText'],
                    );
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(comments[index].profileUrl)),
                        title: Text(comments[index].username),
                        subtitle: Text(comments[index].commentText),
                      );
                    },
                  );
                },
              ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(hintText: 'เขียนความคิดเห็น'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                // Get the comment text from the text field
                String commentText = _commentController.text;

                if (commentText.isNotEmpty) {
                  // Get current user's username and profile image URL
                  String username = widget.data['usernamepost'];
                  String profileUrl = widget.data['profileuserpost'];

                  // Create a new comment document in Firestore
                  await FirebaseFirestore.instance
                      .collection('post')
                      .doc(widget.data['id'])
                      .collection('comments')
                      .add({
                    'usernamecomment': username,
                    'profileusercomment': profileUrl,
                    'timestamp': FieldValue.serverTimestamp(),
                    'commentText': commentText,
                  });

                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: const Color.fromARGB(255, 197, 197, 197)),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.data['profileuserpost'] != null
                        ? NetworkImage(widget.data['profileuserpost'])
                        : null,
                    child: widget.data['profileuserpost'] == null
                        ? Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(widget.data['usernamepost'] ?? 'Unknown User'),
                ],
              ),
              Text(
                widget.data['timestamp'] != null
                    ? (widget.data['timestamp'] as Timestamp)
                        .toDate()
                        .toString()
                    : '',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.data['imageUrl'] != null
                  ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            widget.data['imageUrl'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  )
                  : SizedBox
                      .shrink(), // Add this to conditionally show the image
              Text(widget.data['textPost'] ?? ''),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : null,
                        ),
                      ),
                      Text("$_likeCount"),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: _comment,
                        icon: Icon(Icons.chat),
                      ),
                      Text("เเสดงความคิดเห็น"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
