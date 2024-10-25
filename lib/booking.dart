// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:user/choosebooking.dart';
// import 'package:user/dawer.dart';

// class Booking extends StatefulWidget {
//   final String userId;

//   const Booking({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<Booking> createState() => _BookingState();
// }

// class _BookingState extends State<Booking> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
//         centerTitle: true,
//         title: const Text(
//           "Booking",
//           style: TextStyle(
//               fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               showSearch(
//                 context: context,
//                 delegate: StadiumSearchDelegate(widget.userId),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Dawer(userId: widget.userId), // Pass userId here

//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(10.0),
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance.collection("addtypestadium").snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(child: Text('No stadiums found.'));
//                   }

//                   return SizedBox(
//                     height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kToolbarHeight,
//                     child: ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         var stadium = snapshot.data!.docs[index];
//                         var data = stadium.data() as Map<String, dynamic>;
//                         var status = data.containsKey('status') ? data['status'] : 'unknown';

//                         return Container(
//                           width: 320,
//                           height: 250,
//                           padding: const EdgeInsets.all(10.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                             color: const Color.fromARGB(255, 240, 240, 240),
//                             border: const Border(
//                               bottom: BorderSide(
//                                 color: Colors.black, // Color of the underline
//                                 width: 1.0, // Thickness of the underline
//                               ),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(25), // Add rounded corners
//                                 child: Image.network(
//                                   data['stadiumImageUrl'],
//                                   width: 180,
//                                   height: 150,
//                                   fit: BoxFit.cover, // Ensure the image covers the container
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       data['name'], //ชื่อสนาม
//                                       style: TextStyle(
//                                           fontSize: 16, fontWeight: FontWeight.bold),
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "สถานะ",
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ'),
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                             color: status == 'open' ? Colors.green : (status == 'closed' ? Colors.red : Colors.grey),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const Row(
//                                       children: [
//                                         Text(
//                                           "คะเนน",
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                         Text(
//                                           "4.7",
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                           ),
//                                         ),
//                                         Icon(
//                                           Icons.star,
//                                           color: Colors.yellow,
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "เวลาเปิด : ${data['openingTime']}",
//                                           style: TextStyle(fontSize: 10),
//                                         ),
                                       
//                                       ],
//                                     ),
//                                     Row(children: [
//                                        Text(
//                                           "เวลาปิด : ${data['closingTime']}",
//                                           style: TextStyle(fontSize: 10),
//                                         ),
//                                     ],),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "ที่อยู่ ${data['address']}",
//                                           style: TextStyle(fontSize: 10),
//                                         )
//                                       ],
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "ราคา ${data['price']}",
//                                           style: TextStyle(
//                                             fontSize: 10,
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 5),
//                                     ElevatedButton.icon(
//                                       onPressed: status == 'open'
//                                           ? () {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) => Choosebooking(
//                                                     userId: widget.userId,
//                                                     stadiumData: data,
//                                                   ),
//                                                 ),
//                                               );
//                                             }
//                                           : null,
//                                       icon: const Icon(
//                                         Icons.check_sharp,
//                                         color: Color.fromARGB(255, 255, 255, 255),
//                                       ),
//                                       label: const Text(
//                                         "Choose",
//                                         style: TextStyle(color: Colors.white, fontSize: 10),
//                                       ),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Color.fromARGB(255, 0, 0, 0),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class StadiumSearchDelegate extends SearchDelegate {
//   final String userId;
//   StadiumSearchDelegate(this.userId);

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('addtypestadium')
//           .where('name', isGreaterThanOrEqualTo: query)
//           .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.data!.docs.isEmpty) {
//           return Center(child: Text('No stadiums found.'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var stadium = snapshot.data!.docs[index];
//             var data = stadium.data() as Map<String, dynamic>;
//             var status = data.containsKey('status') ? data['status'] : 'unknown';

//             return ListTile(
//               title: Text(data['name']),
//               subtitle: Text(status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ')),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => Choosebooking(
//                       userId: userId,
//                       stadiumData: data,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('addtypestadium')
//           .where('name', isGreaterThanOrEqualTo: query)
//           .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.data!.docs.isEmpty) {
//           return Center(child: Text('No stadiums found.'));
//         }

//         return ListView.builder(
//           itemCount: snapshot.data!.docs.length,
//           itemBuilder: (context, index) {
//             var stadium = snapshot.data!.docs[index];
//             var data = stadium.data() as Map<String, dynamic>;
//             var status = data.containsKey('status') ? data['status'] : 'unknown';

