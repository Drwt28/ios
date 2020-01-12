import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Services/Student.dart';
import 'package:school_magna/Teacher/classBuilderScreen.dart';
import 'package:school_magna/Teacher/teacherHome.dart';
import 'package:school_magna/Principal/principal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class teacher_login extends StatefulWidget {
  @override
  _teacher_loginState createState() => _teacher_loginState();
}

class _teacher_loginState extends State<teacher_login> {
  FirebaseUser user;
  bool dec = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  NoticationService _noticationService = NoticationService();

  FirebaseAuth _auth;

  String _e, _p;
  String designation;

  @override
  initState() {
    super.initState();

    _auth = FirebaseAuth.instance;

    //   checkForSignIn();
  }

  Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.lightBlue, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100, 10.0));

  @override
  Widget build(BuildContext context) {
    user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);

    String id = pref.getString('school');

    String title = id.substring(0, id.indexOf("@")).toUpperCase();
    bool show = true;

    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.document('schools/$id').snapshots(),
        builder: (context, snapshot) {
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
              title: Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 27,
                    foreground: Paint()
                      ..shader = linearGradient,
                  )),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.clear),
              backgroundColor: !dec ? Colors.white : Colors.blue,
              onPressed: () {
                setState(() {
                  dec = false;
                });
              },
              elevation: 0,
            ),
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 130, width: 130, child: buildTopBox()),
                  (!snapshot.hasData)
                      ? CircularProgressIndicator()
                      : Center(
                    widthFactor: MediaQuery
                        .of(context)
                        .size
                        .width * 0.85,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: email,
                              style: TextStyle(fontSize: 18),
                              obscureText: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(20)),
                                labelText: 'Login Id',
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: password,
                              obscureText: dec,
                              enableInteractiveSelection: true,
                              style: TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(20)),
                                labelText: 'Password',
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: buildClassDropDown(context),
                              ),
                            ),
                            SizedBox(height: 10),
                            dec
                                ? CircularProgressIndicator()
                                : Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width *
                                  0.5,
                              child: CupertinoButton(
                                color: Colors.blue,
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  SignIn(
                                      snapshot.data.data['id'],
                                      snapshot
                                          .data.data['password']);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'teacher',
      child: Image(
        image: AssetImage('assets/teacher/teacher.png'),
      ),
    );
  }

  Widget buildClassDropDown(BuildContext context) {
    return SizedBox(
        height: 50,
        child: DropdownButton<String>(
          value: designation,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.blue,
          ),
          iconSize: 28,
          hint: Text(
            "Select Your Designation ",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          elevation: 16,
          style: TextStyle(color: Colors.indigo),
          underline: Container(
            height: 1,
            color: Colors.blue,
          ),
          onChanged: (String newValue) {
            setState(() {
              designation = newValue;
            });
          },
          items: <String>['Teacher', 'Principal']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            );
          }).toList(),
        ));
  }

  SignIn(String principalId, String pass) async {
    var pref = Provider.of<SharedPreferences>(context);
    setState(() {
      dec = true;
    });
    principalId.trim();
    pass.trim();
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      if (designation == null) {
        showDialog(
            context: context, child: getAlertDialog('Select Designation'));
        setState(() {
          dec = false;
        });
      } else {
        if (designation == "Principal") {
          if (principalId.toLowerCase() == email.text.trim().toLowerCase() &&
              pass.toLowerCase() == password.text.trim().toLowerCase()) {
            pref.setString('Principal', principalId.trim().toLowerCase()).then((
                val) {
              _noticationService.saveUserToken(
                  principalId.substring(0, principalId.indexOf("@")));
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => PrincipalHomeScreen()));
            });
          } else {
            setState(() {
              dec = false;
            });
            showDialog(
                context: context,
                useRootNavigator: true,
                child:
                getAlertDialog('Enter Correct Principal Id and Password'));
          }
        }
        if (designation == 'Teacher') {
          _auth
              .signInWithEmailAndPassword(
              email: email.text, password: password.text)
              .then((val) {
            String topic =
                "N" + email.text.substring(0, email.text.indexOf("@"));
            _noticationService.saveUserToken(topic);

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TeacherHomePage()));
          }).catchError((error) {
            setState(() {
              dec = false;
            });

            showDialog(
                context: context,
                child: getAlertDialog('Enter Correct Teacher Id and Password'));
          });
        }
      }
    } else {
      setState(() {
        dec = false;
      });
      showDialog(
          context: context,
          child: getAlertDialog('Enter login Id and Password for login'),
          useRootNavigator: true);
    }
  }

  void principleSignIn(String id, pass) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => PrincipalHomeScreen()));
  }

  getAlertDialog(String mes) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Icon(
        Icons.warning,
        size: 60,
        color: Colors.yellow,
      ),
      content: Text(
        mes,
        style: TextStyle(fontSize: 17),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              dec = false;
            });
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Text('OK'),
          color: Colors.blue,
          textColor: Colors.white,
        )
      ],
    );
  }
}
