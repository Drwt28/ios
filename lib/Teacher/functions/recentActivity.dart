import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Teacher/functions/RecentHomeWork.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherRecentActivityScreen extends StatefulWidget {
  @override
  _TeacherRecentActivityScreenState createState() =>
      _TeacherRecentActivityScreenState();
}

class _TeacherRecentActivityScreenState
    extends State<TeacherRecentActivityScreen> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    String email = user.email;
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .document('schools/$schoolId/classes/$email')
              .snapshots(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? BuildLayout(snapshot)
                : Center(child: CircularProgressIndicator());
          }),
    );
  }

  BuildLayout(AsyncSnapshot snapshot) {
    Map<String, int> map =
        Map.from(snapshot.data.data['attendenceList']) ?? Map<String, int>();
    List<String> keys =
        List.castFrom(snapshot.data.data['attendenceKey']) ?? List<String>();

    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              title: Text(
                'Last Notice',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                snapshot.data.data['notice'],
                style: TextStyle(color: Colors.indigo, fontSize: 15),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeacherRecentHomework(
                            list: (snapshot.data.data['subjectList']),
                          )));
            },
            title: Text(
              'Last Homeworks',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Tap to saw details'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Last Attendences',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.indigo,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: keys.length,
            itemBuilder: (context, i) {
              return Card(
                child: ListTile(
                  title: Text(keys[i]),
                  subtitle: Text(
                    'Present Students \t\t' + map[keys[i]].toString(),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              );
            })
      ],
    );
  }

  List<Attendence> getDataFromMap(Map map) {
    List<Attendence> attendence = [];
    String s = map.toString();
    int i = map.toString().indexOf(',');
    if (i == -1) {
      i = s.length - 1;
    }
    while (i > 0) {
      try {
        String l = s.substring(0, i);
        attendence.add(Attendence(
            week: l.substring(0, l.indexOf(':')).replaceFirst('{', ""),
            number: map[l
                .substring(0, l.indexOf(':'))
                .toString()
                .replaceFirst("{", "")
                .trim()]));
        s = s.substring(i + 1, s.length - 1);
        i = s.indexOf(',');
        if (i == -1) {
          i = s.length - 1;
        }
        print(s);
      } catch (e) {
        break;
      }
    }
//    for (var a in attendence) {
//      print(a.week + '${a.number}');
//      data.add(Attendence(week: a.week, number: a.number));
//    }
    return attendence;
  }
}

class Attendence {
  Attendence({this.week, this.number});

  final String week;
  final int number;
}
//List<Attendence> getDataFromMap(Map map) {
//  print(map);
//  List<Attendence> a = [];
//  String s = map.toString();
//  int i = map.toString().indexOf(',');
//  if(!s.contains(','))
//  {
//
//    a.add(Attendence(
//        week: s.substring(0, s.indexOf(':')).replaceFirst('{', ""),
//        number: map[s
//            .substring(0, s.indexOf(':'))
//            .toString()
//            .replaceFirst("{", "")
//            .trim()]));
//  }
//  else{
//    while (i > 0) {
//      try {
//        String l = s.substring(0, i);
//        a.add(Attendence(
//            week: l.substring(0, l.indexOf(':')).replaceFirst('{', ""),
//            number: map[l
//                .substring(0, l.indexOf(':'))
//                .toString()
//                .replaceFirst("{", "")
//                .trim()]));
//        s = s.substring(i + 1, s.length - 1);
//        i = s.indexOf(',');
//
//      } catch (e) {
//        print(e);
//        break;
//      }
//    }
//  }
//  print(i);
//  return a;
//}
