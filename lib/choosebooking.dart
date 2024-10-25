import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/booking_history.dart';


class Choosebooking extends StatefulWidget {
  final Map<String, dynamic> stadiumData;
  final String userId;
  const Choosebooking({Key? key, required this.stadiumData, required this.userId}) : super(key: key);

  @override
  State<Choosebooking> createState() => _ChoosebookingState();
}

class _ChoosebookingState extends State<Choosebooking> {
  String? _profilebooking;
  String? _usernambooking;
  DateTime? selectedDate;
  TextEditingController contact = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          "ข้อมูลการจองเเละชำระ",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.stadiumData['stadiumImageUrl'] != null
                  ? Center(
                      child: Image.network(
                        widget.stadiumData['stadiumImageUrl'],
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
             
              Center(
                child: Text(
                  '${widget.stadiumData['name']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
               Center(
                child: Text(
                  'เงื่อนไขของสนาม : ${widget.stadiumData['condition']}',
                  style: TextStyle(fontSize: 16,),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'เปิด: ${widget.stadiumData['openingTime']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'ปิด: ${widget.stadiumData['closingTime']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'ที่อยู่: ${widget.stadiumData['address']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'ราคา: ${widget.stadiumData['price']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _pickDate,
                  child: Text(
                    selectedDate == null
                        ? "เลือกวันที่"
                        : "วันที่ ที่เลือก: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: contact,
                decoration: const InputDecoration(
                  labelText: 'กรุณากรอกข้อมูลติดต่อ กรณีเกิดการยกเลิก',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              
               Center(
                child: Text(
                  'ธนาคาร: ${widget.stadiumData['bankName']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
                SizedBox(height: 20),
                Center(
                child: Text(
                  'เลขบัญชี: ${widget.stadiumData['accountNumber']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
                SizedBox(height: 20),
                Center(
                child: Text(
                  'ชื่อบัญชี: ${widget.stadiumData['accountName']}',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
                SizedBox(height: 20),




              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(
                  "เลือกรูปภาพ",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 20),
              _selectedImagePath != null
                  ? Image.file(
                      File(_selectedImagePath!),
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: confrim_typebooking,
                child: Text(
                  "ยืนยัน",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadImage() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        String? imageUrl = snapshot.get('image_url');
        String? username = snapshot.get('username');

        setState(() {
          _profilebooking = imageUrl;
          _usernambooking = username;
        });
      } else {
        print("Document does not exist");
        setState(() {
          _profilebooking = null;
          _usernambooking = null;
        });
      }
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('proofpayment/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await storageSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  void confrim_typebooking() async {
    

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    String stadiumId = widget.stadiumData['stadiumId'];
    String proofpaymentUrl = 'No payment slip provided';
    if (_selectedImagePath != null) {
      proofpaymentUrl = await _uploadImage(File(_selectedImagePath!));
    }

    Map<String, dynamic> bookingData = {
      'stadiumId': stadiumId,
      'stadiumName': widget.stadiumData['name'],
      'stadiumImageUrl': widget.stadiumData['stadiumImageUrl'],
      'openingTime': widget.stadiumData['openingTime'],
      'closingTime': widget.stadiumData['closingTime'],
      'address': widget.stadiumData['address'],
      'price': widget.stadiumData['price'],
      'accountName': widget.stadiumData['accountName'],
      'accountNumber': widget.stadiumData['accountNumber'],
      'bankName': widget.stadiumData['bankName'],
      'adminId': widget.stadiumData['userId'],
      'userId': widget.userId,
      'userName': _usernambooking,
      'profileImage': _profilebooking,
      'contact': contact.text,
      'bookingStatus': 'Waiting for confirmation',
      'paymentStatus': 'Not yet paid',
      'proofpayment': proofpaymentUrl,
      'bookingDate': selectedDate,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('Waiting for confirmation')
        .add(bookingData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking is awaiting confirmation')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingHistory(userId: widget.userId)),
    );
  }
}

