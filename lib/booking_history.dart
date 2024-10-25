import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:user/dawer.dart';

class BookingHistory extends StatefulWidget {
  final String userId;
  const BookingHistory({Key? key, required this.userId}) : super(key: key);

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "ประวัติการจอง",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      drawer: Dawer(userId: widget.userId),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Waiting for confirmation')
                    .where('userId', isEqualTo: widget.userId)
                    
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No booking history found.'));
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      var bookingTimestamp = data['timestamp'] != null
                          ? (data['timestamp'] as Timestamp).toDate()
                          : null;
                      var formattedTimestamp = bookingTimestamp != null
                          ? DateFormat('HH:mm dd-MM-yyyy ')
                              .format(bookingTimestamp)
                          : 'Unknown';

                      var bookingDate = data['bookingDate'] != null
                          ? (data['bookingDate'] as Timestamp).toDate()
                          : null;
                      var formattedBookingDate = bookingDate != null
                          ? DateFormat('dd-MM-yyyy').format(bookingDate)
                          : 'Unknown';

                      Color getStatusColor(String status) {
                        switch (status) {
                          case 'Confirmed':
                            return Colors.green;
                          case 'Failed':
                            return Colors.red;
                          default:
                            return Colors.orange;
                        }
                      }

                      return Container(
                        width: 400,
                        height: 300,
                        padding: const EdgeInsets.all(10.0),
                        margin: const EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color.fromARGB(255, 240, 240, 240),
                          border: const Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: data['stadiumImageUrl'] != null
                                      ? Image.network(
                                          data['stadiumImageUrl'],
                                          width: 120,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey,
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['stadiumName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'วันที่จอง: $formattedBookingDate',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "สถานะ: ",
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            data['bookingStatus'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: getStatusColor(
                                                  data['bookingStatus'] ?? ''),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'วันที่ทำการ: $formattedTimestamp',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        'เวลาเปิด: ${data['openingTime'] ?? 'Unknown'}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        'เวลาปิด: ${data['closingTime'] ?? 'Unknown'}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 150,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                        ),
                                        child: TextButton(
                                          onPressed: data['bookingStatus']=='Confirmed'
                                          ?  () {
                                            _showReviewDialog(data);
                                          } : null,

                                          child: const Text(
                                            "รีวิวสนาม",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 void _showReviewDialog(Map<String, dynamic> bookingData) {
  TextEditingController reviewController = TextEditingController();
  double rating = 0.0;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('รีวิวสนาม'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                rating = newRating;
              },
            ),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                hintText: 'เขียนรีวิวของคุณ',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('ยืนยัน'),
            onPressed: () {
              _submitReview(bookingData, reviewController.text, rating);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  Future<void> _submitReview(Map<String, dynamic> bookingData, String reviewText, double rating) async {
  if (reviewText.isNotEmpty) {
    await FirebaseFirestore.instance.collection('Reviews').add({
      'stadiumId': bookingData['stadiumId'],  // Assumes 'stadiumId' is available in bookingData
      'stadiumName': bookingData['stadiumName'],
      'adminId': bookingData['adminId'],
      'userId': widget.userId,
      'userName': bookingData['userName'],
      'review': reviewText,
      'rating': rating, // เพิ่มคะแนนที่ผู้ใช้ให้
      'userProfileImage': bookingData['profileImage'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review cannot be empty')),
    );
  }
}
}
