// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class Graph extends StatefulWidget {
//   const Graph({super.key});

//   @override
//   State<Graph> createState() => _GraphState();
// }
// class _GraphState extends State<Graph> {
//   String _selectedPeriod = 'week'; // ค่าเริ่มต้นเป็นสัปดาห์
//   String? _userId; // เก็บ userId ของผู้ใช้ที่ล็อกอินอยู่

//   @override
//   void initState() {
//     super.initState();
//     // ตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่
//     _checkLoginStatus();
//   }

//   void _checkLoginStatus() {
//     User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       setState(() {
//         _userId = currentUser.uid; // เก็บ userId ของผู้ใช้ที่ล็อกอินอยู่
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // สามแท็บ: สัปดาห์, เดือน, ปี
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           backgroundColor: Colors.orange[700],
//           title: const Text(
//             'จำนวนการจอง',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 30,
//             ),
//           ),
//           bottom: TabBar(
//             tabs: const [
//               Tab(text: 'สัปดาห์'),
//               Tab(text: 'เดือน'),
//               Tab(text: 'ปี'),
//             ],
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             onTap: (index) {
//               setState(() {
//                 _selectedPeriod = ['week', 'month', 'year'][index];
//               });
//             },
//           ),
//         ),
//         body: _userId == null
//             ? const Center(
//                 child: Text('กรุณาเข้าสู่ระบบก่อน'),
//               )
//             : TabBarView(
//                 children: [
//                   _buildGraph('week'),
//                   _buildGraph('month'),
//                   _buildGraph('year'),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildGraph(String period) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('count_booking_graph')
//           .where('adminId', isEqualTo: _userId) // กรองข้อมูลโดย userId
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         var data = snapshot.data!.docs;

//         // กรองข้อมูลที่อยู่ในช่วงเวลาที่เลือก
//         var filteredData = data.where((doc) {
//           var docData = doc.data() as Map<String, dynamic>;

//           if (docData['date'] is Timestamp) {
//             var timestamp = (docData['date'] as Timestamp).toDate();

//             if (period == 'week') {
//               var now = DateTime.now();
//               var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//               var endOfWeek = startOfWeek.add(Duration(days: 7));

//               var dateOnlyTimestamp = DateTime(timestamp.year, timestamp.month, timestamp.day);
//               var startOfWeekDateOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
//               var endOfWeekDateOnly = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

//               return dateOnlyTimestamp.isAtSameMomentAs(startOfWeekDateOnly) ||
//                   (dateOnlyTimestamp.isAfter(startOfWeekDateOnly) && dateOnlyTimestamp.isBefore(endOfWeekDateOnly));
//             } else if (period == 'month') {
//               var now = DateTime.now();
//               return timestamp.month == now.month && timestamp.year == now.year;
//             } else if (period == 'year') {
//               var now = DateTime.now();
//               return timestamp.year == now.year;
//             }
//           }
//           return false;
//         }).toList();

//         // ตรวจสอบว่า filteredData มีข้อมูลหรือไม่
//         if (filteredData.isEmpty) {
//           return Center(child: Text('No data available for the selected period.'));
//         }

//         // คำนวณจำนวนการจองในแต่ละช่วงเวลา
//         Map<String, int> periodCounts = _initializePeriodCounts(period);

//         for (var doc in filteredData) {
//           var docData = doc.data() as Map<String, dynamic>;
//           var key = _getPeriodKey(period, docData);
//           var count = docData['count'] as int;

//           periodCounts[key] = (periodCounts[key] ?? 0) + count;
//         }

//         double maxY = periodCounts.values.fold(0, (prev, count) => count > prev ? count : prev).toDouble();
//         int totalCount = periodCounts.values.reduce((a, b) => a + b);

//         List<BarChartGroupData> barGroups = _generateBarGroups(period, periodCounts);

//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'จำนวนการจอง ${_formatPeriod(period)}: $totalCount ครั้ง',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: BarChart(
//                   BarChartData(
//   alignment: BarChartAlignment.spaceAround,
//   maxY: maxY,
//   titlesData: FlTitlesData(
//     bottomTitles: AxisTitles(
//       sideTitles: SideTitles(
//         showTitles: true,
//         reservedSize: 40,
//        getTitlesWidget: (value, meta) {
//   const style = TextStyle(
//     fontSize: 8,
//     fontWeight: FontWeight.bold,
//   );
//   Widget text;
//   if (period == 'week') {
//     text = _weekTitles(value.toInt(), style);
//   } else if (period == 'month') {
//     text = _monthTitles(value.toInt(), style);
//   } else {
//     text = _yearTitles(value.toInt(), style);
//   }
//   return SideTitleWidget(
//     axisSide: meta.axisSide,
//     child: text,
//   );
// }

//       ),
//     ),
//   ),
//   borderData: FlBorderData(
//     show: true,
//     border: Border.all(
//       color: const Color(0xff37434d),
//       width: 1,
//     ),
//   ),
//   barGroups: barGroups,
// ),

//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Map<String, int> _initializePeriodCounts(String period) {
//     if (period == 'week') {
//       return {
//         'Mon': 0,
//         'Tue': 0,
//         'Wed': 0,
//         'Thu': 0,
//         'Fri': 0,
//         'Sat': 0,
//         'Sun': 0,
//       };
//     } else if (period == 'month') {
//       return {
//         'Week 1': 0,
//         'Week 2': 0,
//         'Week 3': 0,
//         'Week 4': 0,
//       };
//     } else {
//       return Map.fromIterable(
//         List.generate(12, (index) => DateFormat('MMMM').format(DateTime(2024, index + 1))),
//         key: (item) => item,
//         value: (item) => 0,
//       );
//     }
//   }

//   String _getPeriodKey(String period, Map<String, dynamic> docData) {
//     if (period == 'week') {
//       return docData['day'] as String;
//     } else if (period == 'month') {
//       int weekNumber = ((docData['date'] as Timestamp).toDate().day - 1) ~/ 7 + 1;
//       return 'Week $weekNumber';
//     } else {
//       return DateFormat('MMMM').format((docData['date'] as Timestamp).toDate());
//     }
//   }

//   List<BarChartGroupData> _generateBarGroups(String period, Map<String, int> periodCounts) {
//     return periodCounts.entries.map((entry) {
//       int xValue;
//       if (period == 'week') {
//         xValue = {
//           'Mon': 0,
//           'Tue': 1,
//           'Wed': 2,
//           'Thu': 3,
//           'Fri': 4,
//           'Sat': 5,
//           'Sun': 6,
//         }[entry.key]!;
//       } else if (period == 'month') {
//         xValue = {
//           'Week 1': 0,
//           'Week 2': 1,
//           'Week 3': 2,
//           'Week 4': 3,
//         }[entry.key]!;
//       } else {
//         xValue = DateFormat('MMMM').parse(entry.key).month - 1;
//       }

//       return BarChartGroupData(
//         x: xValue,
//         barRods: [
//           BarChartRodData(
//             toY: entry.value.toDouble(),
//             color: Colors.orange,
//             width: 20,
//           ),
//         ],
//       );
//     }).toList();
//   }

//   Widget _weekTitles(int value, TextStyle style) {
//     switch (value) {
//       case 0: return Text('Mon', style: style);
//       case 1: return Text('Tue', style: style);
//       case 2: return Text('Wed', style: style);
//       case 3: return Text('Thu', style: style);
//       case 4: return Text('Fri', style: style);
//       case 5: return Text('Sat', style: style);
//       case 6: return Text('Sun', style: style);
//       default: return Text('', style: style);
//     }
//   }

//   Widget _monthTitles(int value, TextStyle style) {
//     switch (value) {
//       case 0: return Text('Week 1', style: style);
//       case 1: return Text('Week 2', style: style);
//       case 2: return Text('Week 3', style: style);
//       case 3: return Text('Week 4', style: style);
//       default: return Text('', style: style);
//     }
//   }

//   Widget _yearTitles(int value, TextStyle style) {
//     switch (value) {
//       case 0: return Text('Jan', style: style);
//       case 1: return Text('Feb', style: style);
//       case 2: return Text('Mar', style: style);
//       case 3: return Text('Apr', style: style);
//       case 4: return Text('May', style: style);
//       case 5: return Text('Jun', style: style);
//       case 6: return Text('Jul', style: style);
//       case 7: return Text('Aug', style: style);
//       case 8: return Text('Sep', style: style);
//       case 9: return Text('Oct', style: style);
//       case 10: return Text('Nov', style: style);
//       case 11: return Text('Dec', style: style);
//       default: return Text('', style: style);
//     }
//   }

//   String _formatPeriod(String period) {
//     if (period == 'week') {
//       return 'ในสัปดาห์นี้';
//     } else if (period == 'month') {
//       return 'ในเดือนนี้';
//     } else {
//       return 'ในปีนี้';
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Graph extends StatefulWidget {
  const Graph({super.key});

  @override
  State<Graph> createState() => _GraphState();
}

class _GraphState extends State<Graph> {
  String _selectedPeriod = 'week'; // ค่าเริ่มต้นเป็นสัปดาห์
  String? _userId; // เก็บ userId ของผู้ใช้ที่ล็อกอินอยู่

  @override
  void initState() {
    super.initState();
    // ตรวจสอบว่าผู้ใช้ล็อกอินอยู่หรือไม่
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _userId = currentUser.uid; // เก็บ userId ของผู้ใช้ที่ล็อกอินอยู่
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // สามแท็บ: สัปดาห์, เดือน, ปี
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.orange[700],
          title: const Text(
            'จำนวนการจอง',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'วัน'),
              Tab(text: 'เดือน'),
              Tab(text: 'ปี'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            onTap: (index) {
              setState(() {
                _selectedPeriod = ['week', 'month', 'year'][index];
              });
            },
          ),
        ),
        body: _userId == null
            ? const Center(
                child: Text('กรุณาเข้าสู่ระบบก่อน'),
              )
            : TabBarView(
                children: [
                  _buildGraph('week'),
                  _buildGraph('month'),
                  _buildGraph('year'),
                ],
              ),
      ),
    );
  }

  Widget _buildGraph(String period) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('count_booking_graph')
          .where('adminId', isEqualTo: _userId) // กรองข้อมูลโดย userId
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data!.docs;

        // กรองข้อมูลที่อยู่ในช่วงเวลาที่เลือก
        var filteredData = data.where((doc) {
          var docData = doc.data() as Map<String, dynamic>;

          if (docData['date'] is Timestamp) {
            var timestamp = (docData['date'] as Timestamp).toDate();

            if (period == 'week') {
              var now = DateTime.now();
              var startOfWeek = now.subtract(Duration(days: now.weekday - 1));
              var endOfWeek = startOfWeek.add(Duration(days: 7));

              var dateOnlyTimestamp = DateTime(timestamp.year, timestamp.month, timestamp.day);
              var startOfWeekDateOnly = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
              var endOfWeekDateOnly = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

              return dateOnlyTimestamp.isAtSameMomentAs(startOfWeekDateOnly) ||
                  (dateOnlyTimestamp.isAfter(startOfWeekDateOnly) && dateOnlyTimestamp.isBefore(endOfWeekDateOnly));
            } else if (period == 'month') {
              var now = DateTime.now();
              return timestamp.month == now.month && timestamp.year == now.year;
            } else if (period == 'year') {
              var now = DateTime.now();
              return timestamp.year == now.year;
            }
          }
          return false;
        }).toList();

        // ตรวจสอบว่า filteredData มีข้อมูลหรือไม่
        if (filteredData.isEmpty) {
          return Center(child: Text('No data available for the selected period.'));
        }

        // คำนวณจำนวนการจองในแต่ละช่วงเวลา
        Map<String, int> periodCounts = _initializePeriodCounts(period);

        for (var doc in filteredData) {
          var docData = doc.data() as Map<String, dynamic>;
          var key = _getPeriodKey(period, docData);
          var count = docData['count'] as int;

          periodCounts[key] = (periodCounts[key] ?? 0) + count;
        }

        double maxY = periodCounts.values.fold(0, (prev, count) => count > prev ? count : prev).toDouble();
        int totalCount = periodCounts.values.reduce((a, b) => a + b);

        List<BarChartGroupData> barGroups = _generateBarGroups(period, periodCounts);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'จำนวนการจอง ${_formatPeriod(period)}: $totalCount ครั้ง',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            );
                            Widget text;
                            if (period == 'week') {
                              text = _weekTitles(value.toInt(), style);
                            } else if (period == 'month') {
                              text = _monthTitles(value.toInt(), style);
                            } else {
                              text = _yearTitles(value.toInt(), style);
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: text,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: const Color(0xff37434d),
                        width: 1,
                      ),
                    ),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, int> _initializePeriodCounts(String period) {
    if (period == 'week') {
      return {
        'Mon': 0,
        'Tue': 0,
        'Wed': 0,
        'Thu': 0,
        'Fri': 0,
        'Sat': 0,
        'Sun': 0,
      };
    } else if (period == 'month') {
      return {
        'Week 1': 0,
        'Week 2': 0,
        'Week 3': 0,
        'Week 4': 0,
      };
    } else {
      return Map.fromIterable(
        List.generate(12, (index) => DateFormat('MMMM').format(DateTime(2024, index + 1))),
        key: (item) => item,
        value: (item) => 0,
      );
    }
  }

  String _getPeriodKey(String period, Map<String, dynamic> docData) {
    if (period == 'week') {
      return docData['day'] as String;
    } else if (period == 'month') {
      int weekNumber = ((docData['date'] as Timestamp).toDate().day - 1) ~/ 7 + 1;
      return 'Week $weekNumber';
    } else {
      return DateFormat('MMMM').format((docData['date'] as Timestamp).toDate());
    }
  }

  List<BarChartGroupData> _generateBarGroups(String period, Map<String, int> periodCounts) {
    List<BarChartGroupData> barGroups = [];

    for (var i = 0; i < periodCounts.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: periodCounts.values.elementAt(i).toDouble(),
              color: Color.fromARGB(255, 255, 132, 31),
              width: 16,
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  Widget _weekTitles(int value, TextStyle style) {
    switch (value) {
      case 0:
        return Text('Mon', style: style);
      case 1:
        return Text('Tue', style: style);
      case 2:
        return Text('Wed', style: style);
      case 3:
        return Text('Thu', style: style);
      case 4:
        return Text('Fri', style: style);
      case 5:
        return Text('Sat', style: style);
      case 6:
        return Text('Sun', style: style);
      default:
        return Text('', style: style);
    }
  }

  Widget _monthTitles(int value, TextStyle style) {
    return Text('Week ${value + 1}', style: style);
  }

  Widget _yearTitles(int value, TextStyle style) {
    switch (value) {
      case 0:
        return Text('Jan', style: style);
      case 1:
        return Text('Feb', style: style);
      case 2:
        return Text('Mar', style: style);
      case 3:
        return Text('Apr', style: style);
      case 4:
        return Text('May', style: style);
      case 5:
        return Text('Jun', style: style);
      case 6:
        return Text('Jul', style: style);
      case 7:
        return Text('Aug', style: style);
      case 8:
        return Text('Sep', style: style);
      case 9:
        return Text('Oct', style: style);
      case 10:
        return Text('Nov', style: style);
      case 11:
        return Text('Dec', style: style);
      default:
        return Text('', style: style);
    }
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'week':
        return 'สัปดาห์นี้';
      case 'month':
        return 'เดือนนี้';
      case 'year':
        return 'ปีนี้';
      default:
        return '';
    }
  }
}
