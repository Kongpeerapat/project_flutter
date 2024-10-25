import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Payment extends StatefulWidget {
  final String documentId;
  final String stadiumName;
  final String? stadiumImageUrl;
  final dynamic bookingDate;
  final String bookingStatus;
  final String paymentStatus;

  const Payment({
    Key? key,
    required this.documentId,
    required this.stadiumName,
    required this.stadiumImageUrl,
    required this.bookingDate,
    required this.bookingStatus,
    required this.paymentStatus,
  }) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการเลือกรูปภาพ: $e");
    }
  }

  Future<void> _uploadImageAndUpdatePayment() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเลือกรูปภาพก่อน')),
      );
      return;
    }

    try {
      // สร้างชื่อไฟล์แบบสุ่ม
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // อัปโหลดไฟล์ไปยัง Firebase Storage
      File file = File(_selectedImagePath!);
      Reference storageRef = FirebaseStorage.instance.ref().child('proof_payments/$fileName');
      UploadTask uploadTask = storageRef.putFile(file);

      // รอให้อัปโหลดเสร็จ
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // อัปเดตเอกสารใน Firestore
      await FirebaseFirestore.instance
          .collection('Waiting for confirmation')
          .doc(widget.documentId)
          .update({
        'proofpayment': imageUrl,
      });

      // สร้าง collection payment ที่ซ้อนอยู่ใน collection Waiting for confirmation
      await FirebaseFirestore.instance
          .collection('Waiting for confirmation')
          .doc(widget.documentId)
          .collection('payment')
          .add({
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('การยืนยันการชำระเงินเสร็จสิ้น')),
      );

      // กลับไปยังหน้าก่อนหน้า
      Navigator.pop(context);
    } catch (e) {
      print("เกิดข้อผิดพลาดในการอัปโหลดรูปภาพหรือยืนยันการชำระเงิน: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Waiting for confirmation')
                .doc(widget.documentId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('ไม่พบข้อมูล.'));
              }
        
              var data = snapshot.data!.data() as Map<String, dynamic>;
              var bankName = data['bankName'] ?? 'ไม่ทราบ';
              var accountNumber = data['accountNumber'] ?? 'ไม่ทราบ';
              var accountName = data['accountName'] ?? 'ไม่ทราบ';
        
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.stadiumImageUrl != null
                      ? Image.network(
                          widget.stadiumImageUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                  SizedBox(height: 20),
                  Text(
                    'สนามกีฬา: ${widget.stadiumName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'วันที่จอง: ${widget.bookingDate.toDate().toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ชื่อธนาคาร: $bankName',
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'เลขที่บัญชี: $accountNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ชื่อบัญชี: $accountName',
                    style: const TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  _selectedImagePath != null
                      ? Image.file(
                          File(_selectedImagePath!),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Text('ยังไม่มีการเลือกรูปภาพ'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('เลือกรูปภาพ'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadImageAndUpdatePayment,
                    child: const Text('ยืนยันการชำระเงิน'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
