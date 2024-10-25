



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Adminconfirem extends StatefulWidget {
  const Adminconfirem({Key? key}) : super(key: key);

  @override
  State<Adminconfirem> createState() => _AdminconfiremState();
}

class _AdminconfiremState extends State<Adminconfirem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "ยืนยันการขอเข้าร่วมทีม",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Waiting join team').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var confirmationList = snapshot.data!.docs;
          return SingleChildScrollView(
            child: Column(
              children: confirmationList.map((confirmation) {
                // ตรวจสอบว่า confirmation.data() ไม่เป็น null
                final data = confirmation.data() as Map<String, dynamic>?;

                // ใช้ defaultValues ถ้าฟิลด์ไม่มี
                final teamId = data?.containsKey('teamId') == true ? data!['teamId'] : 'ไม่ระบุ';
                final memberProfile = data?.containsKey('memberProfile') == true ? data!['memberProfile'] : '';
                final memberName = data?.containsKey('namemember') == true ? data!['namemember'] : 'ไม่ระบุ';
                final usermemberId = data?.containsKey('usermemberId') == true ? data!['usermemberId'] : 'ไม่ระบุ';
                
                return _buildConfirmationCard(
                  context,
                  teamId,
                  memberProfile,
                  memberName,
                  usermemberId,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConfirmationCard(BuildContext context, String teamId, String memberProfile, String memberName, String usermemberId) {
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
                backgroundImage: NetworkImage(memberProfile),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    'ชื่อ: $memberName',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  _confirmMember(teamId, memberName, memberProfile, usermemberId);
                },
                icon: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ยืนยัน",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.check,
                      color: Colors.green,
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
Future<void> _confirmMember(String teamId, String memberName, String memberProfile, String usermemberId) async {
  try {
    // ลบสมาชิกจากรายการรอยืนยันและรับข้อมูลของสมาชิก
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Waiting join team')
        .where('teamId', isEqualTo: teamId)
        .where('namemember', isEqualTo: memberName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบสมาชิกในรายการรอยืนยัน!')),
        );
      }
      return;
    }

    DocumentSnapshot doc = querySnapshot.docs.first;
    String memberProfileData = doc.get('memberProfile');
    String memberNameData = doc.get('namemember');
    String usermemberIdData = doc.get('usermemberId'); // ดึงข้อมูล usermemberId

    if (usermemberIdData == null || usermemberIdData.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบ usermemberId!')),
        );
      }
      return;
    }

    // ลบสมาชิกจากรายการรอยืนยัน
    await doc.reference.delete();

    // อัปเดตข้อมูลทีมและเพิ่มสมาชิกในคอลเลกชัน 'members'
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference teamRef = FirebaseFirestore.instance.collection('team').doc(teamId);

      DocumentSnapshot teamSnapshot = await transaction.get(teamRef);
      if (teamSnapshot.exists) {
        String userLimitString = teamSnapshot.get('quantityuserLimit');
        int userLimit = int.parse(userLimitString);

        if (userLimit > 0) {
          await transaction.update(teamRef, {
            'quantityuserLimit': (userLimit - 1).toString(),
          });

          // เพิ่มสมาชิกในคอลเลกชัน 'members'
          await teamRef.collection('members').add({
            'memberProfile': memberProfileData,
            'namemember': memberNameData,
            'usermemberId': usermemberIdData,
            'status_addminteam': true,
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('สมาชิกได้รับการยืนยันและเพิ่มในทีมแล้ว!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ทีมเต็มแล้ว!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบทีม!')),
          );
        }
      }
    });
  } catch (e) {
    print("Error confirming member: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการยืนยันสมาชิก: $e')),
      );
    }
  }
}

}
