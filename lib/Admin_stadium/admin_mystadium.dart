import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/Admin_stadium/admin_add_stadium.dart';
import 'package:user/Admin_stadium/admin_editmystaduim.dart';

class AdminMystadium extends StatefulWidget {
  @override
  _AdminMystadiumState createState() => _AdminMystadiumState();
}

class _AdminMystadiumState extends State<AdminMystadium> {
  bool isStadiumOpen = true;
  var data;

  void updateStadiumStatus(bool status, String stadiumId) async {
    await FirebaseFirestore.instance
        .collection('addtypestadium')
        .doc(stadiumId)
        .update({
      'status': status ? 'open' : 'closed',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "สนามของฉัน",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[800],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData) {
            return Center(child: Text('ไม่มีผู้ใช้ที่ล็อกอินอยู่.'));
          }

          User? user = userSnapshot.data;
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('addtypestadium')
                .where('userId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, stadiumSnapshot) {
              if (stadiumSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!stadiumSnapshot.hasData ||
                  stadiumSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('ไม่พบสนาม.'));
              }

              return ListView.builder(
                itemCount: stadiumSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var stadium = stadiumSnapshot.data!.docs[index];
                  data = stadium.data() as Map<String, dynamic>;
                  var status =
                      data.containsKey('status') ? data['status'] : 'unknown';
                  String stadiumId = stadium.id;

                   return Padding(
  padding: const EdgeInsets.only(left: 10, top: 10),
  child: Container(
    width: double.infinity, // ให้ความกว้างขยายเต็มที่
    decoration: BoxDecoration(
      border: Border.all(width: 2, color: Color.fromARGB(255, 209, 205, 205)),
      borderRadius: BorderRadius.circular(25),
      color: Color.fromARGB(255, 246, 246, 246),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // ให้คอลัมน์ขยายตามเนื้อหา
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditStadium(
                  stadiumId: stadium.id,
                  stadiumData: data,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.edit,
            color: Colors.black,
            size: 20,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  data['stadiumImageUrl'],
                  width: 180,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'สถานะ',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ'),
                      style: TextStyle(
                        fontSize: 10,
                        color: status == 'open'
                            ? Colors.green
                            : (status == 'closed' ? Colors.red : Colors.grey),
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Switch(
                          value: isStadiumOpen,
                          onChanged: (value) {
                            setState(() {
                              isStadiumOpen = value;
                            });
                            updateStadiumStatus(value, stadiumId);
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        ),
                        Text(
                          isStadiumOpen ? 'เปิด' : 'ปิด',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'เวลาเปิด: ${data['openingTime']}',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      'เวลาปิด: ${data['closingTime']}',
                      style: TextStyle(fontSize: 10),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'ที่อยู่: ${data['address']}',
                      style: TextStyle(fontSize: 10),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'ราคา: ${data['price']}',
                      style: TextStyle(fontSize: 10),
                    ),
                    Text(
                      'เงื่อนไขสนาม: ${data['condition']}',
                      style: TextStyle(fontSize: 10),
                    ),
                    SizedBox(height: 5),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Reviews')
                          .where('stadiumId', isEqualTo: stadiumId)
                          .snapshots(),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                          return Text('No reviews yet', style: TextStyle(fontSize: 12));
                        }

                        final reviews = reviewSnapshot.data!.docs;
                        double totalRating = 0;
                        int reviewCount = reviews.length;

                        for (var review in reviews) {
                          final reviewData = review.data() as Map<String, dynamic>;
                          final rating = reviewData['rating'] ?? 0;
                          totalRating += rating;
                        }

                        double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0;

                        return Row(
                          children: [
                            Icon(Icons.star, color: Color.fromARGB(255, 255, 230, 0)),
                            Text(
                              'คะแนน: ${averageRating.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddStadium()),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.orange,
          size: 50,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
