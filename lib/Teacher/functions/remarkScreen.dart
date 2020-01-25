import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemarkPage extends StatefulWidget {
  @override
  _RemarkPageState createState() => _RemarkPageState();
}

class _RemarkPageState extends State<RemarkPage> {

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools')
            .document(pref.getString('school'))
            .collection('students')
            .orderBy('name')
            .where('classId', isEqualTo: user.email)
            .snapshots(),
        builder: (context, query) {
          return (query.data != null && query.data.documents.length > 0)
              ? Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  pinned: true,
                  primary: true,
                  expandedHeight:
                  MediaQuery
                      .of(context)
                      .size
                      .height * 0.3,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    title: Text(
                      'Student Remarks',
                      style: TextStyle(color: Colors.black),
                    ),
                    background: Center(
                      child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Center(child: buildTopBox())),
                    ),
                  ),
                ),
                SliverList(

                  delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        return remarkItem(
                          name: query.data.documents[i]['name'],
                          roll: ((i + 1).toString()),
                          id: query.data.documents[i].documentID,
                        );
                      },
                      childCount: query.data.documents.length),
                )
              ],
            ),

          )
              : Scaffold(body: Center(child: CircularProgressIndicator()));
        });
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'remark',
      child: Image(
        image: AssetImage('assets/teacher/remark.png'),
      ),
    );
  }

  buildRemarkList(List<DocumentSnapshot> documents) {
    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return remarkItem(
            name: documents[index]['name'],
            roll: ((index + 1).toString()),
            id: documents[index].documentID,
          );
        });
  }

  buildRemarkItem(String name, rollno) {}
}

class remarkItem extends StatefulWidget {
  String name, roll, id;

  remarkItem({@required this.name, this.roll, this.id});

  @override
  _remarkItemState createState() => _remarkItemState();
}

class _remarkItemState extends State<remarkItem> {
  bool send = false,
      sending = false;

  TeacherNotification teacherNotification = TeacherNotification();
  final _formKey = GlobalKey<FormState>();


  TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    String rollNo = widget.roll;
    String name = widget.name;
    String id = widget.id;

    return send
        ? ListTile(
      title: Text('remark succesfully sent for $name'),
      trailing: Icon(
        Icons.done_all,
        color: Colors.greenAccent,
        size: 30,
      ),
    )
        : ListTile(
      title: Text(
        rollNo + "\t" + name, style: TextStyle(color: Colors.indigo),),
      isThreeLine: true,
      contentPadding: EdgeInsets.all(5),
      subtitle: TextFormField(
        maxLines: 10,
        minLines: 1,

        controller: _editingController,
        validator: (val) {
          if (val.isEmpty) {
            return "enter remark";
          }
          return null;
        },
        decoration: InputDecoration(labelText: 'enter remark'),
      ),
      trailing: sending
          ? CircularProgressIndicator()
          : IconButton(
        onPressed: () {
          sendRemark(
              pref.getString('school'), _editingController.text, id);
        },
        icon: Icon(Icons.send),
        color: Colors.blue,
      ),
    );
  }

  sendRemark(String schoolId, String remark, String studentId) {
    if (remark.isNotEmpty) {
      setState(() {
        sending = true;
      });
      String id = widget.id;
      Firestore.instance
          .document("schools/$schoolId/students/$id")
          .updateData({'remark': remark}).then((val) {
        setState(() {
          send = true;
          sending = false;

          teacherNotification.sendNotification(
              'Remark From teacher', remark, studentId);

        });
      });
    }
    else {

    }
  }
}
