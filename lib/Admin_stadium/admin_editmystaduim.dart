import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class EditStadium extends StatefulWidget {
  final String stadiumId;
  final Map<String, dynamic> stadiumData;

  EditStadium({required this.stadiumId, required this.stadiumData});

  @override
  _EditStadiumState createState() => _EditStadiumState();
}

class _EditStadiumState extends State<EditStadium> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _priceController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;
  late TextEditingController _condition;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.stadiumData['name']);
    _addressController = TextEditingController(text: widget.stadiumData['address']);
    _priceController = TextEditingController(text: widget.stadiumData['price']);
    _openingTimeController = TextEditingController(text: widget.stadiumData['openingTime']);
    _closingTimeController = TextEditingController(text: widget.stadiumData['closingTime']);
    _condition = TextEditingController(text: widget.stadiumData['condition']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        final time = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
        controller.text = '${time.hour}:${time.minute}';
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      // Create a unique filename for the image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Reference to Firebase Storage
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref()
        .child('stadium_images')
        .child(fileName);

      // Upload file to Firebase Storage
      await ref.putFile(imageFile);

      // Get download URL
      String downloadURL = await ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      // Handle any exceptions here
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }

  void _saveStadium() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_imageFile != null) {
        
        imageUrl = await uploadImageToFirebase(_imageFile!);
      } else {
      
        imageUrl = widget.stadiumData['stadiumImageUrl'];
      }

      
      await FirebaseFirestore.instance.collection('addtypestadium').doc(widget.stadiumId).update({
        'name': _nameController.text,
        'condition': _condition.text,
        'address': _addressController.text,
        'price': _priceController.text,
        'openingTime': _openingTimeController.text,
        'closingTime': _closingTimeController.text,
        'stadiumImageUrl': imageUrl,

      });

      // Navigate back to previous screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('แก้ไขข้อมูลสนาม',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Colors.orange[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(  
          key: _formKey,
          child: ListView(
            children: [
               TextFormField(
                controller: _condition,
                decoration: InputDecoration(labelText: 'เงื่อนไขของสนาม'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'ชื่อ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'ที่อยู่'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'ราคา'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _openingTimeController,
                decoration: InputDecoration(
                  labelText: 'เวลาเปิด',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _pickTime(_openingTimeController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the opening time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _closingTimeController,
                decoration: InputDecoration(
                  labelText: 'เวลาปิด',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _pickTime(_closingTimeController),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the closing time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : widget.stadiumData['stadiumImageUrl'] != null
                        ? Image.network(widget.stadiumData['stadiumImageUrl'])
                        : Icon(Icons.add_a_photo, size: 100),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStadium,
                child: Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
