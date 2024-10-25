// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AddStadium extends StatefulWidget {
//   const AddStadium({Key? key});

//   @override
//   State<AddStadium> createState() => _AddStadiumState();
// }

// class _AddStadiumState extends State<AddStadium> {
//   File? stadiumImage;
//   File? qrCodeImage;

//   TextEditingController _fieldNameController = TextEditingController();
//   TextEditingController _openingTimeController = TextEditingController();
//   TextEditingController _closingTimeController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   TextEditingController _priceController = TextEditingController();
//   TextEditingController _accountNameController = TextEditingController();
//   TextEditingController _accountNumberController = TextEditingController();
//   TextEditingController _bankNameController = TextEditingController();
//   TextEditingController condition = TextEditingController();

//   Future<void> _pickImage(bool isStadiumImage) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         if (isStadiumImage) {
//           stadiumImage = File(pickedFile.path);
//         } else {
//           qrCodeImage = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   Future<String?> _uploadImageToFirebase(File image) async {
//     try {
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference storageReference =
//           FirebaseStorage.instance.ref().child('stadiums/$fileName');
//       UploadTask uploadTask = storageReference.putFile(image);
//       TaskSnapshot taskSnapshot = await uploadTask;
//       return await taskSnapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Error uploading image: $e");
//       return null;
//     }
//   }

//  Future<void> _submitStadium() async {
//   if (_fieldNameController.text.isEmpty ||
//       _openingTimeController.text.isEmpty ||
//       _closingTimeController.text.isEmpty ||
//       _addressController.text.isEmpty ||
//       _priceController.text.isEmpty ||
//       _accountNameController.text.isEmpty ||
//       _accountNumberController.text.isEmpty ||
//       _bankNameController.text.isEmpty ||
//       stadiumImage == null ||
//       qrCodeImage == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Please fill in all fields and select images')),
//     );
//     return;
//   }

//   try {
//     String? stadiumImageUrl = await _uploadImageToFirebase(stadiumImage!);
//     String? qrCodeImageUrl = await _uploadImageToFirebase(qrCodeImage!);

//     if (stadiumImageUrl != null && qrCodeImageUrl != null) {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         Map<String, dynamic> stadiumData = {
//           'stadiumImageUrl': stadiumImageUrl,
//           'condition':condition.text,
//           'qrCodeImageUrl': qrCodeImageUrl,
//           'name': _fieldNameController.text,
//           'openingTime': _openingTimeController.text,
//           'closingTime': _closingTimeController.text,
//           'address': _addressController.text,
//           'price': _priceController.text,
//           'accountName': _accountNameController.text,
//           'accountNumber': _accountNumberController.text,
//           'bankName': _bankNameController.text,
//           'userId': user.uid,  
//         };

//         await FirebaseFirestore.instance
//             .collection('addtypestadium')
//             .add(stadiumData);

//         Navigator.pop(context, stadiumData);
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to upload images')),
//       );
//     }
//   } catch (e) {
//     print("Error submitting stadium: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Failed to submit stadium')),
//     );
//   }
// }

//   Future<void> _selectTime(TextEditingController controller) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         controller.text = picked.format(context);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange[800],
//         centerTitle: true,
//         title: const Text(
//           'Add Stadium',
//           style: TextStyle(
//             fontSize: 25,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               GestureDetector(
//                 onTap: () => _pickImage(true),
//                 child: Center(
//                   child: Container(
//                     width: 300,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 236, 235, 235),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: stadiumImage != null
//                         ? Image.file(
//                             stadiumImage!,
//                             fit: BoxFit.cover,
//                           )
//                         : const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.add_a_photo_rounded,
//                                   size: 50,
//                                   color: Colors.black54,
//                                 ),
//                                 Text(
//                                   'เพิ่มรูปภาพสนามของคุณ',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _fieldNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'ชื่อสนาม',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () => _selectTime(_openingTimeController),
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'เวลาเปิด',
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Text(
//                           _openingTimeController.text,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () => _selectTime(_closingTimeController),
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'เวลาปิด',
//                           border: OutlineInputBorder(),
//                         ),
//                         child: Text(
//                           _closingTimeController.text,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//                TextFormField(
//                 controller: condition,
//                 decoration: const InputDecoration(
//                   labelText: 'เงื่อนไขของสนาม',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _addressController,
//                 decoration: const InputDecoration(
//                   labelText: 'ที่อยู่',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(
//                   labelText: 'ราคา',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _accountNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'ชื่อบัญชี',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _accountNumberController,
//                 decoration: const InputDecoration(
//                   labelText: 'เลขที่บัญชี',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _bankNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'ธนาคาร',
//                   border: OutlineInputBorder(),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 10),
//               GestureDetector(
//                 onTap: () => _pickImage(false),
//                 child: Center(
//                   child: Container(
//                     width: 300,
//                     height: 180,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 236, 235, 235),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: qrCodeImage != null
//                         ? Image.file(
//                             qrCodeImage!,
//                             fit: BoxFit.cover,
//                           )
//                         : const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.add_a_photo_rounded,
//                                   size: 50,
//                                   color: Colors.black54,
//                                 ),
//                                 Text(
//                                   'เพิ่ม QR code',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitStadium,
//                   child: const Text(
//                     'ยืนยัน',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStadium extends StatefulWidget {
  const AddStadium({Key? key}) : super(key: key);

  @override
  State<AddStadium> createState() => _AddStadiumState();
}

