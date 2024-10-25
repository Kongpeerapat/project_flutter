import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Imagetest extends StatefulWidget {
  final String userId;
  const Imagetest({Key? key, required this.userId}) : super(key: key);

  @override
  State<Imagetest> createState() => _ImagetestState();
}

class _ImagetestState extends State<Imagetest> {
  String? _uploadedImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        String? imageUrl = snapshot.get('image_url');
        setState(() {
          _uploadedImage = imageUrl;
        });
      } else {
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          _uploadedImage = null; // หรือจัดการในวิธีที่คุณต้องการ
        });
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการโหลดภาพ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Image'),
      ),
      body: _uploadedImage == null
          ? const Center(child: Text('ไม่มีภาพหรือเอกสารไม่มีอยู่จริง.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(_uploadedImage!),
            ),
    );
  }
}
