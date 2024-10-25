// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:user/dawer.dart';
// import 'package:user/myteam.dart';  // Import Myteam class

// class Jointeam extends StatefulWidget {
//   final String userId;
//   const Jointeam({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Jointeam> createState() => _JointeamState();
// }

// class _JointeamState extends State<Jointeam> {
//   String? _uploadedImage; // เก็บ URL ของรูปภาพที่อัปโหลด
//   String? _userName; // เก็บชื่อผู้ใช้

//   Future<void> _loadImage() async {
//     try {
//       // ดึงข้อมูลผู้ใช้จาก Cloud Firestore โดยใช้ ID ผู้ใช้ (widget.userId)
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(widget.userId) // ใช้ widget.userId เพื่อดึง ID ผู้ใช้จากพารามิเตอร์
//           .get();

//       // ตรวจสอบว่าข้อมูลมีอยู่หรือไม่
//       if (snapshot.exists) {
//         // หากมีข้อมูล ดึง URL ของรูปภาพ ชื่อผู้ใช้ และอีเมลออกมา
//         String? imageUrl = snapshot.get('image_url'); // ดึง URL ของรูปภาพ
//         String? userName = snapshot.get('username'); // ดึงชื่อผู้ใช้

//         // ตั้งค่าข้อมูลใหม่และแสดงผลในหน้า UI ด้วย setState
//         setState(() {
//           _uploadedImage = imageUrl; // กำหนด URL ของรูปภาพ
//           _userName = userName; // กำหนดชื่อผู้ใช้
//         });
//       } else {
//         // หากไม่มีข้อมูล ให้กำหนดค่าเป็น null และแสดงข้อความว่าเอกสารไม่มีอยู่จริง
//         print("เอกสารไม่มีอยู่จริง");
//         setState(() {
//           _uploadedImage = null; // กำหนดรูปภาพเป็น null
//           _userName = null; // กำหนดชื่อผู้ใช้เป็น null
//         });
//       }
//     } catch (e) {
//       // จัดการข้อผิดพลาดที่เกิดขึ้นในการโหลดภาพหรือข้อมูลผู้ใช้
//       print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           "Jointeam",
//           style: TextStyle(fontSize: 30, color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       drawer: Dawer(
//         userId: widget.userId,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('team').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           var teams = snapshot.data!.docs;

//           return SingleChildScrollView(
//             child: Column(
//               children: teams.map((team) {
//                 return _buildTeamCard(
//                   context,
//                   team['teamname'],
//                   'AdminTeam:${team['adminteam']}',
//                   team['imageteam'],
//                   team['quantityuserLimit'],
//                   team.id // Add document ID for future reference
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTeamCard(
//       BuildContext context, String teamName, String adminName, String imageUrl, String quantityuserLimit, String teamId) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 400,
//         height: 120,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.black)),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 5),
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundImage: NetworkImage(imageUrl),
//               ),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     teamName,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         adminName,
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                       const SizedBox(width: 30,),
//                       Text(
//                         'Limit: $quantityuserLimit',
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: IconButton(
//                 onPressed: () {
//                   int userLimit = int.parse(quantityuserLimit);
//                   if (userLimit > 0) {
//                     join_team(teamId, userLimit);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('ทีมเต็ม')),
//                     );
//                   }
//                 },
//                 icon: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Join",
//                       style: TextStyle(
//                           fontSize: 10, fontWeight: FontWeight.bold),
//                     ),
//                     Icon(
//                       Icons.login_rounded,
//                       color: Colors.black,
//                       size: 30,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> join_team(String teamId, int userLimit) async {
//     try {
//       // ตรวจสอบว่าผู้ใช้มีข้อมูลอยู่ใน members หรือไม่
//       QuerySnapshot userInMembers = await FirebaseFirestore.instance
//           .collection('team')
//           .doc(teamId)
//           .collection('members')
//           .where('namemember', isEqualTo: _userName)
//           .get();

//       if (userInMembers.docs.isNotEmpty) {
//         // หากผู้ใช้มีข้อมูลอยู่แล้ว แสดงข้อความแจ้งเตือน
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('คุณอยู่ในทีมแล้ว')),
//         );
//       } else {
//         // ลดค่า quantityuserLimit ลง 1 ในคอลเลกชัน team
//         await FirebaseFirestore.instance.collection('team').doc(teamId).update({
//           'quantityuserLimit': (userLimit - 1).toString(),
//         });

//         // สร้างเอกสารใหม่ในคอลเลกชันย่อย members ภายใต้คอลเลกชัน team
//         await FirebaseFirestore.instance.collection('team').doc(teamId).collection('members').add({
//           'memberProfile': _uploadedImage,
//           'namemember': _userName,
//           'status_addminteam': true,
//           'timestamp': FieldValue.serverTimestamp(),
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('เข้าร่วมทีมสำเร็จ')),
//         );

//         // Navigate to Myteam page
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Myteam(userId: widget.userId)),
//         );
//       }
//     } catch (e) {
//       print("เกิดข้อผิดพลาดในการเข้าร่วมทีม: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('เกิดข้อผิดพลาดในการเข้าร่วมทีม: $e')),
//       );
//     }
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:user/dawer.dart';
// import 'package:user/myteam.dart';  // Import Myteam class

