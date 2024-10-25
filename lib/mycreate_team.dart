// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:user/admingroup.dart';
// import 'package:user/chat.dart';
// import 'package:user/dawer.dart';

// class Mycreate_team extends StatefulWidget {
//   final String userId;
//   const Mycreate_team({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Mycreate_team> createState() => _Mycreate_teamState();
// }

// class _Mycreate_teamState extends State<Mycreate_team> {
//   String? _userName;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserName();
//   }

//   Future<void> _loadUserName() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(widget.userId)
//           .get();

//       if (snapshot.exists) {
//         setState(() {
//           _userName = snapshot.get('username');
//         });
//       } else {
//         print("เอกสารไม่มีอยู่จริง");
//       }
//     } catch (e) {
//       print("เกิดข้อผิดพลาดในการโหลดชื่อผู้ใช้: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           "Mycreateteam",
//           style: TextStyle(fontSize: 30, color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       drawer: Dawer(
//         userId: widget.userId,
//       ),
//       body: _userName == null
//           ? const Center(child: CircularProgressIndicator())
//           : StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('team')
//                   .where('adminteam', isEqualTo: _userName) // แสดงเฉพาะทีมที่ผู้ใช้เป็นแอดมิน
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var teams = snapshot.data!.docs;

//                 return ListView.builder(
//                   itemCount: teams.length,
//                   itemBuilder: (context, index) {
//                     var team = teams[index].data() as Map<String, dynamic>;
//                     var teamId = teams[index].id;

//                     return _buildTeamCard(
//                       context,
//                       team['teamname'],
//                       'AdminTeam: ${team['adminteam']}',
//                       team['imageteam'],
//                       team['quantityuserLimit'],
//                       teamId,
//                     );
//                   },
//                 );
//               },
//             ),
//     );
//   }

//   Widget _buildTeamCard(BuildContext context, String teamName, String adminName, String imageUrl, String quantityuserLimit, String teamId) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 400,
//         height: 120,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.black),
//         ),
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
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => Admingroup(userId: widget.userId, teamId: teamId)));
//                 },
//                 icon: const Row(
//                   children: [
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Manage",
//                           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                         ),
//                         Icon(
//                           Icons.manage_accounts,
//                           color: Colors.black,
//                           size: 30,
//                         ),
                       
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 10),
//               child: IconButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(userId: widget.userId, teamId: teamId)));
//                 },
//                 icon: const Row(
//                   children: [
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "chat",
//                           style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                         ),
//                         Icon(
//                           Icons.chat,
//                           color: Colors.black,
//                           size: 30,
//                         ),
                       
//                       ],
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
// }












import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/admingroup.dart';
import 'package:user/chat.dart';
import 'package:user/dawer.dart';

class Mycreate_team extends StatefulWidget {
  final String userId;
  const Mycreate_team({Key? key, required this.userId}) : super(key: key);

  @override
  State<Mycreate_team> createState() => _Mycreate_teamState();
}

class _Mycreate_teamState extends State<Mycreate_team> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        setState(() {
          _userName = snapshot.get('username');
        });
      } else {
        print("เอกสารไม่มีอยู่จริง");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดชื่อผู้ใช้: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "ทีมที่ฉันสร้าง",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Dawer(
        userId: widget.userId,
      ),
      body: _userName == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('team')
                  .where('adminteam', isEqualTo: _userName) // แสดงเฉพาะทีมที่ผู้ใช้เป็นแอดมิน
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var teams = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    var team = teams[index].data() as Map<String, dynamic>;
                    var teamId = teams[index].id;

                    return _buildTeamCard(
                      context,
                      team['teamname'],
                      'ผู้ดูเเล: ${team['adminteam']}',
                      team['imageteam'],
                      team['quantityuserLimit'],
                      teamId,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildTeamCard(BuildContext context, String teamName, String adminName, String imageUrl, String? quantityuserLimit, String teamId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.grey[200], // Background color if image fails to load
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // ป้องกัน Overflow
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          adminName,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis, // ป้องกัน Overflow
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'รับได้อีก: ${quantityuserLimit ?? 'N/A'}',
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis, // ป้องกัน Overflow
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Admingroup(userId: widget.userId, teamId: teamId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.manage_accounts, size: 30),
                  ),
                  const Text(
                    "จัดการ",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(userId: widget.userId, teamId: teamId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat, size: 30),
                  ),
                  const Text(
                    "พูดคุย",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
