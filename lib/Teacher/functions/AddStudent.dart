import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Services/Student.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStudentPage extends StatelessWidget {
  List<dynamic> subList = List();

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    FirebaseUser user = Provider.of<FirebaseUser>(context);

    TextEditingController name = TextEditingController(),
        fName = TextEditingController(),
        mName = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'add',
                child: IconButton(
                  icon: Icon(Icons.add, size: 100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextField('Student name', name),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextField('fathers name', fName),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildTextField('mothers name', mName),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        tooltip: 'add student',
        backgroundColor: Colors.indigo,
        onPressed: () {
          addData(name.text, fName.text, mName.text, user.email,
              pref.getString('school'), context);
        },
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController cont) {
    return TextFormField(
      controller: cont,
      decoration: InputDecoration(labelText: hint),
    );
  }

  void addData(String Sname, Fname, Mname, id, schoolId, BuildContext context) {
    CollectionReference collectionReference = Firestore.instance
        .collection('schools')
        .document(schoolId)
        .collection('students');

    String studentId = Sname.trim() + Fname.trim() + Mname.trim();

    Map map = Map<String, dynamic>();

    Student student = Student(
        '1',
        Sname,
        Fname,
        Mname,
        '',
        studentId,
        id,
        id,
        DateTime.now(),
        List<Timestamp>(),
        List<Timestamp>(),
        List<Timestamp>(),
        Map(),
        subList,
        List<String>(),
        List<result>());

    collectionReference
        .document(studentId)
        .setData(Student.toMap(student))
        .whenComplete(() {
      showCupertinoDialog(
          context: context,
          builder: (context) =>
              CupertinoAlertDialog(
                title: Text('Well done'),
                content: Text('Student Succesfully Added to class'),
                actions: <Widget>[
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('done'),
                  ),
                  CupertinoButton(
                    onPressed: () {},
                    color: Colors.blue,
                    child: Text('Add Another'),
                  )
                ],
              ));
    });
  }

  AddStudentPage(this.subList);
}
