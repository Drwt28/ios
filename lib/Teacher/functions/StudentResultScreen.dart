import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Teacher/functions/upload_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentResultPage extends StatefulWidget {
  String resultName;

  @override
  _StudentResultPageState createState() => _StudentResultPageState();

  StudentResultPage({@required this.resultName});
}

class _StudentResultPageState extends State<StudentResultPage> {
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
                      'Result',
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
                          (context, i) =>
                          buildStudentItem(query.data.documents[i]),
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
      tag: 'result',
      child: Image(
        image: AssetImage('assets/teacher/exam.png'),
      ),
    );
  }


  buildStudentItem(DocumentSnapshot document) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Image.asset('assets/teacher/student.png'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              document['name'],
              style: TextStyle(
                  color: Colors.indigo, fontWeight: FontWeight.w500),
            ),
            Text(document['fName']),
          ],
        ),
        trailing: FlatButton(
          child: Text('Upload Result'),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UploadResult(
                          resultName: widget.resultName,
                          stdId: document['id'],
                          sub: document['compulsorySubjectList'],
                          studentName: document['name'],
                        )));
          },
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      UploadResult(
                        resultName: widget.resultName,
                        stdId: document['id'],
                        sub: document['compulsorySubjectList'],
                        studentName: document['name'],
                      )));
        },
      ),
    );
  }
}
