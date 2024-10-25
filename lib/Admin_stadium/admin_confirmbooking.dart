import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // สำหรับใช้กับ DateFormat

class Confirmbooking extends StatefulWidget {
  const Confirmbooking({Key? key}) : super(key: key);

  @override
  State<Confirmbooking> createState() => _ConfirmbookingState();
}
class _ConfirmbookingState extends State<Confirmbooking> {
  // ดึงข้อมูลของผู้ใช้ที่ล็อกอินอยู่
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      // ถ้าไม่มีผู้ใช้ล็อกอิน ให้แสดงข้อความ
      return Scaffold(
        appBar: AppBar(
          title: const Text('ยืนยันการจอง'),
        ),
        body: const Center(
          child: Text('กรุณาล็อกอินเพื่อดูข้อมูลการจองของคุณ'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange[800],
        title: const Text(
          'ยืนยันการจอง',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Waiting for confirmation')
                .where('adminId', isEqualTo: currentUser!.uid) // กรองข้อมูลตาม userId ของผู้ใช้ที่ล็อกอิน
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No bookings to confirm.'));
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  // Handling null and type check for bookingDate
                  var bookingDate = data['bookingDate'] != null &&
                          data['bookingDate'] is Timestamp
                      ? (data['bookingDate'] as Timestamp).toDate()
                      : DateTime.now(); // Use current date or another default

                  return Container(
                    width: 400,
                    height: 350,
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromARGB(255, 240, 240, 240),
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(data['profileImage'] ?? ''),
                                  radius: 25,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  data['userName'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                data['stadiumImageUrl'] ?? '',
                                width:
                                    MediaQuery.of(context).size.width * 0.5,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                data['proofpayment'] ?? '',
                                width:
                                    MediaQuery.of(context).size.width * 0.5,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['stadiumName'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    "สถานะการจอง: ",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    data['bookingStatus'] ?? 'Unknown',
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: data['bookingStatus'] ==
                                                'Confirmed'
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    "ราคา: ",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    "${data['price'] ?? 'N/A'}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "เวลาเปิด : ${data['openingTime']}",
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "เวลาปิด : ${data['closingTime']}",
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Text(
                                    "วันที่จอง: ",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    "${bookingDate.day}/${bookingDate.month}/${bookingDate.year}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "ข้อมูลติดต่อ : ${data['contact']}",
                                      style: const TextStyle(fontSize: 10),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('ยืนยัน'),
                                        content: const Text(
                                            'คุณเเน่ใจในการยืนยันการจองครั้งนี้ใช่ไหม'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context); // Close dialog without confirming
                                            },
                                            child: const Text('ยกเลิก'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              confirm(doc.id, data);
                                              Navigator.pop(
                                                  context); // Close dialog after confirming
                                            },
                                            child: const Text('ยืนยัน'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "ยืนยันการจอง", //ปุ่มยืนยัน
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(doc.id);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "ยกเลิกการจอง",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
     );
  },
          ))
      ),
    );
  }
void confirm(String docId, Map<String, dynamic> data) async {
  try {
    // อัพเดตสถานะการจอง
    await FirebaseFirestore.instance
        .collection('Waiting for confirmation')
        .doc(docId)
        .update({
      'bookingStatus': 'Confirmed',
      'date': FieldValue.serverTimestamp(), // เพิ่มฟิลด์ date ที่เป็น timestamp ปัจจุบัน
    });

    // รับข้อมูลวัน, เดือน และปีปัจจุบัน
    String day = DateFormat('EEE').format(DateTime.now()); // เช่น 'Mon'
    String month = DateFormat('MMMM').format(DateTime.now()); // เช่น 'July'
    String year = DateFormat('yyyy').format(DateTime.now()); // เช่น '2024'

    final graphCollection =
        FirebaseFirestore.instance.collection('count_booking_graph');

    // ตรวจสอบว่ามีเอกสารที่ตรงกับวัน, เดือน, ปี, และ stadiumId นี้หรือไม่
    final existingDocs = await graphCollection
        .where('day', isEqualTo: day)
        .where('period', isEqualTo: 'week') // สมมติว่าเป็นช่วงสัปดาห์
        .where('year', isEqualTo: year)
        .where('stadiumId', isEqualTo: data['stadiumId']) // เพิ่มการตรวจสอบ stadiumId
        .get();

    if (existingDocs.docs.isNotEmpty) {
      // อัพเดตเอกสารที่มีอยู่
      await existingDocs.docs.first.reference.update({
        'count': FieldValue.increment(1),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // สร้างเอกสารใหม่
      await graphCollection.add({
        'stadiumName': data['stadiumName'],
        'stadiumId': data['stadiumId'], // เพิ่ม stadiumId
        'adminId': data['adminId'],
        'day': day,
        'month': month,
        'year': year,
        'count': 1,
        'timestamp': FieldValue.serverTimestamp(),
        'period': 'week', // สมมติว่าเป็นช่วงสัปดาห์
        'date': FieldValue.serverTimestamp(),
      });
    }

    print('Booking confirmed and graph updated successfully.');
  } catch (e) {
    print('Error confirming booking or updating graph: $e');
  }




    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Booking confirmed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยกเลิกการจอง'),
          content: const Text('คุณเเน่ใจที่จะยกเลิกการจองนี้ใช่ไหม'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without deleting
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                updateStatusToFailed(docId);
                Navigator.pop(context); // Close dialog after deleting
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  void updateStatusToFailed(String docId) async {
    await FirebaseFirestore.instance
        .collection('Waiting for confirmation')
        .doc(docId)
        .update({'bookingStatus': 'Failed'});

    // Show deletion dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: const Text('Booking status updated to Failed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
