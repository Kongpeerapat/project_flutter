import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/adminconfirem.dart';

class Admingroup extends StatefulWidget {
  final String userId;
  final String teamId;

  Admingroup({Key? key, required this.userId, required this.teamId})
      : super(key: key);

  @override
  State<Admingroup> createState() => _AdmingroupState();
}

class _AdmingroupState extends State<Admingroup> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _refreshMembers() async {
    setState(() {});
  }

  Future<void> _showDeleteConfirmationDialog(String memberId, bool isMember) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ลบสมาชิก'),
          content: const Text('คุณเเนใจที่จะลบสมาชิกคนนี้ใช่ไหม'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('ยืนยัน'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteMember(memberId, isMember); // Perform the delete action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMember(String memberId, bool isMember) async {
    try {
      // Check if the user is admin before allowing deletion
      if (isMember) {
        // Check if trying to delete self (prevent self-deletion)
        if (memberId == widget.userId) {
          print("Cannot delete yourself from the team.");
          return;
        }

        await FirebaseFirestore.instance
            .collection('team')
            .doc(widget.teamId)
            .collection('members')
            .doc(memberId)
            .delete();
        print("Member deleted successfully");

        // Update user limit after deleting a member
        await _updateUserLimit();
      } else {
        print("Only admins can delete members");
      }
    } catch (e) {
      print("Error deleting member: $e");
    }
  }

  Future<void> _updateUserLimit() async {
    try {
      DocumentSnapshot teamDoc = await FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamId)
          .get();

      if (teamDoc.exists) {
        int userLimit = int.parse(teamDoc['quantityuserLimit']);
        userLimit += 1;

        await FirebaseFirestore.instance
            .collection('team')
            .doc(widget.teamId)
            .update({
          'quantityuserLimit': userLimit.toString(),
        });
        print("User limit updated successfully");
      } else {
        print("Team document does not exist");
      }
    } catch (e) {
      print("Error updating user limit: $e");
    }
  }

  Future<void> _deleteUserFromCollections(String memberId) async {
    try {
      // Delete user from members collection
       await FirebaseFirestore.instance
          .collection('team')
          .doc(widget.teamId)
          .collection('members')
          .doc(memberId)
          .delete();

      print("ออกจากทีมเเล้ว");

    } catch (e) {
      print("Error deleting user from collections: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Adminconfirem()));
            },
            icon: const Icon(Icons.group_add),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "จัดการทีม",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMembers,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('team')
              .doc(widget.teamId) 
              .collection('members')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading members'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No members found'));
            }

            var members = snapshot.data!.docs;

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                var memberData = members[index].data() as Map<String, dynamic>;
                var memberId = members[index].id;
                var userName = memberData['namemember'] ?? 'Unknown';
                var profileImage = memberData['memberProfile'] ?? '';
                var isMember = memberData['status_addminteam'] ?? false;

                return Container(
                  width: 380,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 214, 214, 214),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 2, color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircleAvatar(
                          backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                          backgroundColor: Colors.grey,
                          radius: 30,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isMember ? "สมาชิก" : "ผู้ดูเเล",
                            style: TextStyle(
                              fontSize: 16,
                              color: isMember ? Colors.black : Colors.blue,
                              fontWeight: isMember ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Show delete button for all members, but only enable for admins
                      if (isMember == true)
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(memberId, isMember);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
