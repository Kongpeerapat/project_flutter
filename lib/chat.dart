import 'package:cloud_firestore/cloud_firestore.dart'; // นำเข้าแพ็คเกจ cloud_firestore สำหรับเชื่อมต่อกับ Firestore
import 'package:flutter/material.dart';// นำเข้าแพ็คเกจ flutter สำหรับสร้าง UI
import 'package:user/member_group.dart'; 


// สร้าง StatefulWidget ที่ชื่อว่า Chat
class Chat extends StatefulWidget {
  final String
      userId; // ประกาศตัวแปร userId ที่จะรับค่ามาจากการเรียกใช้งาน Chat widget
  final String
      teamId; // ประกาศตัวแปร teamId ที่จะรับค่ามาจากการเรียกใช้งาน Chat widget
  

  Chat({Key? key, required this.userId, required this.teamId})
      : super(key: key); // กำหนดค่าตัวแปร userId และ teamId จากค่าที่ถูกส่งมา

  @override
  State<Chat> createState() =>
      _ChatState(); // สร้าง state ที่จะใช้กับ Chat widget
}

// สร้าง State class สำหรับ Chat widget
class _ChatState extends State<Chat> {
  TextEditingController _messagesController = TextEditingController();
  ScrollController _scrollController = ScrollController(); // เพิ่ม ScrollController
  String? _profile;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _checkIfUserIsStillMember() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('team')
        .doc(widget.teamId)
        .collection('members')
        .where('namemember', isEqualTo: widget.userId)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have left the team and cannot access the chat.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _loadUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        String? imageUrl = snapshot.get('image_url');
        String? username = snapshot.get('username');

        setState(() {
          _profile = imageUrl;
          _userName = username;
        });
      } else {
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          _profile = null;
        });
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดข้อมูลผู้ใช้: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "แชทกลุ่ม",
          style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MemberGroup(teamId: widget.teamId,userId: widget.userId,)));
            },
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('team')
                  .doc(widget.teamId)
                  .collection('teamgroup')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                // เลื่อนไปที่ข้อความล่าสุดเมื่อข้อมูลเปลี่ยนแปลง
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController, // ใช้ ScrollController
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    var messageText = messageData['message'] ?? '';
                    var senderName = messageData['senderName'] ?? '';
                    var senderProfile = messageData['senderProfile'] ?? '';

                    return Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: senderName == _userName
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft,
                        child: Row(
                          mainAxisAlignment: senderName == _userName
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (senderName != _userName)
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(senderProfile),
                              ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: senderName == _userName
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(senderName),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(width: 2, color: Colors.black),
                                      ),
                                      child: Text(
                                        messageText,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (senderName == _userName)
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(_profile ?? ''),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 2, color: Colors.black),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _messagesController,
                        decoration: const InputDecoration(
                            hintText: "Write your message here...",
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 10),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.grey,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    if (_messagesController.text.isNotEmpty) {
      FirebaseFirestore.instance 
          .collection('team')
          .doc(widget.teamId)
          .collection('teamgroup')
          .add({
        'message': _messagesController.text,
        'senderName': _userName,
        'senderProfile': _profile,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messagesController.clear();

      // เลื่อนไปที่ข้อความล่าสุดหลังจากส่งข้อความ
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Chat extends StatefulWidget {
//   final String userId;
//   final String teamId;

//   const Chat({Key? key, required this.userId, required this.teamId}) : super(key: key);

//   @override
//   _ChatState createState() => _ChatState();
// }

// class _ChatState extends State<Chat> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
    
//   }


// Future<void> _checkIfUserIsStillMember() async {
//   var snapshot = await FirebaseFirestore.instance
//       .collection('team')
//       .doc(widget.teamId)
//       .collection('members')
//       .where('namemember', isEqualTo: widget.userId) // ใช้ 'namemember' แทน 'userId'
//       .get();

//   if (snapshot.docs.isEmpty) {
//     // ผู้ใช้ไม่ได้อยู่ในทีมแล้ว
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('You have left the team and cannot access the chat.')),
//     );
//     Navigator.pop(context);
//   }
// }



//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) {
//       return;
//     }

//     await FirebaseFirestore.instance
//         .collection('team')
//         .doc(widget.teamId)
//         .collection('messages')
//         .add({
//       'text': _messageController.text,
//       'senderId': widget.userId,
//       'timestamp': Timestamp.now(),
//     });

//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat"),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('team')
//                   .doc(widget.teamId)
//                   .collection('messages')
//                   .orderBy('timestamp')
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var messages = snapshot.data!.docs;

//                 return ListView.builder(
//                   controller: _scrollController,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     var messageData = messages[index].data() as Map<String, dynamic>;
//                     var message = messageData['text'] ?? '';
//                     var senderId = messageData['senderId'] ?? '';
//                     var isCurrentUser = senderId == widget.userId;

//                     return Container(
//                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: isCurrentUser ? Colors.blue : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           message,
//                           style: TextStyle(
//                             color: isCurrentUser ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