class _AddStadiumState extends State<AddStadium> {
  File? stadiumImage;
  File? qrCodeImage;

  TextEditingController _fieldNameController = TextEditingController();
  TextEditingController _openingTimeController = TextEditingController();
  TextEditingController _closingTimeController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController condition = TextEditingController();

  Future<void> _pickImage(bool isStadiumImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isStadiumImage) {
          stadiumImage = File(pickedFile.path);
        } else {
          qrCodeImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('stadiums/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _submitStadium() async {
    if (_fieldNameController.text.isEmpty ||
        _openingTimeController.text.isEmpty ||
        _closingTimeController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _accountNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _bankNameController.text.isEmpty ||
        stadiumImage == null ||
        qrCodeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select images')),
      );
      return;
    }

    try {
      String? stadiumImageUrl = await _uploadImageToFirebase(stadiumImage!);
      String? qrCodeImageUrl = await _uploadImageToFirebase(qrCodeImage!);

      if (stadiumImageUrl != null && qrCodeImageUrl != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Create a new document reference
          DocumentReference newStadiumRef = FirebaseFirestore.instance.collection('addtypestadium').doc();

          // Prepare stadium data
          Map<String, dynamic> stadiumData = {
            'stadiumImageUrl': stadiumImageUrl,
            'condition': condition.text,
            'qrCodeImageUrl': qrCodeImageUrl,
            'name': _fieldNameController.text,
            'openingTime': _openingTimeController.text,
            'closingTime': _closingTimeController.text,
            'address': _addressController.text,
            'price': _priceController.text,
            'accountName': _accountNameController.text,
            'accountNumber': _accountNumberController.text,
            'bankName': _bankNameController.text,
            'userId': user.uid,
          };

          // Set data with the generated document ID
          await newStadiumRef.set(stadiumData);

          // Get the document ID
          String stadiumId = newStadiumRef.id;

          // Optionally, update the document with the ID
          await newStadiumRef.update({'stadiumId': stadiumId});

          // Pass the stadiumId to the previous screen or use as needed
          Navigator.pop(context, {
            ...stadiumData,
            'stadiumId': stadiumId,
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images')),
        );
      }
    } catch (e) {
      print("Error submitting stadium: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit stadium')),
      );
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        centerTitle: true,
        title: const Text(
          'กรอกข้อมูลสนาม',
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Center(
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 235, 235),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: stadiumImage != null
                        ? Image.file(
                            stadiumImage!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 50,
                                  color: Colors.black54,
                                ),
                                Text(
                                  'เพิ่มรูปภาพสนามของคุณ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _fieldNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสนาม',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(_openingTimeController),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'เวลาเปิด',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _openingTimeController.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(_closingTimeController),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'เวลาปิด',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _closingTimeController.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: condition,
                decoration: const InputDecoration(
                  labelText: 'เงื่อนไขของสนาม',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'ที่อยู่',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'ราคา',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อบัญชี',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'เลขที่บัญชี',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'ธนาคาร',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Center(
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 235, 235),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: qrCodeImage != null
                        ? Image.file(
                            qrCodeImage!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 50,
                                  color: Colors.black54,
                                ),
                                Text(
                                  'เพิ่ม QR code',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _submitStadium,
                  child: const Text(
                    'ยืนยัน',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
