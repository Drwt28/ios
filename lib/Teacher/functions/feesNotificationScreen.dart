import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class feesNotificationPage extends StatefulWidget {
  @override
  _feesNotificationPageState createState() => _feesNotificationPageState();
}

class _feesNotificationPageState extends State<feesNotificationPage> {
  TeacherNotification _notification = TeacherNotification();
  List<String> studentId;

  List<bool> CheckList = [];

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
                child: Center(child: buildTopBox()),
              ),
            ),
            Flexible(
              flex: 7,
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('schools')
                    .document(pref.getString('school'))
                    .collection('students')
                    .orderBy('name')
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
              sendFessNotification(c);
              i++;
            }
            if (i == studentId.length) {
              showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Icon(
                      Icons.done_all,
                      color: Colors.greenAccent,
                      size: 50,
                    ),
                    shape:
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    content: Text('Notification Sent to Selected Students'),
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
    CheckList = List.generate(documents.length, (i) => true);

    studentId = List.generate(documents.length, (i) => documents[i].documentID);

    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, i) {
          return NotificationListTile(
            name: documents[i].data['name'],
            fathersName: documents[i]['fName'],
            onChange: (val) {
              if (val) {
                studentId.add(documents[i].documentID);
              }
              else {
                studentId.remove(documents[i].documentID);
              }
            },
          );
        });
  }

  sendFessNotification(String id) {
    _notification.sendNotification(
        'Fee Pending', 'Your Student fees is pending ', id);
  }


}

class NotificationListTile extends StatefulWidget {

  String name, fathersName;

  final Function(bool) onChange;


  @override
  _NotificationListTileState createState() => _NotificationListTileState();


  NotificationListTile({@required this.name, this.fathersName, this.onChange});

}

class _NotificationListTileState extends State<NotificationListTile> {

  bool dec = true;


  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: dec,
      onChanged: (bool value) {
        widget.onChange(!dec);

        setState(() {
          if (dec == false) {
            dec = true;
          } else {
            dec = false;
          }
        });
      },
      title: Text(widget.name),
      subtitle: Text(widget.fathersName),
      activeColor: Colors.indigo,
    );
  }
}

