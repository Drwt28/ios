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
    return Scaffold(
        appBar: AppBar(
          title: Text('Students List'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 7,
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('schools')
                    .document(pref.getString('school'))
                    .collection('students')
                    .where('classId', isEqualTo: user.email)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> query) {
                  return (query.data != null && query.data.documents.length > 0)
                      ? builStudentList(query.data.documents)
                      : Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ));
  }

  builStudentList(List<DocumentSnapshot> documents) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(5),
        itemCount: documents.length,
        itemBuilder: (context, i) {
          return buildStudentItem(documents[i]);
        });
  }

  buildStudentItem(DocumentSnapshot document) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
                      builder: (context) => UploadResult(
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
                    builder: (context) => UploadResult(
                          resultName: widget.resultName,
                          stdId: document['id'],
                          sub: document['compulsorySubjectList'],
                          studentName: document['name'],
                        )));
          },
        ),
      ),
    );
  }
}
