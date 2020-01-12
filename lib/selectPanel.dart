import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Teacher/teacher_login.dart';
import 'package:school_magna/Model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Student/studentLoginPage.dart';
import 'package:school_magna/Teacher/teacherHome.dart';


class SelectionPanel extends StatelessWidget {
  int i;

  SelectionPanel(this.i);

  Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.lightBlue, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100, 10.0));

  @override
  Widget build(BuildContext context) {
    var sharedPreferences = Provider.of<SharedPreferences>(context);

    String id = sharedPreferences.getString('school') ?? '';

    id = id.substring(0, id.indexOf("@")).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info, color: Colors.indigo),
              onPressed: () {}

            //show help Dialog

          )
        ],
        elevation: 0,
        backgroundColor: Colors.white,

        title: Text(
            id,

            style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 27, foreground: Paint()
              ..shader = linearGradient,)),
        ),

      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StudentPanel()));
                    },
                    child: CustomWidgets.SelectionPannelCard(
                        context,
                        "Parents",
                        'assets/parent/parents.png',
                        Colors.indigoAccent,
                        Colors.indigo, 'parents')),
              ),
              Flexible(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => teacher_login()));
                    },
                    child: CustomWidgets.SelectionPannelCard(
                        context,
                        "Teacher",
                        'assets/teacher/teacher.png',
                        Colors.lightBlue,
                        Colors.blueAccent, 'teacher')),
              )
            ],
          ),
        ),
      ),
    );
  }

}
