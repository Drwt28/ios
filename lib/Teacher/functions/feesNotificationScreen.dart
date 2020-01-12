import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class feesNotificationPage extends StatefulWidget {
  @override
  _feesNotificationPageState createState() => _feesNotificationPageState();
}

class _feesNotificationPageState extends State<feesNotificationPage> {
  List<String> studentId = [];
  List<bool> checkList = [];

  FirebaseMessaging fcm = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Fees'),
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
                      ? buildNotificationList(query.data.documents)
                      : CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            int i = 0;
            for (var c in studentId) {


            }
          },
          child: Icon(Icons.check),
        ));
  }

  Widget buildAttendence(String a) {
    return Text(a, style: TextStyle(fontSize: 30));
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'fees',
      child: Image(
        image: AssetImage('assets/teacher/fees.png'),
      ),
    );
  }

  buildNotificationList(List<DocumentSnapshot> documents) {
    checkList.clear();
    studentId.clear();
    int i = 0;
    for (var c in documents) {
      checkList.add(false);
      studentId.add(documents[i].documentID);
      i++;
    }

    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, i) {
          return CheckboxListTile(
            value: checkList[i],
            onChanged: (val) {
              setState(() {
                if (checkList[i] == false) {
                  studentId.add(documents[i]['id']);
                  checkList[i] = true;
                } else {
                  studentId.remove(documents[i]['id']);
                  checkList[i] = false;
                }
                print(studentId);
              });
            },
            title: Text(i.toString() + documents[i]['name']),
            subtitle: Text(documents[i]['fName']),
            activeColor: Colors.indigo,
          );
        });
  }

  sendFessNotification(String id) {}
}
