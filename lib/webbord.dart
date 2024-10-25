// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:user/dawer.dart';

// class Webbord extends StatefulWidget {
//   final String userId;

//   const Webbord({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Webbord> createState() => _WebbordState();
// }

// class _WebbordState extends State<Webbord> {
//   String? _profile;
//   String? _textPost;

//   TextEditingController _textPostController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }

//   Future<void> _loadImage() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(widget.userId)
//           .get();

//       if (snapshot.exists) {
//         String? imageUrl = snapshot.get('image_url');

//         setState(() {
//           _profile = imageUrl;
//         });
//       } else {
//         print("เอกสารไม่มีอยู่จริง");
//         setState(() {
//           _profile = null;
//         });
//       }
//     } catch (e) {
//       print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme:
//             const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
//         centerTitle: true,
//         title: const Text(
//           "Webbord",
//           style: TextStyle(
//               fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: const Color.fromARGB(255, 0, 0, 0),
//       ),
//       drawer: Dawer(userId: widget.userId),
//       body: Column(
//         children: [
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 10, top: 10),
//                 child: CircleAvatar(
//                   radius: 25,
//                   backgroundColor: Colors.grey,
//                   backgroundImage:
//                       _profile != null ? NetworkImage(_profile!) : null,
//                   child: _profile == null
//                       ? const Icon(
//                           Icons.person,
//                           color: Colors.grey,
//                         )
//                       : null,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 10, right: 5),
//                   child: Container(
//                     width: 300,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(25),
//                       border: Border.all(
//                         color: Colors.black,
//                         width: 2,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.only(left: 15, right: 5),
//                             child: TextField(
//                               controller: _textPostController,
//                               decoration: const InputDecoration(
//                                 hintText: "Write something...",
//                                 hintStyle: TextStyle(color: Colors.grey),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: IconButton(
//                             onPressed: () {
//                               sandPost();
//                             },
//                             icon: const Icon(
//                               Icons.send,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('post')
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(
//                       child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
//                 }
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }

