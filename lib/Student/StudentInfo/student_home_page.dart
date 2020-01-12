import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Student/StudentChatPage.dart';
import 'package:school_magna/Teacher/TeacherChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool dec = false;

  String classTeacher = "";

  String ClassName = "";
  String notice = "";

  @override
  Widget build(BuildContext context) {
    String id, schoolId, classId;

    var pref = Provider.of<SharedPreferences>(context);

    id = pref.getString('Student');
    schoolId = pref.getString('school');
    classId = pref.getString('classId');
    print(classId);

    return Material(
      color: Colors.grey.shade300,
      child: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .document('schools/' +
              pref.getString('school') +
              "/students/" +
              pref.getString('Student'))
              .snapshots(),
          builder: (context, snapshot) {
            return (!snapshot.hasData)
                ? Scaffold(body: Center(child: CircularProgressIndicator()))
                : Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: Image(
                            image:
                            AssetImage('assets/teacher/student.png'),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          snapshot.data.data['name'],
                          style: TextStyle(fontSize: 25),
                        )
                      ],
                    ),
                    ListTile(
                        title: Container(
                          width: 50,
                          height: 50,
                        ),
                        subtitle: Column(
                          children: <Widget>[
                            buildDashText('Class Teacher:', classTeacher),
                            buildDashText('Class :', className),
                            buildDashText("Roll No :",
                                snapshot.data.data['rollNo']),
                            buildDashText("Father's Name :",
                                snapshot.data.data['fName']),
                            buildDashText("Mother's Name :",
                                snapshot.data.data['mName']),
                          ],
                        )),
                    Card(
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: Firestore.instance
                              .document(
                              'schools/$schoolId/classes/$classId')
                              .snapshots(),
                          builder: (context, doc) {
                            return !doc.hasData
                                ? CircularProgressIndicator()
                                : buildNotice();
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: ListTile(
                        leading: SizedBox(
                          height: 40,
                          width: 40,
                          child: Image(
                            image:
                            AssetImage('assets/teacher/teacher.png'),
                          ),
                        ), title: Text('Chat With Class Teacher'),
                        subtitle: Text('tap to see remarks'),
                        onTap: () {
                          createChatDocument(snapshot.data.data['name'],
                              snapshot.data.documentID, id, schoolId);
                        },
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 400,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'School Event Gallery',
                                  style: TextStyle(
                                      color: Colors.indigo, fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 5,
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                pageSnapping: false,
                                dragStartBehavior:
                                DragStartBehavior.start,
                                itemCount: 4,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: Colors.blue[100],
                                    child: Center(
                                      child: Text('$index'),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  buildNotice() {
    return FutureBuilder(
      future: getTeacherData(),
      builder: (context, doc) =>
      !(doc.hasData)
          ? Padding(
        padding: const EdgeInsets.all(2.0),
        child: ListTile(
          title: Text(
            'Class Notice',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.indigo),
          ),
          subtitle: notice.isEmpty
              ? Text(
            'No notice yet from the school',
            style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w400),
          )
              : Text(
                        notice,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w400),
          ),
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext bc) {
          return CupertinoActionSheet(
            title: Text('Type your reply'),
            message: CupertinoTextField(
              enableInteractiveSelection: true,
              placeholder: 'type reply',
            ),
            cancelButton: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.indigo,
                child: Text('cancel')),
            actions: <Widget>[
              FlatButton(
                splashColor: Colors.yellow,
                onPressed: () {},
                child: Text('The date of parents meeting'),
              ),
              FlatButton(
                splashColor: Colors.yellow,
                onPressed: () {},
                child: Text('Template'),
              ),
              FlatButton(
                splashColor: Colors.yellow,
                onPressed: () {},
                child: Text('This is wrong'),
              )
            ],
          );
        });
  }

  buildHomeWorkLayout(String title, content) {
    print(title);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigoAccent])),
        child: ListTile(
          onTap: () {},
          title: Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          subtitle: Text(
            'Recieved at  $content',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  buildDashText(String title, val) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                flex: 1,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                )),
            Flexible(
                flex: 1,
                child: Text(val,
                    style: TextStyle(color: Colors.black, fontSize: 16)))
          ]),
    );
  }

  String className = "";

  Future<DocumentSnapshot> getTeacherData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String schoolId = pref.getString('school');
    String classId = pref.getString('classId');

    DocumentSnapshot snap = await Firestore.instance
        .document('schools/$schoolId/classes/$classId')
        .get();

    setState(() {
      notice = snap.data['notice'];
      classTeacher = snap.data['teacherName'];
      className = (snap.data['classSection'] + snap.data['section']);
    });

    return snap;
  }

  void createChatDocument(String name,
      String documentID, String id, String schoolId) {
    String id = documentID;
    DocumentReference ref =
    Firestore.instance.document('schools/$schoolId/chat/$documentID');
    print(documentID);
    print(id);


    List<String> users = [id, documentID];

    ref
        .setData(({'users': users, 'count': 0}))
        .then((val) => print('done'))
        .then((val) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => StudentChatScreen(classId: name, id: id)));
    });
  }



}
