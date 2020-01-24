import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Student/StudentChatPage.dart';
import 'package:school_magna/Teacher/TeacherChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class createStudentChat extends StatefulWidget {
  @override
  _createStudentChatState createState() => _createStudentChatState();
}

class _createStudentChatState extends State<createStudentChat> {
  NoticationService _noticationService = NoticationService();

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    var user = Provider.of<FirebaseUser>(context);

    String schoolId = pref.getString('school');

    String id = pref.getString('principal');

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools/$schoolId/students')
            .where('classId', isEqualTo: user.email)
            .snapshots(),
        builder: (context, query) => query.hasData
            ? buildChatList(query.data.documents, id, schoolId)
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  buildChatList(List<DocumentSnapshot> snap, String principalId, schoolId) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return ListView.builder(
        itemCount: snap.length,
        itemBuilder: (context, i) => Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(
                  snap[i].data['name'],
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  snap[i].data['name'] + "\t\t" + snap[i].data['fName'],
                  style: TextStyle(color: Colors.black87),
                ),
                trailing: Icon(Icons.message, color: Colors.indigo),
                onTap: () {
                  pref.setString('studentName', snap[i].data['name']);
                  createChatDocument(snap[i].documentID, user.email, schoolId,
                      i.toString() + "\t" + snap[i].data['name']);
                },
              ),
            ));
  }

  void createChatDocument(
      String documentID, String teacherId, String schoolId, String name) {
    String id = documentID;
    DocumentReference ref =
        Firestore.instance.document('schools/$schoolId/chat/$documentID');
    List<String> users = [documentID, teacherId];

    var pref = Provider.of<SharedPreferences>(context);
    String topic = teacherId.substring(0, teacherId.indexOf("@")) + documentID;
    _noticationService.saveUserToken(topic);

    topic = documentID + teacherId.substring(0, teacherId.indexOf("@"));
    pref.setString('topic', topic);

    ref
        .setData(({'users': users, 'count': 0, 'name': name}))
        .then((val) => print('done'))
        .then((val) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StudentChatScreen(
                  classId: teacherId, studentId: documentID)));
    });
  }
}