//                 if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
//                   return ListView(
//                     children: snapshot.data!.docs
//                         .map((DocumentSnapshot document) {
//                       Map<String, dynamic> data =
//                           document.data()! as Map<String, dynamic>;
//                       data['id'] = document.id; // Adding the document ID
//                       return PostItem(data: data);
//                     }).toList(),
//                   );
//                 } else {
//                   return Center(child: Text("ยังไม่มีโพสต์"));
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void sandPost() async {
//     setState(() {
//       _textPost = _textPostController.text;
//     });

//     if (_textPost != null && _textPost!.isNotEmpty) {
//       try {
//         DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//             .collection('user')
//             .doc(widget.userId)
//             .get();

//         if (userSnapshot.exists) {
//           String username = userSnapshot.get('username');
//           String profileUrl = userSnapshot.get('image_url');

//           await FirebaseFirestore.instance.collection('post').add({
//             'textPost': _textPost,
//             'usernamepost': username,
//             'profileuserpost': profileUrl,
//             'timestamp': FieldValue.serverTimestamp(),
//             'likes': 0, // Add a field for likes
//           });

//           // ล้างข้อความในช่องข้อความหลังจากโพสต์
//           _textPostController.clear();
//           setState(() {
//             _textPost = null;
//           });
//         }
//       } catch (e) {
//         print("เกิดข้อผิดพลาดในการบันทึกโพสต์: $e");
//       }
//     }
//   }
// }

// class Comment {
//   final String username;
//   final String profileUrl;
//   final dynamic timestamp;
//   final String commentText;

//   Comment({
//     required this.username,
//     required this.profileUrl,
//     required this.timestamp,
//     required this.commentText,
//   });
// }

// class PostItem extends StatefulWidget {
//   final Map<String, dynamic> data;

//   const PostItem({Key? key, required this.data}) : super(key: key);

//   @override
//   _PostItemState createState() => _PostItemState();
// }

// class _PostItemState extends State<PostItem> {
//   bool _isLiked = false;
//   int _likeCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _likeCount = widget.data['likes'] ?? 0;
//   }

//   void _toggleLike() {
//     setState(() {
//       if (_isLiked) {
//         _isLiked = false;
//         _likeCount--;
//       } else {
//         _isLiked = true;
//         _likeCount++;
//       }
//     });

//     // Update the like count in Firestore
//     FirebaseFirestore.instance
//         .collection('post')
//         .doc(widget.data['id'])
//         .update({'likes': _likeCount});
//   }

//   void _comment() {
//     TextEditingController _commentController =
//         TextEditingController(); // Controller for comment text field

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Comment'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('post')
//                     .doc(widget.data['id'])
//                     .collection('comments')
//                     .snapshots(),
//                 builder: (BuildContext context,
//                     AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   List<Comment> comments =
//                       snapshot.data!.docs.map((DocumentSnapshot document) {
//                     Map<String, dynamic> data =
//                         document.data()! as Map<String, dynamic>;
//                     return Comment(
//                       username: data['usernamecomment'],
//                       profileUrl: data['profileusercomment'],
//                       timestamp: data['timestamp'],
//                       commentText: data['commentText'],
//                     );
//                   }).toList();

//                   return ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: comments.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         leading: CircleAvatar(
//                             backgroundImage:
//                                 NetworkImage(comments[index].profileUrl)),
//                         title: Text(comments[index].username),
//                         subtitle: Text(comments[index].commentText),
//                       );
//                     },
//                   );
//                 },
//               ),
//               TextField(
//                 controller: _commentController,
//                 decoration: InputDecoration(hintText: 'Enter your comment'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Get the comment text from the text field
//                 String commentText = _commentController.text;

//                 if (commentText.isNotEmpty) {
//                   // Get current user's username and profile image URL
//                   String username = widget.data['usernamepost'];
//                   String profileUrl = widget.data['profileuserpost'];

//                   // Create a new comment document in Firestore
//                   await FirebaseFirestore.instance
//                       .collection('post')
//                       .doc(widget.data['id'])
//                       .collection('comments')
//                       .add({
//                     'usernamecomment': username,
//                     'profileusercomment': profileUrl,
//                     'timestamp': FieldValue.serverTimestamp(),
//                     'commentText': commentText,
//                   });

//                   Navigator.of(context).pop(); // Close the dialog
//                 }
//               },
//               child: Text('Submit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(width: 2, color: Colors.black),
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.5),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: Offset(0, 3), // changes position of shadow
//             ),
//           ],
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.all(10),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundImage: widget.data['profileuserpost'] != null
//                         ? NetworkImage(widget.data['profileuserpost'])
//                         : null,
//                     child: widget.data['profileuserpost'] == null
//                         ? Icon(Icons.person)
//                         : null,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(widget.data['usernamepost'] ?? 'Unknown User'),
//                 ],
//               ),
//               Text(
//                 widget.data['timestamp'] != null
//                     ? (widget.data['timestamp'] as Timestamp).toDate().toString()
//                     : '',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               widget.data['imageUrl'] != null
//                   ? Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.black, width: 2),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8.0),
//                           child: Image.network(
//                             widget.data['imageUrl'],
//                             width: double.infinity,
//                             height: 200,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                   )
//                   : SizedBox
//                       .shrink(), // Add this to conditionally show the image
//               Text(widget.data['textPost'] ?? ''),
//               SizedBox(height: 5),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     children: [
//                       IconButton(
//                         onPressed: _toggleLike,
//                         icon: Icon(
//                           _isLiked ? Icons.favorite : Icons.favorite_border,
//                           color: _isLiked ? Colors.red : null,
//                         ),
//                       ),
//                       Text("$_likeCount"),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       IconButton(
//                         onPressed: _comment,
//                         icon: Icon(Icons.chat),
//                       ),
//                       Text("Comment"),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // นำเข้า intl package
import 'package:user/dawer.dart';
import 'package:user/managepost.dart';

class Webbord extends StatefulWidget {
  final String userId;

  const Webbord({Key? key, required this.userId}) : super(key: key);

  @override
  State<Webbord> createState() => _WebbordState();
}

class _WebbordState extends State<Webbord> {
  String? _profile;
  String? _textPost;

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
          _profile = imageUrl ?? 'default_image_url'; // กำหนดค่าเริ่มต้นหาก imageUrl เป็น null
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
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        title: const Text(
          "กระทู้หานักเตะ",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),

