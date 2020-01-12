import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/Database/db.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Services/Student.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendencePage extends StatefulWidget {
  String tag;

  Map<dynamic, dynamic> map;

  AttendencePage({@required this.map});

  @override
  _AttendencePageState createState() => _AttendencePageState();
}

class _AttendencePageState extends State<AttendencePage> {
  var _db = DatabaseService();

  var _notification = TeacherNotification();
  List<Student> students = [];
  Color selectColor = Colors.blue;

  List<String> absentList = List(),
      presentList = List(),
      leaveList = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools')
            .document(pref.getString('school'))
            .collection('students')
            .where('classId', isEqualTo: user.email)
            .snapshots(),
        builder: (context, query) {
          return (query.data != null && query.data.documents.length > 0)
              ? Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  primary: true,
                  expandedHeight:
                  MediaQuery
                      .of(context)
                      .size
                      .height * 0.4,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    title: Text(
                      'Attendence',
                      style: TextStyle(color: Colors.black),
                    ),
                    background: Center(
                      child: SizedBox(
                          height: 200, width: 200, child: buildTopBox()),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                          buildAttendenceTile(query.data.documents[i], i),
                      childCount: query.data.documents.length),
                )
              ],
            ),
            persistentFooterButtons: <Widget>[
              SafeArea(
                  child: RaisedButton(
                    onPressed: () {
                      updateAttendece(pref.getString('school'),
                          query.data.documents, user.email);
                    },
                    textColor: Colors.white,
                    color: Colors.lightBlue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Take Attendence'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.done_all),
                        )
                      ],
                    ),
                  ))
            ],
          )
              : CircularProgressIndicator();
        });
  }

  static List<bool> triple = [false, false, false];
  List<List<bool>> isSelected =
  List.generate(200, (_) => [false, false, false]);

  Widget buildAttendenceTile(DocumentSnapshot snap, int i) {
    return ListTile(
      title: Text("\t" + snap.data['name']),
      trailing: ToggleButtons(
        fillColor: Colors.white,
        disabledColor: Colors.black12,
        selectedBorderColor: Colors.blue,
        borderRadius: BorderRadius.circular(2),
        selectedColor: selectColor,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: buildAttendence("A"),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: buildAttendence("P"),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: buildAttendence('L'),
          )
        ],
        onPressed: (int index) {
          setState(() {
            int j = 0;
            for (var c in isSelected[i]) {
              if (isSelected[i][j]) {
                isSelected[i][j] = false;
              }
              j++;
            }
            isSelected[i][index] = true;
            if (index == 0) {
              absentList.add(snap.data['id']);
              presentList.remove(snap.data['id']);
              leaveList.remove(snap.data['id']);
            } else if (index == 1) {
              presentList.add(snap.data['id']);
              absentList.remove(snap.data['id']);
              leaveList.remove(snap.data['id']);
            } else {
              leaveList.add(snap.data['id']);
              presentList.remove(snap.data['id']);
              absentList.remove(snap.data['id']);
            }
          });
        },
        isSelected: isSelected[i],
      ),
    );
  }

  Widget buildAttendence(String a) {
    return Text(a, style: TextStyle(fontSize: 28));
  }

  buildWidget() {}

  Widget buildTopBox() {
    return Hero(
      tag: 'attendence',
      child: Image(
        image: AssetImage('assets/teacher/attendence.png'),
      ),
    );
  }

  void getStudentsData(String classId, schoolId) {
    setState(() {
      this.students = _db.getStudents(classId, schoolId);
    });

    print(students);
  }

//
//  StreamBuilder<QuerySnapshot>(
//  stream: Firestore.instance.collection('schools').document(pref.getString('school'))
//      .collection('students').where('classId',isEqualTo:"1" ).snapshots(),
//
//  builder: (context,snapshots)
//  {
//  return
//  ListView.builder(
//  itemCount: 30,
//  itemBuilder: (context,index){
//  return buildAttendenceList('name', index);
//  });
//
//  },
//  )

  var month = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    "MAY",
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    "DEC"
  ];
  updateAttendece(String schoolid, List<DocumentSnapshot> snap,
      String classId) {
    var db = Firestore.instance.collection('schools/$schoolid/students');

    for (var doc in snap) {
      var id = doc.documentID;

      var name = doc.data['name'];

      if (absentList.contains(id)) {
        var list = new List<dynamic>.from(doc.data['absentList']);
        list.add(DateTime.now());

        db.document(id).updateData({'absentList': list});
        _notification.sendNotification(
            "Attendence", '$name is absent in todays class ', id);

      } else if (presentList.contains(id)) {
        var list = new List<dynamic>.from(doc.data['presentList']);
        list.add(DateTime.now());

        db.document(id).updateData({'presentList': list});
      } else if (leaveList.contains(id)) {
        var list = new List<dynamic>.from(doc.data['leaveList']);
        list.add(DateTime.now());

        db.document(id).updateData({'leaveList': list});
      }
    }
    CustomWidgets.getTimeFromString(DateTime.now());

    Map<String, int> map = Map.from(widget.map);

    var d = DateTime.now();
    String date = d.day.toString() + "\t" + month[d.month - 1];

    map[date] =
        presentList.length;
    Firestore.instance
        .document('schools/$schoolid/classes/$classId')
        .updateData({
      'attendenceList': map,
      'presentStudents': presentList.length.toString()
    })
        .then((val) {

    })
        .catchError((error) {
      print(error);
    });
    showDialog(
        context: context,
        child: AlertDialog(
          title: Icon(
            Icons.done_all,
            color: Colors.greenAccent,
            size: 50,
          ),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text('Attendence taken succesfully'),
          actions: <Widget>[
            FlatButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }
}
