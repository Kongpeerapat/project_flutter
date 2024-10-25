import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'package:flutter/material.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final User? currentUser = FirebaseAuth.instance.currentUser; // Get the current user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        centerTitle: true,
        title: const Text(
          'รีวิว',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see your reviews.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Reviews')
                  .where('adminId', isEqualTo: currentUser!.uid) // Filter reviews by userId
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No reviews available'));
                }

                final reviews = snapshot.data!.docs;

                // Calculate average rating
                double totalRating = 0;
                int reviewCount = reviews.length;

                for (var review in reviews) {
                  final reviewData = review.data() as Map<String, dynamic>;
                  final rating = reviewData['rating'] ?? 0;
                  totalRating += rating;
                }

                double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'คะเเนนการรีวิว: ${averageRating.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final reviewData = reviews[index].data() as Map<String, dynamic>;
                          final userName = reviewData['userName'] ?? 'Anonymous';
                          final reviewText = reviewData['review'] ?? 'No review text';
                          final staduimname = reviewData['stadiumName'] ?? 'dont have name';
                          final rating = reviewData['rating'] ?? 0;
                          final profileImageUrl = reviewData['userProfileImage'];
                          final timestamp = (reviewData['timestamp'] as Timestamp?)?.toDate();

                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              width: double.infinity,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: profileImageUrl != null
                                        ? CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(profileImageUrl),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(50),
                                              color: Colors.orange,
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5, top: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold,),
                                              ),
                                              Text(staduimname,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold  ),)
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            reviewText,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < rating ? Icons.star : Icons.star_border,
                                                size: 30,
                                                color: Colors.yellow,
                                              );
                                            }),
                                          ),
                                          if (timestamp != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: Text(
                                                '${timestamp.toLocal().toString().split(' ')[0]} ${timestamp.toLocal().toString().split(' ')[1].split('.')[0]}',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