        actions: [IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Managepost(userId: widget.userId),),);
        }, icon: Icon(Icons.notifications_on))],
      ),
      drawer: Dawer(userId: widget.userId),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage:
                      _profile != null ? NetworkImage(_profile!) : null,
                  child: _profile == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10, right: 5),
                  child: Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 15, right: 5),
                            child: TextField(
                              controller: _textPostController,
                              decoration: const InputDecoration(
                                hintText: "เขียนโพสที่นี่...",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              sandPost();
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                    children: snapshot.data!.docs
                        .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      data['id'] = document.id; // Adding the document ID
                      return PostItem(data: data, currentUserId: widget.userId);
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

  void sandPost() async {
    setState(() {
      _textPost = _textPostController.text;
    });

    if (_textPost != null && _textPost!.isNotEmpty) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userId)
            .get();

        if (userSnapshot.exists) {
          String username = userSnapshot.get('username') ?? 'Unknown User';
          String profileUrl = userSnapshot.get('image_url') ?? 'default_profile_url';

          await FirebaseFirestore.instance.collection('post').add({
            'textPost': _textPost,
            'usernamepost': username,
            'profileuserpost': profileUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': widget.userId, // Save the userId for ownership check
            'likes': 0, // Add a field for likes
          });

          // ล้างข้อความในช่องข้อความหลังจากโพสต์
          _textPostController.clear();
          setState(() {
            _textPost = null;
          });
        }
      } catch (e) {
        print("เกิดข้อผิดพลาดในการบันทึกโพสต์: $e");
      }
    }
  }
}

class PostItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final String currentUserId;

  const PostItem({Key? key, required this.data, required this.currentUserId}) : super(key: key);

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
          title: Text('แสดงความคิดเห็น'),
          content: SingleChildScrollView(
            child: Column(
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
                        username: data['usernamecomment'] ?? 'Unknown User',
                        profileUrl: data['profileusercomment'] ?? 'default_profile_url',
                        timestamp: data['timestamp'],
                        commentText: data['commentText'] ?? '',
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
                  decoration: InputDecoration(hintText: 'เขียนความคิดเห็นของคุณ'),
                ),
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
              onPressed: () {
                String commentText = _commentController.text;
                _addComment(commentText);
                Navigator.of(context).pop(); // Close the dialog after adding comment
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addComment(String commentText) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.currentUserId)
        .get();

    if (userSnapshot.exists) {
      String username = userSnapshot.get('username') ?? 'Unknown User';
      String profileUrl =
          userSnapshot.get('image_url') ?? 'default_profile_url';

      await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.data['id'])
          .collection('comments')
          .add({
        'commentText': commentText,
        'usernamecomment': username,
        'profileusercomment': profileUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {return Card(   //UI post
  child: Stack(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.data['profileuserpost'] != null
                  ? NetworkImage(widget.data['profileuserpost'])
                  : null,
              child: widget.data['profileuserpost'] == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
              radius: 20,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data['usernamepost'] ?? 'Unknown User',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.data['timestamp'] != null)
                  Text(
                    formatDate(widget.data['timestamp']),
                    style: TextStyle(color: Colors.grey[600],fontSize: 10),
                  ),
              ],
            ),
            subtitle: Text(
              widget.data['textPost'] ?? '',
              overflow: TextOverflow.ellipsis, // ป้องกัน Overflow
            ),
          ),
          if (widget.data['imageUrl'] != null && widget.data['imageUrl'] != '')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(
                widget.data['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$_likeCount'),
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: _comment,
                ),
              ],
            ),
          ),
        ],
      ),
      if (widget.currentUserId == widget.data['userId'])
        Positioned(
          bottom: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deletePost,
          ),
        ),
    ],
  ),
);

  }

  String formatDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formatter = DateFormat('dd/MM/yyyy hh:mm a'); // ปรับรูปแบบวันที่และเวลา
    return formatter.format(dateTime);
  }

  void _deletePost() async {
    try {
      await FirebaseFirestore.instance.collection('post').doc(widget.data['id']).delete();
      print("โพสต์ถูกลบเรียบร้อยแล้ว");
    } catch (e) {
      print("เกิดข้อผิดพลาดในการลบโพสต์: $e");
    }
  }
}

class Comment {
  final String username;
  final String profileUrl;
  final Timestamp timestamp;
  final String commentText;

  Comment({
    required this.username,
    required this.profileUrl,
    required this.timestamp,
    required this.commentText,
  });
}

