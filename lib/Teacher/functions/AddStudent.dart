import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Services/Student.dart';
import 'package:school_magna/Teacher/teacherHome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddStudentPage extends StatelessWidget {
  List<dynamic> subList = List();


  AddStudentPage(this.subList);

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
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Hero(
                tag: 'add',
                child: Image(
                  height: 80,
                  width: 80,
                  image: AssetImage('assets/teacher/add.png'),
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

  void addData(String Sname, String Fname, String Mname, id, schoolId,
      BuildContext context) {
    CollectionReference collectionReference = Firestore.instance
        .collection('schools')
        .document(schoolId)
        .collection('students');

    String studentId = Sname.trim().toLowerCase() + Fname.toLowerCase().trim() +
        Mname.toLowerCase().trim();

    Map map = Map<String, dynamic>();

    Student student = Student(
        '1',
        Sname.toLowerCase().trim(),
        Fname.toLowerCase().trim(),
        Mname.toLowerCase().trim(),
        '',
        studentId,
        id,
        id,
        DateTime.now(),
        List<Timestamp>(),
        List<Timestamp>(),
        List<Timestamp>(),
        '',
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
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                title: Text('Well done'),
                content: Text('Student Succesfully Added to class'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) => TeacherHomePage()
                      ));
                    },
                    child: Text('done'),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.blue,
                    child: Text('Add Another'),
                  )
                ],
              ));
    });
  }

}
