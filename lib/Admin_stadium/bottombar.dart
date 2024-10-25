import 'package:flutter/material.dart';
import 'package:user/Admin_stadium/admin_confirmbooking.dart';
import 'package:user/Admin_stadium/admin_graph.dart';
import 'package:user/Admin_stadium/admin_mystadium.dart';
import 'package:user/Admin_stadium/admin_reviwe.dart';
import 'package:user/Admin_stadium/admin_webborad.dart';

class BottomBar extends StatefulWidget {
  final String userId;
  const BottomBar({Key? key, required this.userId}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      AdminMystadium(),
      AdminWebborad(userId: widget.userId),
      Confirmbooking(),
      Graph(),
      Review(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color.fromARGB(255, 255, 94, 0),
            icon: Icon(
              Icons.stadium,
              color: Colors.white,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.document_scanner,
              color: Colors.white,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notification_add,
              color: Colors.white,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.stacked_bar_chart_sharp,
              color: Colors.white,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star_outlined,
              color: Colors.white,
              size: 30,
            ),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PeopleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'สนามของฉัน',
        style: TextStyle(fontSize: 25),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'การเเจ้งเตือนยืนยันการจอง',
        style: TextStyle(fontSize: 25),
      ),
    );
  }
}

class GraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'สถิติการจอง',
        style: TextStyle(fontSize: 25),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'รีวิวสนาม',
        style: TextStyle(fontSize: 25),
      ),
    );
  }
}