// class Jointeam extends StatefulWidget {
//   final String userId;
//   const Jointeam({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Jointeam> createState() => _JointeamState();
// }

// class _JointeamState extends State<Jointeam> {
//   String? _uploadedImage; // เก็บ URL ของรูปภาพที่อัปโหลด
//   String? _userName; // เก็บชื่อผู้ใช้

//   @override
//   void initState() {
//     super.initState();
//     _loadImage();
//   }

//   Future<void> _loadImage() async {
//     try {
//       // ดึงข้อมูลผู้ใช้จาก Cloud Firestore โดยใช้ ID ผู้ใช้ (widget.userId)
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(widget.userId) // ใช้ widget.userId เพื่อดึง ID ผู้ใช้จากพารามิเตอร์
//           .get();

//       // ตรวจสอบว่าข้อมูลมีอยู่หรือไม่
//       if (snapshot.exists) {
//         // หากมีข้อมูล ดึง URL ของรูปภาพ ชื่อผู้ใช้ และอีเมลออกมา
//         String? imageUrl = snapshot.get('image_url'); // ดึง URL ของรูปภาพ
//         String? userName = snapshot.get('username'); // ดึงชื่อผู้ใช้

//         // ตั้งค่าข้อมูลใหม่และแสดงผลในหน้า UI ด้วย setState
//         setState(() {
//           _uploadedImage = imageUrl; // กำหนด URL ของรูปภาพ
//           _userName = userName; // กำหนดชื่อผู้ใช้
//         });
//       } else {
//         // หากไม่มีข้อมูล ให้กำหนดค่าเป็น null และแสดงข้อความว่าเอกสารไม่มีอยู่จริง
//         print("เอกสารไม่มีอยู่จริง");
//         setState(() {
//           _uploadedImage = null; // กำหนดรูปภาพเป็น null
//           _userName = null; // กำหนดชื่อผู้ใช้เป็น null
//         });
//       }
//     } catch (e) {
//       // จัดการข้อผิดพลาดที่เกิดขึ้นในการโหลดภาพหรือข้อมูลผู้ใช้
//       print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           "เข้าร่วมทีม",
//           style: TextStyle(fontSize: 30, color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       drawer: Dawer(
//         userId: widget.userId,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('team').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           var teams = snapshot.data!.docs;

//           return SingleChildScrollView(
//             child: Column(
//               children: teams.map((team) {
//                 return _buildTeamCard(
//                   context,
//                   team['teamname'],
//                   'ผู้ดูเเล:${team['adminteam']}',
//                   team['imageteam'],
//                   team['quantityuserLimit'],
//                   team.id // Add document ID for future reference
//                 );
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTeamCard(
//       BuildContext context, String teamName, String adminName, String imageUrl, String quantityuserLimit, String teamId) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 400,
//         height: 120,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.black)),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 5),
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundImage: NetworkImage(imageUrl),
//               ),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     teamName,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         adminName,
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                       const SizedBox(width: 30,),
//                       Text(
//                         'รับได้อีก:$quantityuserLimit',
//                         style: const TextStyle(
//                           fontSize: 10,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: IconButton(
//                 onPressed: () {
//                   int userLimit = int.parse(quantityuserLimit);
//                   if (userLimit > 0) {
//                     join_team(teamId, userLimit);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('ทีมเต็ม')),
//                     );
//                   }
//                 },
//                 icon: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "เข้าร่วม",
//                       style: TextStyle(
//                           fontSize: 10, fontWeight: FontWeight.bold),
//                     ),
//                     Icon(
//                       Icons.login_rounded,
//                       color: Colors.black,
//                       size: 30,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> join_team(String teamId, int userLimit) async {
//     try {
//       // Check if user is already in the team
//       QuerySnapshot userInTeam = await FirebaseFirestore.instance
//           .collection('team')
//           .doc(teamId)
//           .collection('members')
//           .where('namemember', isEqualTo: _userName)
//           .get();

//       if (userInTeam.docs.isNotEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You are already in the team.')),
//         );
//       } else {
//         // Check if user is already in the waiting list
//         QuerySnapshot userInWaiting = await FirebaseFirestore.instance
//             .collection('Waiting join team') // Updated collection name
//             .where('teamId', isEqualTo: teamId)
//             .where('namemember', isEqualTo: _userName)
//             .get();

//         if (userInWaiting.docs.isNotEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('You are already in the waiting list.')),
//           );
//         } else {
//           // Add user to the waiting list
//           await FirebaseFirestore.instance.collection('Waiting join team').add({
//             'teamId': teamId,
//             'memberProfile': _uploadedImage,
//             'namemember': _userName,
//             'status_addminteam': false,
//             'timestamp': FieldValue.serverTimestamp(),
//           });

//           // Show a dialog informing the user that they have successfully joined the waiting list
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Joined Waiting List'),
//                 content: const Text('Your request to join the team has been submitted. Please wait for confirmation.'),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('OK'),
//                   ),
//                 ],
//               );
//             },
//           );

//           // Navigate to Myteam page
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Myteam(userId: widget.userId)),
//           );
//         }
//       }
//     } catch (e) {
//       print("Error joining team: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error joining team: $e')),
//       );
//     }
//   }
// }








