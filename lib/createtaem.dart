import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:user/dawer.dart';
import 'package:user/mycreate_team.dart';

class Createteam extends StatefulWidget {
  final String userId;
  const Createteam({Key? key, required this.userId}) : super(key: key);

  @override
  State<Createteam> createState() => _CreateteamState();
}

class _CreateteamState extends State<Createteam> {
  File? _imageLogoteam;
  String? _leMituser;
  TextEditingController controllerTeamname = TextEditingController();
  String? teamName;
  String? userName;
  String? proFile;
  List<String> _quantityuser = ['7', '8', '9', '10', '11', '12', '13', '14'];

  @override
  void initState() {
    super.initState();
    _loaduser();
  }

  Future<void> _loaduser() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        String? username = snapshot.get('username');
        String? profile = snapshot.get('image_url');

        setState(() {
          userName = username;
          proFile = profile;
        });
      } else {
        print("เอกสารไม่มีอยู่จริง");
        setState(() {
          userName = null;
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
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "สร้างทีมของฉัน",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Dawer(userId: widget.userId),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage_logoteam,
              child: Padding(
                padding: const EdgeInsets.only(top: 110),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _imageLogoteam != null ? FileImage(_imageLogoteam!) : null,
                  child: _imageLogoteam == null
                      ? Icon(Icons.add_photo_alternate_rounded,
                          size: 120, color: Colors.grey[800])
                      : null,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: controllerTeamname,
                    decoration: InputDecoration(
                      hintText: "ชื่อทีมของคุณ",
                      hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _leMituser,
                    hint: Row(
                      children: [
                        Icon(Icons.arrow_drop_down, color: Colors.grey[800]),
                        SizedBox(width: 10),
                        Text(
                          "เลือกจำนวนสมาชิก",
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                    items: _quantityuser.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: Text(
                            "$value",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _leMituser = newValue;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: TextButton(
                onPressed: createTeam,
                child: Text(
                  "สร้าง",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage_logoteam() async {
    try {
      final imagepicker = ImagePicker();
      final image = await imagepicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageLogoteam = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> createTeam() async {
    setState(() {
      teamName = controllerTeamname.text;
    });

    if (teamName != null && teamName!.isNotEmpty && _imageLogoteam != null && _leMituser != null) {
      try {
        // Upload the image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('team_logos/$fileName')
            .putFile(_imageLogoteam!);

        TaskSnapshot taskSnapshot = await uploadTask;
        String logoUrl = await taskSnapshot.ref.getDownloadURL();

        // Generate a unique team ID
        String teamId = FirebaseFirestore.instance.collection('team').doc().id;

        // Save team information to Firestore with teamId
        DocumentReference teamRef =
            FirebaseFirestore.instance.collection('team').doc(teamId);
        
        await teamRef.set({
          'teamname': teamName,
          'imageteam': logoUrl,
          'adminteam': userName,
          'quantityuserLimit': _leMituser,
          'teamId': teamId, // Save the generated teamId
        });

        // Add the creator as admin in the members collection with teamId
        await teamRef.collection('members').add({
          'status_addminteam': false,
          'namemember': userName,
          'memberProfile': proFile, // You can add admin profile if available
          'timestamp': FieldValue.serverTimestamp(),
          'teamId': teamId, // Include teamId for the member
        });

        // Clear the text fields and image
        controllerTeamname.clear();
        setState(() {
          _imageLogoteam = null;
          _leMituser = null;
        });

        // Navigate to Myteam screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Mycreate_team(userId: widget.userId),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team created successfully!')),
        );
      } catch (e) {
        print("Error creating team: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating team: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please fill all fields and select a logo before creating.')),
      );
    }
  }
}