//             return ListTile(
//               title: Text(data['name']),
//               subtitle: Text(status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ')),
//               onTap: () {
//                 query = data['name'];
//                 showResults(context);
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user/choosebooking.dart';
import 'package:user/dawer.dart';

class Booking extends StatefulWidget {
  final String userId;

  const Booking({Key? key, required this.userId}) : super(key: key);

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        title: const Text(
          "จองสนาม",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StadiumSearchDelegate(widget.userId),
              );
            },
          ),
        ],
      ),
      drawer: Dawer(userId: widget.userId), // Pass userId here

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("addtypestadium").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No stadiums found.'));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kToolbarHeight,
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var stadium = snapshot.data!.docs[index];
                        var data = stadium.data() as Map<String, dynamic>;
                        var status = data.containsKey('status') ? data['status'] : 'unknown';

                        return Container(
                          width: 320,
                          height: 250,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color.fromARGB(255, 240, 240, 240),
                            border: const Border(
                              bottom: BorderSide(
                                color: Colors.black, // Color of the underline
                                width: 1.0, // Thickness of the underline
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25), // Add rounded corners
                                child: Image.network(
                                  data['stadiumImageUrl'],
                                  width: 180,
                                  height: 150,
                                  fit: BoxFit.cover, // Ensure the image covers the container
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'], //ชื่อสนาม
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "สถานะ",
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: status == 'open' ? Colors.green : (status == 'closed' ? Colors.red : Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Reviews')
                                          .where('stadiumId', isEqualTo: stadium.id)
                                          .snapshots(),
                                      builder: (context, reviewSnapshot) {
                                        if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                                          return const Row(
                                            children: [
                                              Text(
                                                "คะเนน",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "ยังไมีมัรีวิว",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Icon(
                                                Icons.star,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          );
                                        }

                                        double totalRating = 0.0;
                                        reviewSnapshot.data!.docs.forEach((doc) {
                                          totalRating += (doc.data() as Map<String, dynamic>)['rating'];
                                        });
                                        double averageRating = totalRating / reviewSnapshot.data!.docs.length;

                                        return Row(
                                          children: [
                                            Text(
                                              "คะเนน",
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              averageRating.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "เวลาเปิด : ${data['openingTime']}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "เวลาปิด : ${data['closingTime']}",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                   Row(
  children: [
    Flexible(  // ใช้ Flexible เพื่อให้ Text ปรับขนาดตามพื้นที่
      child: Text(
        "ที่อยู่ ${data['address']}",
        style: TextStyle(fontSize: 10),
        softWrap: true, // ให้ข้อความยาวขึ้นบรรทัดใหม่
        overflow: TextOverflow.visible, // แสดงข้อความทั้งหมดโดยขึ้นบรรทัดใหม่
        maxLines: null, // อนุญาตให้ข้อความยาวขึ้นหลายบรรทัดได้
      ),
    ),
  ],
),

                                    Row(
                                      children: [
                                        Text(
                                          "ราคา ${data['price']}",
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton.icon(
                                      onPressed: status == 'open'
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Choosebooking(
                                                    userId: widget.userId,
                                                    stadiumData: {
                                                      ...data,
                                                      'stadiumId': stadium.id, // เพิ่ม stadiumId
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      icon: const Icon(
                                        Icons.check_sharp,
                                        color: Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      label: const Text(
                                        "เลือก",
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StadiumSearchDelegate extends SearchDelegate {
  final String userId;
  StadiumSearchDelegate(this.userId);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('addtypestadium')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No stadiums found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var stadium = snapshot.data!.docs[index];
            var data = stadium.data() as Map<String, dynamic>;
            var status = data.containsKey('status') ? data['status'] : 'unknown';

            return ListTile(
              title: Text(data['name']),
              subtitle: Text(status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Choosebooking(
                      userId: userId,
                      stadiumData: data,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('addtypestadium')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No stadiums found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var stadium = snapshot.data!.docs[index];
            var data = stadium.data() as Map<String, dynamic>;
            var status = data.containsKey('status') ? data['status'] : 'unknown';

            return ListTile(
              title: Text(data['name']),
              subtitle: Text(status == 'open' ? 'เปิด' : (status == 'closed' ? 'ปิด' : 'ไม่ทราบ')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Choosebooking(
                      userId: userId,
                      stadiumData: data,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
