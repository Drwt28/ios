import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Student/FullScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailHomeWorkPage extends StatefulWidget {
  List list;

  DetailHomeWorkPage({@required this.list});

  @override
  _DetailHomeWorkPageState createState() => _DetailHomeWorkPageState();
}

class _DetailHomeWorkPageState extends State<DetailHomeWorkPage> {
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
        'Sunday'
  ];

  int currentItem;

  @override
  Widget build(BuildContext context) {
    print(widget.list);

    var pref = Provider.of<SharedPreferences>(context);

    List subjectList = pref.getStringList('subjects');
    print(subjectList);

    String id = pref.getString('Student');
    String schoolId = pref.getString('school');
    String classId = pref.getString('classId');
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .document('schools/$schoolId/classes/$classId')
            .snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            body: (snapshot.hasData)
                ? ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: subjectList.length,
              controller: controller,
              itemBuilder: (context, i) =>
              (snapshot
                  .data.data[subjectList[i]] !=
                  null)
                  ? buildHomeworkPages(snapshot.data.data[subjectList[i]])
                  : SizedBox(
                  child: Card(
                      child: ListTile(
                        title: Text('${subjectList[i]}'),
                        subtitle: Text('No HomeWork'),
                      ))),
            )
                : Center(
              child: CircularProgressIndicator(),
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
      elevation: 3.0,
      color: Colors.grey.shade100,
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
                "Publised on\t" + time,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              SizedBox(
                height: 10,
              ),
              (h.images != null && h.images.length > 0) ? SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width * .9,
                child: Hero(
                  tag: h.subject,
                  child: Image(
                    fit: BoxFit.fitWidth,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * .9,
                    image: NetworkImage(h.images[0]),
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : Center(
                          child: LinearProgressIndicator(
                            value: ((progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes) * 100),

                          ));
                    },
                  ),
                ),
              ) : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Text(
                h.text,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        onTap: () {
          if ((h.images != null && h.images.length > 0))
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FullScreen(
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
