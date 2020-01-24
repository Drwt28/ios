import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notices extends StatefulWidget {
  @override
  _NoticesState createState() => _NoticesState();
}

//var _option = ['School', 'Teacher', 'Both'];
//var _current = 'School';
class _NoticesState extends State<Notices> {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.lightBlueAccent, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  void showNoticeBox() {
    showDialog(context: context, child: getDialog(), useRootNavigator: true);
  }


  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: customFloatingActionButton(),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('schools/$schoolId/classes')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(text: '', children: [
                      TextSpan(
                        text: 'NO\n',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45),
                      ),
                      TextSpan(
                        text: 'NOTICE\n',
                        style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w400,
                            foreground: Paint()
                              ..shader = linearGradient),
                      ),
                      TextSpan(
                        text: 'Yet',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black26),
                      )
                    ]),
                  ),
                ),
              );
            }
            return getSectionList(snapshot.data.documents);
          }),
    );
  }

  getSectionList(List<DocumentSnapshot> documents) {
    return Stack(children: <Widget>[
      ListView(
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        shrinkWrap: true,
        children: List<Widget>.generate(
          documents.length,
              (int index) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.black12)),
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              margin: EdgeInsets.symmetric(vertical: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    '${documents[index]['notice']}',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 16.0, color: Colors.black),
                  ),
                  Text(
                    '${documents[index]['className'] +
                        documents[index]['section']}',
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  Text(
                    '${documents[index]['teacherName']}',
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }

  customFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoButton(
        color: Colors.blue,
          child: Text(
            'ADD NOTICE',
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        onPressed: showNoticeBox,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
      ),
    );
  }

  TextEditingController noticeController = TextEditingController();
  getDialog() {
    var pref = Provider.of<SharedPreferences>(context);
    String id = pref.getString('school');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text('Type your notice'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(

                    controller: noticeController,
                    decoration: InputDecoration(hintText: 'Notice'),
                    minLines: 1,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    autofocus: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textColor: Colors.blue,
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.blue,
          child: Text('SEND'),
          onPressed: () {
            sendNotice(noticeController.text, id);
          },
        ),
      ],
    );
  }

  sendNotice(String text, String id) async {
    QuerySnapshot list = await Firestore.instance.collection(
        'schools/$id/classes').getDocuments();
    int i = 0;
    for (var doc in list.documents) {
      doc.reference.updateData({'notice': text}).then((val) => i++);
    }


    Navigator.pop(context);
    showSuccesfullNotice();
  }

  showSuccesfullNotice() {
    showDialog(context: context, child: AlertDialog(
      content: Text('Notice sent Succesfully to Teacher and Students'),
      title: Image(
        image: AssetImage('assets/teacher/notice.png'), width: 80, height: 80,),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)), actions: <Widget>[
      FlatButton(
        child: Text('ok'),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ],));
  }
}
