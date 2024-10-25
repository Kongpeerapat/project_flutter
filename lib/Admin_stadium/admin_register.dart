import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/Admin_stadium/admin_login.dart';
import 'package:user/Admin_stadium/bottombar.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Register> {
  File? _image;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  
  final FirebaseAuth _auth = FirebaseAuth.instance; // เข้าถึง FirebaseAuth instance
  final FirebaseStorage _storage = FirebaseStorage.instance; // เข้าถึง FirebaseStorage instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // เข้าถึง FirebaseFirestore instance


    void _register() async {
    try {// สร้างผู้ใช้ใหม่โดยใช้อีเมลและรหัสผ่านที่ผู้ใช้ป้อน
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (_image != null) {
        String imageUrl = await _uploadImage(_image!, userCredential.user!.uid);// หากมีการเลือกรูปภาพในขณะที่ลงทะเบียน อัปโหลดรูปภาพไปยัง Firebase Storage

        await _firestore.collection('user').doc(userCredential.user!.uid).set({// บันทึกข้อมูลผู้ใช้ลงใน Cloud Firestore
          'username': _usernameController.text, // บันทึกชื่อผู้ใช้ลงใน firebase
          'email': _passwordController.text,// บันทึกอีเมลลงใน firebase
          'image_url': imageUrl,// บันทึกรูปภาพลงใน firebase
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomBar(userId: userCredential.user!.uid)// เมื่อลงทะเบียนสำเร็จ นำผู้ใช้ไปยังหน้าแถบเมนู (Dawer)
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





  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.blue[900]!,
                Colors.orange[800]!,
                Colors.orange[400]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 80,
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Register",
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                    Text(
                      "TO ADMIN STADIUM",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'LOGIN',
                        style: TextStyle(
                            color: Color.fromARGB(255, 25, 0, 255),
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 30),
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 249, 247, 247),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              const BoxShadow(
                                  color: Color.fromARGB(255, 248, 175, 66),
                                  blurRadius: 30,
                                  offset: Offset(0, 0))
                            ]),
                        child: Column(
                          children: <Widget>[
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
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[200]!))),
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: "   Email",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 238, 156, 49),
                              height: 0,
                              thickness: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[200]!))),
                              child: TextField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  hintText: "   Username",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 238, 156, 49),
                              height: 0,
                              thickness: 1,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[200]!))),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: "   Password",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 20),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.vpn_key_outlined,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 238, 156, 49),
                              height: 0,
                              thickness: 1,
                            ),
                           
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 80),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            colors: [
                              Colors.orange[900]!,
                              Colors.orange[800]!,
                              Colors.orange[400]!,
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: _register,
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: const Text(
                              "REGISTER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
