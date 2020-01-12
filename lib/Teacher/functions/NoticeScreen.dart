import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  var notice = TextEditingController();
  bool send = false;
  var _notification = TeacherNotification();



  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    var user = Provider.of<FirebaseUser>(context);

    return Scaffold(
        appBar: AppBar(),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,

          children: <Widget>[

            Flexible(
              flex: 1,
              child: SizedBox(
                height: 120,
                width: 120,
                child: buildTopBox(),
              ),
            )
            ,
            Flexible(
                flex: 6,
                child: AnimatedContainer(
                  duration: Duration(seconds: 2),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.5,

                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: notice,
                          decoration: InputDecoration(
                              labelText: 'Enter Notice'

                          ),
                          style: TextStyle(
                              fontSize: 18

                          ),
                        ),
                      ),
                      send ? CircularProgressIndicator() : Container(
                        padding: EdgeInsets.all(30),
                        alignment: Alignment.bottomRight,
                        child: RaisedButton(
                          onPressed: () {
                            sendNotice(user.email, pref.getString('school'),
                                notice.text);
                          },
                          child: Text('Send'),
                          textColor: Colors.white,

                          color: Colors.blue,


                        ),
                      )
                    ],
                  ),


                )
            ),
          ],
        )

    );
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'notice',
      child: Image(
        image: AssetImage('assets/teacher/notice.png'),
      ),
    );
  }

  sendNotice(String id, String schooldId, String noticeText) {
    if (noticeText.isNotEmpty) {
      DocumentReference ref = Firestore.instance.document(
          'schools/$schooldId/classes/$id');

      ref.updateData({'notice': noticeText})
          .then((val) {
        var name = id.substring(0, id.indexOf("@"));
        _notification.sendNotification(
            'New Notice for $name', noticeText, name);
        setState(() {
          send = false;
          ShowDialog('Sent', 'notice succesfully sent to all Students',
              Icon(Icons.check, color: Colors.green, size: 50,));
        });
      });
    }
    else {

    }
  }

  ShowDialog(String title, message, Icon i) {
    showDialog(context: context, child: AlertDialog(

      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      title: i,
      content: Text(message),
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
