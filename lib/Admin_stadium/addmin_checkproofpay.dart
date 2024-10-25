import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddminCheckproofpay extends StatefulWidget {
  const AddminCheckproofpay({super.key});

  @override
  State<AddminCheckproofpay> createState() => _AddminCheckproofpayState();
}

class _AddminCheckproofpayState extends State<AddminCheckproofpay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'ตรวจสอบการชำระเงิน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Waiting for confirmation') // เปลี่ยนเป็น collection 'Waiting for confirmation'
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลการชำระเงิน'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;

              return Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: data['proofpayment'] != null && data['proofpayment'].isNotEmpty
                          ? Image.network(
                              data['proofpayment'] ?? '',
                              width: MediaQuery.of(context).size.width * 0.5, // Adjust width to be responsive
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('No payment slip provided');
                              },
                            )
                          : const Text('No payment slip provided'),
                    ),
                    Text(
                      'Timestamp: ${data['timestamp']?.toDate().toString() ?? 'ไม่มีข้อมูล'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _confirmPayment(doc.id, data);
                      },
                      child: const Text('ยืนยันการชำระเงิน', style: TextStyle(fontSize: 20, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _confirmPayment(String docId, Map<String, dynamic> data) async {
    try {
      // อัปเดตสถานะการชำระเงินเป็น 'Confirmed' ใน collection 'Waiting for confirmation'
      await FirebaseFirestore.instance
          .collection('Waiting for confirmation')
          .doc(docId)
          .update({'paymentStatus': 'Confirmed'});

      // อัปเดตสถานะการจองเป็น 'Confirmed' ใน collection 'Waiting for confirmation'
      await FirebaseFirestore.instance
          .collection('Waiting for confirmation')
          .doc(docId)
          .update({'bookingStatus': 'Confirmed'});

      // แสดงกล่องข้อความยืนยัน
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Payment confirmed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิดกล่องข้อความ
                  Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("เกิดข้อผิดพลาดในการยืนยันการชำระเงิน: $e");
      // แสดงข้อความข้อผิดพลาด
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while confirming payment.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิดกล่องข้อความ
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
