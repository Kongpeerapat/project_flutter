import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/jointeam.dart';

class MemberGroup extends StatefulWidget {
  final String teamId;
  final String userId;

  const MemberGroup({required this.teamId, required this.userId});

  @override
  _MemberGroupState createState() => _MemberGroupState();
}

class _MemberGroupState extends State<MemberGroup> {
  String? userId;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    userId = widget.userId;
    if (userId != null) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'User ID not found in storage.';
      });
    }
  }

  Future<void> _exitTeam() async {
    if (userId != null) {
      try {
        var memberQuery = await FirebaseFirestore.instance
            .collection('team')
            .doc(widget.teamId)
            .collection('members')
            .where('usermemberId', isEqualTo: userId)
            .get();

        if (memberQuery.docs.isNotEmpty) {
          await memberQuery.docs.first.reference.delete();
          print('Member removed from team');

          var waitingQuery = await FirebaseFirestore.instance
              .collection('Waiting join team')
              .where('usermemberId', isEqualTo: userId)
              .where('teamId', isEqualTo: widget.teamId)
              .get();
          for (var doc in waitingQuery.docs) {
            await doc.reference.delete();
          }
          print('Member removed from waiting list');

          var teamgroupQuery = await FirebaseFirestore.instance
              .collection('teamgroup')
              .where('teamId', isEqualTo: widget.teamId)
              .where('userId', isEqualTo: userId)
              .get();
          for (var doc in teamgroupQuery.docs) {
            await doc.reference.delete();
          }
          print('Member removed from teamgroup');

          await _updateUserLimit();
          setState(() {});

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Jointeam(userId: widget.userId),
            ),
          );
        } else {
          print('Member document does not exist');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('User ID not found in storage.');
    }
  }

  Future<void> _updateUserLimit() async {
    try {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamId)
          .get();

      if (teamDoc.exists) {
        int userLimit = int.parse(teamDoc['quantityuserLimit']);
        userLimit += 1;

        await FirebaseFirestore.instance
            .collection('team')
            .doc(widget.teamId)
            .update({
          'quantityuserLimit': userLimit.toString(),
        });
        print("User limit updated successfully");
      } else {
        print("Team document does not exist");
      }
    } catch (e) {
      print("Error updating user limit: $e");
    }
  }

  Future<void> _showExitConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากทีม'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากทีม?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () {
                Navigator.of(context).pop(); // ปิด Dialog
                _exitTeam(); // เรียกฟังก์ชันออกจากทีม
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshMembers() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            "สมาชิกในกลุ่ม",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _showExitConfirmationDialog(); // เรียก Dialog ยืนยันการออกจากทีม
            },
            icon: const Icon(Icons.logout),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "สมาชิกในกลุ่ม",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMembers,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('team')
              .doc(widget.teamId)
              .collection('members')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading members'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No members found'));
            }

            var members = snapshot.data!.docs;

            return ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  var memberData =
                      members[index].data() as Map<String, dynamic>;
                  var userName = memberData['namemember'] ?? 'Unknown';
                  var profileImage = memberData['memberProfile'] ?? '';
                  var isMember = memberData['status_addminteam'] ?? false;

                  return Container(
                    width: 380,
                    height: 80,
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 214, 214, 214),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.black),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircleAvatar(
                            backgroundImage: profileImage.isNotEmpty
                                ? NetworkImage(profileImage)
                                : null,
                            backgroundColor: Colors.grey,
                            radius: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMember ? "สมาชิก" : "ผู้ดูเเลทีม",
                              style: TextStyle(
                                fontSize: 16,
                                color: isMember ? Colors.black : Colors.blue,
                                fontWeight: isMember
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