import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/dawer.dart';
import 'package:user/myteam.dart';  // นำเข้าคลาส Myteam

class Jointeam extends StatefulWidget {
  final String userId;
  const Jointeam({Key? key, required this.userId}) : super(key: key);

  @override
  State<Jointeam> createState() => _JointeamState();
}

class _JointeamState extends State<Jointeam> {
  String? _uploadedImage; // ใช้เก็บ URL ของรูปภาพที่อัปโหลด
  String? _userName; // ใช้เก็บชื่อผู้ใช้

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // ดึงข้อมูลผู้ใช้จาก Cloud Firestore โดยใช้ ID ผู้ใช้ (widget.userId)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId) // ใช้ widget.userId เพื่อดึง ID ผู้ใช้จากพารามิเตอร์
          .get();

      // ตรวจสอบว่าข้อมูลมีอยู่หรือไม่
      if (snapshot.exists) {
        // หากมีข้อมูล ดึง URL ของรูปภาพ ชื่อผู้ใช้ และอีเมลออกมา
        String? imageUrl = snapshot.get('image_url'); // ดึง URL ของรูปภาพ
        String? userName = snapshot.get('username'); // ดึงชื่อผู้ใช้

        // ตั้งค่าข้อมูลใหม่และแสดงผลในหน้า UI ด้วย setState
        setState(() {
          _uploadedImage = imageUrl; // กำหนด URL ของรูปภาพ
          _userName = userName; // กำหนดชื่อผู้ใช้
        });
      } else {
        // หากไม่มีข้อมูล ให้กำหนดค่าเป็น null และแสดงข้อความว่าเอกสารไม่มีอยู่จริง
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          _uploadedImage = null; // กำหนดรูปภาพเป็น null
          _userName = null; // กำหนดชื่อผู้ใช้เป็น null
        });
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นในการโหลดภาพหรือข้อมูลผู้ใช้
      print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsIconTheme: IconThemeData(color: Colors.white),
        title: const Text("เข้าร่วมทีม",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      drawer: Dawer(
        userId: widget.userId,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('team').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var teams = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: teams.map((team) {
                return _buildTeamCard(
                  context,
                  team['teamname'],
                  'ผู้ดูแล: ${team['adminteam']}',
                  team['imageteam'],
                  team['quantityuserLimit'],
                  team.id
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(
      BuildContext context, String teamName, String adminName, String imageUrl, String quantityuserLimit, String teamId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(teamName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(adminName, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 30),
                      Text('รับได้อีก: $quantityuserLimit', style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  int userLimit = int.parse(quantityuserLimit);
                  if (userLimit > 0) {
                    join_team(teamId, userLimit);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ทีมเต็ม')));
                  }
                },
                icon: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("เข้าร่วม", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Icon(Icons.login_rounded, color: Colors.black, size: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> join_team(String teamId, int userLimit) async {
    try {
      // ตรวจสอบว่าผู้ใช้มีอยู่ในทีมแล้วหรือไม่
      QuerySnapshot userInTeam = await FirebaseFirestore.instance
          .collection('team')
          .doc(teamId)
          .collection('members')
          .where('namemember', isEqualTo: _userName)
          .get();

      if (userInTeam.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('คุณอยู่ในทีมแล้ว')));
      } else {
        // ตรวจสอบว่าผู้ใช้มีอยู่ในรายการรอหรือไม่
        QuerySnapshot userInWaiting = await FirebaseFirestore.instance
            .collection('Waiting join team') // ชื่อคอลเลกชันที่อัปเดตแล้ว
            .where('teamId', isEqualTo: teamId)
            .where('namemember', isEqualTo: _userName)
            .get();

        if (userInWaiting.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('คุณอยู่ในรายการรอแล้ว')));
        } else {
          // เพิ่มผู้ใช้ลงในรายการรอ
          await FirebaseFirestore.instance.collection('Waiting join team').add({
            'teamId': teamId,
            'usermemberId': widget.userId, // ใช้ userId จาก widget
            'memberProfile': _uploadedImage,
            'namemember': _userName,
            'status_addminteam': false,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // แสดงกล่องโต้ตอบที่แจ้งผู้ใช้ว่าพวกเขาได้เข้าร่วมรายการรอแล้ว
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('เข้าร่วมรายการรอ'),
                content: const Text('คำขอเข้าร่วมทีมของคุณได้ถูกส่งแล้ว กรุณารอการยืนยัน'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('ตกลง'),
                  ),
                ],
              );
            },
          );

          // เปลี่ยนไปที่หน้าของ Myteam
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Myteam(userId: widget.userId)),
          );
        }
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการเข้าร่วมทีม: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการเข้าร่วมทีม: $e')));
    }
  }
}
