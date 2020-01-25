import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadResult extends StatefulWidget {
  String resultName;
  var stdId;
  String studentName;
  var sub = [];

  UploadResult(
      {@required this.resultName, this.stdId, this.sub, this.studentName});

  @override
  _UploadResultState createState() => _UploadResultState();
}

class _UploadResultState extends State<UploadResult> {
  Map<String, dynamic> marks = Map();
  TextEditingController maxMarks = TextEditingController();
  TeacherNotification notification = TeacherNotification();
  List<TextEditingController> controllers = List<TextEditingController>();
  final _formKey = GlobalKey<FormState>();
  String max = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.studentName),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Result Name \t' + widget.resultName,
                  style: TextStyle(color: Colors.indigo, fontSize: 17),
                ),
              )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 60.0),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: maxMarks,
                  onChanged: (val) {
                    setState(() {
                      max = val;
                    });
                  },
                  keyboardType: TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  decoration: InputDecoration(
                      labelStyle: TextStyle(fontSize: 20),
                      labelText: 'Enter Max Marks',
                      hintText: 'eg 100',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Colors.indigo, width: 1.0))),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.sub.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                          width: 100,
                          child: Text(
                            '${widget.sub[index]} :',
                            style: TextStyle(letterSpacing: 2.0),
                          )),
                      trailing: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "/" + max,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Center(
                          child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          onChanged: (value) {
                            marks[widget.sub[index]] = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter marks';
                            }
                            if (int.parse(value) < 0) {
                              return 'Enter marks greater than 0';
                            }
                            return int.parse(value) > int.parse(maxMarks.text)
                                ? 'Enter marks less than ${maxMarks.text}'
                                : null;
                          },
                          decoration: InputDecoration(
                              labelText: 'Enter Marks Obtained'),
                          textAlign: TextAlign.justify,
                        ),
                      )),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ),
              customButton()
            ],
          ),
        ));
  }

  customButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('UPLOAD'),
        onPressed: () {
          setState(() {
            if (_formKey.currentState.validate()) {
              uploadResult(context, marks);
            }
          });
        },
      ),
    );
  }

  uploadResult(context, Map marks) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    String topic = user.email.substring(0, user.email.indexOf('@'));
    String schoolId = pref.getString('school');
    DocumentReference ref = Firestore.instance
        .collection('schools/$schoolId/students/${widget.stdId}/result')
        .document(widget.resultName);
    Map<String, dynamic> dataMap = Map<String, dynamic>();
    dataMap['name'] = widget.resultName;
    dataMap['time'] = DateTime.now();
    dataMap['subjectList'] = widget.sub;
    dataMap['marks'] = marks;
    dataMap['max'] = maxMarks.text;
    ref.setData(dataMap).then((val) {
      notification.sendNotification(
          '${widget.resultName } result delcared', 'Tap to see your marks',
          topic);
      showDialog(context: context, child: createDialog());
    });
  }

  createDialog() {
    return AlertDialog(
      title: Image(
        height: 80,
        width: 80,
        image: AssetImage('assets/teacher/exam.png'),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(' ${widget.resultName} Result Upload succesfully '),
      actions: <Widget>[
        FlatButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
