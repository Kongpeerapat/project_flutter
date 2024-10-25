
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:user/chat.dart';
// import 'package:user/dawer.dart';

// class Myteam extends StatefulWidget {
//   final String userId;
//   const Myteam({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Myteam> createState() => _MyteamState();
// }
// class _MyteamState extends State<Myteam> {
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
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // ตรวจสอบข้อมูลที่ส่งกลับมา
//     final bool? shouldRefresh = ModalRoute.of(context)?.settings.arguments as bool?;
//     if (shouldRefresh == true) {
//       _loadUserName(); // เรียกใช้ `_loadUserName` เพื่อลงข้อมูลใหม่
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         title: const Text(
//           "Myteam",
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
//               stream: FirebaseFirestore.instance.collection('team').snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var teams = snapshot.data!.docs;

//                 return SingleChildScrollView(
//                   child: Column(
//                     children: teams.map((teamDoc) {
//                       var teamId = teamDoc.id; // เก็บ teamId ในตัวแปร
//                       var team = teamDoc.data() as Map<String, dynamic>?; // เข้าถึงข้อมูลของแต่ละเอกสาร
//                       if (team == null) {
//                         return Container();
//                       }
//                       return StreamBuilder<QuerySnapshot>(
//                         stream: FirebaseFirestore.instance
//                             .collection('team')
//                             .doc(teamId) // ใช้ teamId แทนการใช้ teamDoc.id โดยตรง
//                             .collection('members')
//                             .where('namemember', isEqualTo: _userName)
//                             .snapshots(),
//                         builder: (context, membersSnapshot) {
//                           if (!membersSnapshot.hasData) {
//                             return const Center(child: CircularProgressIndicator());
//                           }

//                           var members = membersSnapshot.data!.docs;

//                           return members.isEmpty
//                               ? Container()
//                               : _buildTeamCard(
//                                   context,
//                                   team['teamname'],
//                                   'AdminTeam:${team['adminteam']}',
//                                   team['imageteam'],
//                                   team['quantityuserLimit'],
//                                   teamId, // ส่ง teamId เพื่อใช้ใน _buildTeamCard
//                                 );
//                         },
//                       );
//                     }).toList(),
//                   ),
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
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Chat(userId: widget.userId, teamId: teamId),
//                     ),
//                   ).then((value) {
//                     if (value == true) {
//                       setState(() {
//                         _loadUserName(); // รีเฟรชข้อมูลเมื่อกลับมาจากหน้าจอ Chat
//                       });
//                     }
//                   });
//                 },
//                 icon: const Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "chat",
//                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                     ),
//                     Icon(
//                       Icons.chat,
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
// }





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/chat.dart';
import 'package:user/dawer.dart';

class Myteam extends StatefulWidget {
  final String userId;
  const Myteam({Key? key, required this.userId}) : super(key: key);

  @override
  State<Myteam> createState() => _MyteamState();
}
class _MyteamState extends State<Myteam> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ตรวจสอบข้อมูลที่ส่งกลับมา
    final bool? shouldRefresh = ModalRoute.of(context)?.settings.arguments as bool?;
    if (shouldRefresh == true) {
      _loadUserName(); // เรียกใช้ `_loadUserName` เพื่อลงข้อมูลใหม่
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "ทีมของฉัน",
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
  stream: FirebaseFirestore.instance.collection('team').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    var teams = snapshot.data!.docs;

    return SingleChildScrollView(
      child: Column(
        children: teams.map((teamDoc) {
          var teamId = teamDoc.id;
          var team = teamDoc.data() as Map<String, dynamic>?;

          if (team == null) {
            return Container();
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('team')
                .doc(teamId)
                .collection('members')
                .where('namemember', isEqualTo: _userName)
                .snapshots(),
            builder: (context, membersSnapshot) {
              if (!membersSnapshot.hasData || membersSnapshot.data!.docs.isEmpty) {
                return Container(); // ไม่แสดงทีมนี้ถ้าไม่มีสมาชิกที่ตรงกับ username
              }

              return _buildTeamCard(
                context,
                team['teamname'],
                'ผู้ดูเเล:${team['adminteam']}',
                team['imageteam'],
                team['quantityuserLimit'],
                teamId,
              );
            },
          );
        }).toList(),
      ),
    );
  },
)

    );
  }

  Widget _buildTeamCard(BuildContext context, String teamName, String adminName, String imageUrl, String quantityuserLimit, String teamId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 400,
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
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        adminName,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 30,),
                      Text(
                        'รับได้อีก: $quantityuserLimit',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chat(userId: widget.userId, teamId: teamId),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        _loadUserName(); // รีเฟรชข้อมูลเมื่อกลับมาจากหน้าจอ Chat
                      });
                    }
                  });
                },
                icon: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "พูดคุย",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.chat,
                      color: Colors.black,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

