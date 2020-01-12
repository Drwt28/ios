import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/SpalshScreen.dart';
import 'package:school_magna/Student/StudentInfo/Homework/detailHomeWorkPage.dart';
import 'package:school_magna/Principal/principal_page.dart';
import 'package:school_magna/Student/StudentInfo/student_home_page.dart';
import 'package:school_magna/Student/studentHomeScreen.dart';
import 'package:school_magna/Teacher/functions/homeWork.dart';
import 'package:school_magna/Teacher/teacherHome.dart';
import 'package:school_magna/selectPanel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  String pref = 'data',
      user = 'data';
  SharedPreferences.getInstance().then((val) {
    pref = val.getString('school');
  });
  FirebaseAuth.instance.currentUser().then((val) {
    user = val.email;
  });

  runApp(MultiProvider(
    providers: [
      StreamProvider<FirebaseUser>.value(
        value: FirebaseAuth.instance.onAuthStateChanged,
      ),
      StreamProvider<SharedPreferences>.value(
          value: SharedPreferences.getInstance().asStream()),
      StreamProvider<DocumentSnapshot>.value(
          value: Firestore.instance
              .collection('schools')
              .document(pref)
              .collection('classes')
              .document(user)
              .snapshots())
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          backgroundColor: Colors.white,

          appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              textTheme: TextTheme(
                  title: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  )),
              iconTheme: IconThemeData(color: Colors.black),
              actionsIconTheme: IconThemeData(color: Colors.black)),
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.blue, splashColor: Colors.indigo)),
      home: MyApp(),
      title: 'School Magna',
    ),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String name;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkForLogin();
  }


  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    return WillPopScope(
        onWillPop: _onWillPop,
        child: buildPage()
    );
  }

  Widget buildSchoolListcard(int i, List<DocumentSnapshot> documents) {
    SharedPreferences sharedPreferences =
    Provider.of<SharedPreferences>(context);

    return GestureDetector(
        onTap: () {
          sharedPreferences
              .setString("school", documents[i]['id'])
              .then((bool val) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SelectionPanel(i)));
          });
        },
        child: CustomWidgets.SchoolPannelCard(
            context,
            documents[i]['logo'],
            documents[i]['name'],
            documents[i]['address'],
            Colors.blue,
            Colors.indigo,
            i));
  }

  void checkForLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var user = await auth.currentUser();

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => TeacherHomePage()
      ));
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  Widget buildPage() {
    var pref = Provider.of<SharedPreferences>(context);

    if (pref.getString('Student') != null) {
      return StudentHome();
    }
    else if (pref.getString('Principal') != null) {
      return PrincipalHomeScreen();
    }
    else {
      return Scaffold(
        body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("schools").snapshots(),
              builder: (context, snapshots) =>
              (snapshots.hasData)
                  ? CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    actions: <Widget>[
                      IconButton(icon: Icon(Icons.search, color: Colors.white)

                        , onPressed: () {

                        },)
                    ],
                    floating: true,
                    expandedHeight:
                    MediaQuery
                        .of(context)
                        .size
                        .height * 0.34,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.pin,
                      title: Text(
                        'Select Your School',
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50))),
                      ),
                    ),

                  ),
                  SliverList(
                    delegate:
                    SliverChildBuilderDelegate((context, i) {
                      return buildSchoolListcard(i,
                          snapshots.data.documents);
                    }, childCount: snapshots.data.documents.length),
                  )
                ],
              )
                  : CircularProgressIndicator()),
        ),
      );
    }
  }
}
