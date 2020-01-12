import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Remark'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: SizedBox(
                height: 90,
                width: 90,
                child: buildTopBox(),
              ),
            ),
            Flexible(
              flex: 7,
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('schools')
                    .document(pref.getString('school'))
                    .collection('students')
                    .where('classId', isEqualTo: user.email)
                    .snapshots(),
                builder: (context, query) {
                  return (query.data != null && query.data.documents.length > 0)
                      ? buildRemarkList(query.data.documents)
                      : CircularProgressIndicator();
                },
              ),
            ),
          ],
        ));
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
            roll: index.toString(),
            id: documents[index]['id'],
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
              pref.getString('school'), _editingController.text);
        },
        icon: Icon(Icons.send),
        color: Colors.blue,
      ),
    );
  }

  sendRemark(String schoolId, String remark) {
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
        });
      });
    }
    else {

    }
  }
}
