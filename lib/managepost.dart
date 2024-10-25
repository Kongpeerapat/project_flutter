import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับการฟอร์แมตวันที่

class Managepost extends StatefulWidget {
  final String userId; // เพิ่ม userId เป็นพารามิเตอร์
  

  const Managepost({Key? key, required this.userId}) : super(key: key);

  @override
  State<Managepost> createState() => _ManagepostState();
}

class _ManagepostState extends State<Managepost> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 2.0,
        backgroundColor: Colors.black,
        title: Text(
          "หน้าจัดการโพสต์",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('post')
            .where('userId', isEqualTo: widget.userId) // กรองโพสต์โดย userId
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                data['id'] = document.id; // เพิ่ม document ID
                return ManagePostItem(
                  data: data,
                  currentUserId: widget.userId,
                  scaffoldMessengerKey: scaffoldMessengerKey, // ส่ง GlobalKey
                );
              }).toList(),
            );
          } else {
            return Center(child: Text("คุณยังไม่มีโพสต์"));
          }
        },
      ),
    );
  }
}

class ManagePostItem extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey; // รับ GlobalKey
  final Map<String, dynamic> data;
  final String currentUserId;

  ManagePostItem({
    Key? key,
    required this.data,
    required this.currentUserId,
    required this.scaffoldMessengerKey, // รับ GlobalKey
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card( // UI สำหรับแต่ละโพสต์
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: data['profileuserpost'] != null
                  ? NetworkImage(data['profileuserpost'])
                  : null,
              child: data['profileuserpost'] == null
                  ? Icon(Icons.person, color: Colors.grey)
                  : null,
              radius: 20,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    data['usernamepost'] ?? 'Unknown User',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (data['timestamp'] != null)
                  Text(
                    formatDate(data['timestamp']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
              ],
            ),
            subtitle: Text(
              data['textPost'] ?? '',
              overflow: TextOverflow.ellipsis, // ป้องกัน Overflow
            ),
          ),
          if (data['imageUrl'] != null && data['imageUrl'] != '')
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(
                data['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _deletePost(context, data['id']);
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text(
                    'ลบโพสต์',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showCommentDialog(context, data['id']);
                  },
                  icon: Icon(Icons.comment, color: Colors.blue),
                  label: Text(
                    'คอมเมนต์',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          _buildCommentSection(data['id']), // เพิ่มการแสดงคอมเมนต์
        ],
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final formatter = DateFormat('dd/MM/yyyy hh:mm a'); // ปรับรูปแบบวันที่และเวลา
    return formatter.format(dateTime);
  }

  void _deletePost(BuildContext context, String postId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณต้องการลบโพสต์นี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // ไม่ลบ
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // ลบ
              },
              child: Text('ยืนยัน'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('post')
            .doc(postId)
            .delete();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('โพสต์ถูกลบเรียบร้อยแล้ว')),
        );
      } catch (e) {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการลบโพสต์: $e')),
        );
      }
    }
  }

  // ส่วนการแสดงคอมเมนต์
  Widget _buildCommentSection(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .doc(postId)
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("เกิดข้อผิดพลาดในการดึงคอมเมนต์: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Column(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> commentData =
                  doc.data()! as Map<String, dynamic>;

              // Check if fields are strings, otherwise provide fallback values
              String? profileImageUrl =
                  commentData['profileusercomment'] is String
                      ? commentData['profileusercomment']
                      : null;
              String username =
                  commentData['usernamecomment'] is String
                      ? commentData['usernamecomment']
                      : 'Unknown User';
              String commentText =
                  commentData['commentText'] is String
                      ? commentData['commentText']
                      : '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl == null
                      ? Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                title: Text(username),
                subtitle: Text(commentText),
              );
            }).toList(),
          );
        } else {
          return Center(child: Text("ยังไม่มีคอมเมนต์"));
        }
      },
    );
  }

  // ฟังก์ชันการแสดง dialog สำหรับเพิ่มคอมเมนต์
  void showCommentDialog(BuildContext context, String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("เพิ่มคอมเมนต์"),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: "พิมพ์คอมเมนต์ของคุณ",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () {
                _fetchUserInfoAndAddComment(postId, commentController.text);
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: Text("เพิ่ม"),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันเพิ่มคอมเมนต์
  Future<void> _fetchUserInfoAndAddComment(
      String postId, String commentText) async {
    // ดึงข้อมูลจากคอลเลคชัน user โดยใช้ currentUserId
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

      if (userData != null) {
        String? username = userData['username'] as String?;
        String? profileImageUrl = userData['image_url'] as String?;

        await _addComment(
          postId,
          commentText,
          username: username ?? 'Unknown User',
          profileImageUrl: profileImageUrl,
        );
      }
    }
  }

  // ฟังก์ชันเพิ่มคอมเมนต์เข้าฐานข้อมูล Firestore
  Future<void> _addComment(
    String postId,
    String commentText, {
    required String username,
    String? profileImageUrl,
  }) async {
    CollectionReference commentsRef = FirebaseFirestore.instance
        .collection('post')
        .doc(postId)
        .collection('comments');

    await commentsRef.add({
      'usernamecomment': username,
      'profileusercomment': profileImageUrl,
      'commentText': commentText,
      'timestamp': Timestamp.now(), // เก็บเวลาที่คอมเมนต์
    });
  }
}
