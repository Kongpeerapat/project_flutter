import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/booking.dart';
import 'package:user/booking_history.dart';
import 'package:user/createtaem.dart';
import 'package:user/jointeam.dart';
import 'package:user/login.dart';
import 'package:user/mycreate_team.dart';

import 'package:user/myteam.dart';
import 'package:user/webbord.dart';

class Dawer extends StatefulWidget {
  final String userId; // Add this line

  const Dawer({Key? key, required this.userId})
      : super(key: key); // Add required userId

  @override
  State<Dawer> createState() => _DawerState();
}

class _DawerState extends State<Dawer> {
  String? _uploadedImage; // เก็บ URL ของรูปภาพที่อัปโหลด
  String? _userName; // เก็บชื่อผู้ใช้
  String? _Email; // เก็บอีเมลของผู้ใช้

  @override
  void initState() {
    super.initState();
    _loadImage(); // เมื่อสร้างสถานะ State นี้ ให้โหลดข้อมูลรูปภาพ
  }

  // ฟังก์ชันเพื่อโหลดรูปภาพและข้อมูลผู้ใช้
  Future<void> _loadImage() async {
    try {
      // ดึงข้อมูลผู้ใช้จาก Cloud Firestore โดยใช้ ID ผู้ใช้ (widget.userId)
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget
              .userId) // ใช้ widget.userId เพื่อดึง ID ผู้ใช้จากพารามิเตอร์
          .get();

      // ตรวจสอบว่าข้อมูลมีอยู่หรือไม่
      if (snapshot.exists) {
        // หากมีข้อมูล ดึง URL ของรูปภาพ ชื่อผู้ใช้ และอีเมลออกมา
        String? imageUrl = snapshot.get('image_url'); // ดึง URL ของรูปภาพ
        String? userName = snapshot.get('username'); // ดึงชื่อผู้ใช้
        String? Email = snapshot.get('email'); // ดึงอีเมล

        // ตั้งค่าข้อมูลใหม่และแสดงผลในหน้า UI ด้วย setState
        setState(() {
          _uploadedImage = imageUrl; // กำหนด URL ของรูปภาพ
          _userName = userName; // กำหนดชื่อผู้ใช้
          _Email = Email; // กำหนดอีเมล
        });
      } else {
        // หากไม่มีข้อมูล ให้กำหนดค่าเป็น null และแสดงข้อความว่าเอกสารไม่มีอยู่จริง
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          _uploadedImage = null; // กำหนดรูปภาพเป็น null
          _userName = null; // กำหนดชื่อผู้ใช้เป็น null
          _Email = null; // กำหนดอีเมลเป็น null
        });
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่เกิดขึ้นในการโหลดภาพหรือข้อมูลผู้ใช้
      print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate the user to the login screen or any other appropriate screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(), // Navigate to the login screen
        ),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 85, 85, 85),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: ClipOval(
                      child: _uploadedImage != null
                          ? Image.network(_uploadedImage!, fit: BoxFit.cover)
                          : const Icon(Icons.add_photo_alternate_rounded,
                              size: 50, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30, left: 10),
                      child: Text(
                        _userName ??
                            '', // แสดงชื่อผู้ใช้หากมีอยู่ ไม่งั้นแสดงสตริงว่าง
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 1),
                      child: Text(
                        _Email ?? '',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.stadium,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "จองสนาม",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Booking(userId: widget.userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_document,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "กระทู้หานักเตะ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Webbord(userId: widget.userId),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.chat,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "ทีมของฉัน ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Myteam(userId: widget.userId),
                ),
              );
            },
          ), ListTile(
            leading: const Icon(
              Icons.cruelty_free_rounded,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "ทีมที่ฉันสร้าง",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Mycreate_team(userId: widget.userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.group_add,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "สร้างทีม",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Createteam(userId: widget.userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.group,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "เข้าร่วมทีม",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Jointeam(userId: widget.userId, ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.history,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "ประวัติการจอง",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingHistory(userId: widget.userId),
                ),
              );
            },
          ),
           
      
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 20,
            ),
            title: const Text(
              "ออกจากระบบ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              _logout(); // Call logout function
            },
          ),
        ],
      ),
    );
  }
}
