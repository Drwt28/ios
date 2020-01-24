import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Services/Class.dart';
import 'package:school_magna/Student/FullScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherRecentHomework extends StatefulWidget {
  List list = [];

  TeacherRecentHomework({@required this.list});

  @override
  _TeacherRecentHomeworkState createState() => _TeacherRecentHomeworkState();
}

class _TeacherRecentHomeworkState extends State<TeacherRecentHomework> {
  PageController controller = PageController();

  ScrollController listViewController = ScrollController();

  List<HomeWork> homeworkList = new List();

  List<String> dayList = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thrusday',
    'Friday',
    'Saturday'
  ];

  int currentItem;

  @override
  Widget build(BuildContext context) {
    print(widget.list);
    var pref = Provider.of<SharedPreferences>(context);
    var user = Provider.of<FirebaseUser>(context);
    List subjectList = widget.list;

    String id = pref.getString('Student');
    String schoolId = pref.getString('school');
    String classId = user.email;
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .document('schools/$schoolId/classes/$classId')
            .snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Recent Homework'),
            ),
            body: snapshot.hasData
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: subjectList.length,
                    controller: controller,
                    itemBuilder: (context, i) => (snapshot
                                .data.data[subjectList[i]] !=
                            null)
                        ? buildHomeworkPages(snapshot.data.data[subjectList[i]])
                        : SizedBox())
                : SizedBox(
                    height: 200,
                    width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/teacher/teacher.png'),
                        ),
                        Text('No HomeWork sent yet')
                      ],
                    ),
                  ),
          );
        });
  }

  buildTopBarText(text, i) {
    return GestureDetector(
      onTap: () {
        controller.animateToPage(i,
            duration: Duration(milliseconds: 500), curve: Curves.decelerate);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  buildTopBarSelectedText(text, int i) {
    print(controller.page);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 30, color: Colors.indigo, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  buildHomeworkPages(Map homework) {
    var list = homework['image'];

    String time = CustomWidgets.getTime(homework['time']);

    String homeworkText = homework['text'];

    String day = homework['day'];

    String subjectName = homework['name'];

    HomeWork h = HomeWork(
        day: day, images: list, subject: subjectName, text: homeworkText);

    return Card(
      borderOnForeground: true,
      margin: EdgeInsets.all(5),
      child: ListTile(
        title: Text(
          h.subject,
          style: TextStyle(fontSize: 20, color: Colors.indigoAccent),
          textAlign: TextAlign.center,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Publised on\t" + h.day + time,
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width * .9,
                child: Hero(
                  tag: h.subject,
                  child: Image(
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width * .9,
                    image: NetworkImage(h.images[0]),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                h.text,
                style: TextStyle(fontSize: 16, color: Colors.black),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullScreen(
                        image: h.images[0],
                        tag: h.subject,
                      )));
        },
      ),
    );
  }
}

class HomeWork {
  HomeWork({this.subject, this.text, this.day, this.images});

  String subject, text, day;
  List images;
}

class HomeWorkPage extends StatelessWidget {
  List<HomeWork> list;

  HomeWorkPage({@required this.list});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
