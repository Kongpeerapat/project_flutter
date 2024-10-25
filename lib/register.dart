import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/dawer.dart';
import 'login.dart';

// ประกาศคลาส Register ซึ่งเป็น StatefulWidget ซึ่งใช้สร้างหน้าที่ให้ผู้ใช้ลงทะเบียน
class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

// สร้างคลาส _RegisterState เพื่อเก็บสถานะของ State ในหน้า Register
class _RegisterState extends State<Register> {
  File? _image; // ตัวแปรที่ใช้เก็บไฟล์รูปภาพ
  TextEditingController emailController = TextEditingController(); // Controller สำหรับช่องกรอกอีเมล
  TextEditingController passwordController = TextEditingController(); // Controller สำหรับช่องกรอกรหัสผ่าน
  TextEditingController usernameController = TextEditingController(); // Controller สำหรับช่องกรอกชื่อผู้ใช้

  final FirebaseAuth _auth = FirebaseAuth.instance; // เข้าถึง FirebaseAuth instance
  final FirebaseStorage _storage = FirebaseStorage.instance; // เข้าถึง FirebaseStorage instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // เข้าถึง FirebaseFirestore instance

  // เมื่อผู้ใช้คลิกที่ปุ่ม Confirm เพื่อลงทะเบียน
  void _register() async {
    try {// สร้างผู้ใช้ใหม่โดยใช้อีเมลและรหัสผ่านที่ผู้ใช้ป้อน
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (_image != null) {
        String imageUrl = await _uploadImage(_image!, userCredential.user!.uid);// หากมีการเลือกรูปภาพในขณะที่ลงทะเบียน อัปโหลดรูปภาพไปยัง Firebase Storage

        await _firestore.collection('user').doc(userCredential.user!.uid).set({// บันทึกข้อมูลผู้ใช้ลงใน Cloud Firestore
          'username': usernameController.text, // บันทึกชื่อผู้ใช้ลงใน firebase
          'email': emailController.text,// บันทึกอีเมลลงใน firebase
          'image_url': imageUrl,// บันทึกรูปภาพลงใน firebase
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dawer(userId: userCredential.user!.uid)// เมื่อลงทะเบียนสำเร็จ นำผู้ใช้ไปยังหน้าแถบเมนู (Dawer)
        ),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {// แจ้งเตือนหากรหัสผ่านไม่ปลอดภัย
        print('The password provided is too weak.');// แจ้งเตือนหากมีบัญชีอีเมลนี้อยู่แล้ว
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {// แสดงข้อผิดพลาดที่เกิดขึ้น
      print(e);
    }
  }

  Future<String> _uploadImage(File image, String userId) async {// ฟังก์ชั่นสำหรับอัปโหลดรูปภาพไปยัง Firebase Storage
    try {
      Reference storageRef =// สร้าง Reference สำหรับเก็บไฟล์รูปภาพใน Firebase Storage
          _storage.ref().child('user_images').child('$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(image); // เริ่มกระบวนการอัปโหลด
      TaskSnapshot taskSnapshot = await uploadTask;// รอให้กระบวนการอัปโหลดเสร็จสิ้น
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();// ดึง URL ของรูปภาพที่อัปโหลดเสร็จ
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Register",
                style: TextStyle(fontSize: 30),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Container(
                  margin: const EdgeInsets.only(left: 18.0),
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? Icon(Icons.add_photo_alternate_rounded,
                              size: 70, color: Colors.grey[800])
                          : null,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 50,
                  right: 50,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color.fromARGB(255, 219, 212, 212),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      icon: Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: Color.fromARGB(255, 143, 143, 143),
                        ),
                      ),
                      hintText: 'Username',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 50,
                  right: 50,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 219, 212, 212),
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 143, 143, 143),
                        ),
                      ),
                      hintText: 'Email',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 10, right: 50),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 219, 212, 212),
                  ),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(Icons.password),
                      ),
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.black),
                    ),
                    obscureText: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 50, right: 50),
                child: Container(
                  width: 400,
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black),
                  child: TextButton(
                    onPressed: _register,
                    child: const Text(
                      "Confirm",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.perm_contact_cal_sharp,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
}
