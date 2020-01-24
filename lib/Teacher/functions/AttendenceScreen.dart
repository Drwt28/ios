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


  List keyList;

  AttendencePage({@required this.map, this.keyList});

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
                      'Attendance',
                      style: TextStyle(color: Colors.black),
                    ),
                    background: Center(
                      child: SizedBox(
                          height: 100,
                          width: 100,
                          child: Center(child: buildTopBox())),
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
                          child: Text('Take Attendance'),
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



  Widget buildAttendenceTile(DocumentSnapshot snap, int i) {
    return AttendenceTile(rollNo: (i + 1).toString(), name: snap.data['name'],
      onChange: (index) {
        if (index == 0 && !absentList.contains(snap.documentID)) {
          absentList.add(snap.documentID);
          presentList.remove(snap.documentID);
          leaveList.remove(snap.documentID);
        }
        else if (index == 1 && !presentList.contains(snap.documentID)) {
          absentList.remove(snap.documentID);
          presentList.add(snap.documentID);
          leaveList.remove(snap.documentID);
        }
        if (index == 2 && !leaveList.contains(snap.documentID)) {
          absentList.add(snap.documentID);
          presentList.remove(snap.documentID);
          leaveList.add(snap.documentID);
        }
      },);
  }



  buildWidget() {}

  Widget buildTopBox() {
    return Hero(
      tag: 'attendance',
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
    List keyList = List.from(widget.keyList);

    var d = DateTime.now();
    String date = d.day.toString() + "\t" + month[d.month - 1];

    if (!keyList.contains(date)) {
      keyList.add(date);
    }
    map[date] = presentList.length;
    Firestore.instance
        .document('schools/$schoolid/classes/$classId')
        .updateData({
      'lastAttendence': DateTime.now(),
      'attendenceKey': keyList,
      'attendenceList': map,
      'presentStudents': presentList.length.toString()
    })
        .then((val) {})
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

class AttendenceTile extends StatefulWidget {


  final Function(int) onChange;

  String name, rollNo;

  AttendenceTile({@required this.rollNo, this.name, this.onChange});

  @override
  _AttendenceTileState createState() => _AttendenceTileState();
}

class _AttendenceTileState extends State<AttendenceTile> {

  final List<Color> colors = [Colors.red, Colors.green, Colors.blue];

  List<bool> selectedList = [false, false, false];

  Color selectedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.rollNo + "\t" + widget.name),
      trailing: ToggleButtons(
        selectedColor: selectedColor,
        fillColor: Colors.white,
        disabledColor: Colors.black12,
        selectedBorderColor: selectedColor,
        borderWidth: 1.7,
        isSelected: selectedList,
        onPressed: (i) {
          setState(() {
            widget.onChange(i);
            selectedColor = colors[i];

            for (int j = 0; j < 3; j ++) {
              selectedList[j] = false;
            }
            selectedList[i] = true;
          });
        },
        borderRadius: BorderRadius.circular(19),
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

      ),
    );
  }


  Widget buildAttendence(String a) {
    return Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(shape: BoxShape.circle
        ),
        child: Center(child: Text(
            a, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500))));
  }
}

