import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Student/FullScreen.dart';
import 'package:school_magna/Student/StudentChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool dec = false;
  final List ImageList = [
    'https://firebasestorage.googleapis.com/v0/b/schoolmagnatest.appspot.com/o/Events%2Feventstart.jfif?alt=media&token=b75da7c5-0b1c-4fbc-9351-23fd47fcc650',
    'https://firebasestorage.googleapis.com/v0/b/schoolmagnatest.appspot.com/o/Events%2FEvent1.jpg?alt=media&token=6893510b-399d-4eae-a2fd-36beb095d4e0',
    'https://firebasestorage.googleapis.com/v0/b/schoolmagnatest.appspot.com/o/Events%2Fevent2.jfif?alt=media&token=62a7038d-ce35-4c95-913e-1adc697ba692'
  ];
  bool chatLoading = false;

  NoticationService _noticationService = NoticationService();

  String classTeacher;

  String ClassName;
  String notice;

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

                    FutureBuilder<DocumentSnapshot>(
                        future: getTeacherData(),
                        builder: (context, doc) {
                          return !doc.hasData
                              ? Center(child: CircularProgressIndicator())
                              : ListTile(
                              title: Container(
                                width: 50,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Image(
                                        image: AssetImage(
                                            'assets/teacher/student.png'),
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
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  buildDashText(
                                      'Class Teacher:',
                                      doc.data['teacherName'] ?? ''),
                                  buildDashText('Class :', ClassName ??
                                      pref.getString('classId').substring(
                                          0,
                                          pref
                                              .getString('classId')
                                              .indexOf('@'))),
                                  buildDashText("Roll No :",
                                      snapshot.data.data['rollNo']),
                                  buildDashText("Father's Name :",
                                      snapshot.data.data['fName']),
                                  buildDashText("Mother's Name :",
                                      snapshot.data.data['mName']),

                                  buildNotice(doc)
                                  , (snapshot.data.data['remark']
                                      .toString()
                                      .isNotEmpty) ? ListTile(
                                    title: Text(
                                      'Teacher Remark',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data.data['remark'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          letterSpacing: 1.0, fontSize: 16.0),
                                    ),
                                  ) : SizedBox()

                                ],
                              ));
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    Card(
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: chatLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListTile(
                        leading: SizedBox(
                          height: 40,
                          width: 40,
                          child: Image(
                            image: AssetImage(
                                'assets/teacher/teacher.png'),
                          ),
                        ),
                        title: Text('Chat With Class Teacher'),
                        subtitle: Text('tap to see remarks'),
                        trailing: SizedBox(
                          height: 30,
                          width: 30,
                          child: FutureBuilder<int>(
                              future: getChatCounter(snapshot.data.documentID),
                              builder: (context, snap) =>
                              (snap.hasData && snap.data > 0) ? Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.indigo,
                                ),
                                child: Center(
                                    child: Text(
                                      (snap.data).toString(),
                                      style: TextStyle(color: Colors.white),
                                    )),
                              )
                                  : SizedBox()),
                        ),
                        onTap: () {
                          String classId =
                          snapshot.data.data['classId'];
                          String studentid =
                              snapshot.data.documentID;
                          pref.setString('studentName',
                              snapshot.data.data['name']);
                          createChatDocument(studentid, classId,
                              schoolId, snapshot.data.data['name']);

//                          createChatDocument(snapshot.data.data['name'],
//                              snapshot.data.documentID, id, schoolId);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 400,
                      child: Card(
                        color: Colors.grey.shade100,
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
                                itemCount: ImageList.length,
                                itemBuilder: (context, i) {
                                  return buildGalleryImage(i);
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

  Future<int> getChatCounter(String documentId) async {
    var pref = Provider.of<SharedPreferences>(context);
    int count = pref.getInt(documentId);
    var col = await Firestore.instance.collection(
        'schools/${pref.getString('school')}/chat/$documentId/messages')
        .getDocuments();
    int not = col.documents.length;

    return (not - count);
  }
  buildNotice(AsyncSnapshot<DocumentSnapshot> doc) {
    return (doc.data['notice']
        .toString()
        .isEmpty)
        ? ListTile(
      title: Text(
        'Class Notice',
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.indigo,
        ),
      ),
      subtitle: Text(
        'No Notice Sended By School',
        textAlign: TextAlign.center,
        style: TextStyle(letterSpacing: 3.0, fontSize: 16.0),
      ),
    )
        : Padding(
      padding: EdgeInsets.all(2.0),
      child: ListTile(
        title: Text(
          'ClassNotice',
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.indigo),
        ),
        subtitle: Text(
          doc.data['notice'],
          textAlign: TextAlign.center,
          style: TextStyle(letterSpacing: 1.0, fontSize: 16.0),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                )),
            Flexible(
                flex: 1,
                child: Text(val,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    )))
          ]),
    );
  }

  Future<DocumentSnapshot> getTeacherData() async {
    SharedPreferences pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    String classId = pref.getString('classId');

    DocumentSnapshot snap = await Firestore.instance
        .document('schools/$schoolId/classes/$classId')
        .get();

    return snap;
  }

  buildGalleryImage(int i) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FullScreen(image: ImageList[i], tag: 'tag')));
      },
      child: Image(
        fit: BoxFit.scaleDown,
        image: NetworkImage(
          ImageList[i],
        ),
        loadingBuilder: (context, child, progress) {
          return progress == null
              ? child
              : Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.indigo,
              ));
        },
      ),
    );
  }

  createChatDocument(String documentID, String teacherId, String schoolId,
      String name) async {
    String id = documentID;
    DocumentReference ref =
    Firestore.instance.document('schools/$schoolId/chat/$documentID');
    List<String> users = [documentID, teacherId];

    var pref = Provider.of<SharedPreferences>(context);
    String topic = teacherId.substring(0, teacherId.indexOf("@")) + documentID;
    _noticationService.saveUserToken(topic);

    topic = documentID + teacherId.substring(0, teacherId.indexOf("@"));
    pref.setString('topic', topic);

    var snap = await ref.get();
    if (!snap.exists) {
      setState(() {
        chatLoading = true;
      });
      ref
          .setData(({'users': users, 'count': 0, 'name': name}))
          .then((val) => print('done'))
          .then((val) {
        setState(() {
          chatLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StudentChatScreen(
                        classId: teacherId, studentId: documentID)));
      });
    } else {
      setState(() {
        chatLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StudentChatScreen(
                      classId: teacherId, studentId: documentID)));
    }
  }
}
