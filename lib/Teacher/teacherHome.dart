import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/Database/db.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Services/Teacher.dart';
import 'package:school_magna/Teacher/TeacherChatPage.dart';
import 'package:school_magna/Teacher/functions/AddStudent.dart';
import 'package:school_magna/Teacher/functions/AttendenceScreen.dart';
import 'package:school_magna/Teacher/functions/NoticeScreen.dart';
import 'package:school_magna/Teacher/functions/feesNotificationScreen.dart';
import 'package:school_magna/Teacher/functions/homeWork.dart';
import 'package:school_magna/Teacher/functions/remarkScreen.dart';
import 'package:school_magna/Teacher/functions/studentListScreen.dart';
import 'package:school_magna/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHomePage extends StatefulWidget {
  @override
  _TeacherHomePageState createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  PageController controller = PageController();
  ScrollController listViewController = ScrollController();
  String title = "title";
  int _currentIndex = 0;

  final List<String> _childrenText = ['Home', 'Chat'];

  Teacher teacher = Teacher();

  int currentItem = 0;

  PageController pageController = PageController(initialPage: 0);

  List<dynamic> subList = List();

  FirebaseUser user;

  final db = DatabaseService();

  NoticationService _notication = NoticationService();

  @override
  void initState() {
    super.initState();
    setState(() {
      getData();
      _notication.saveUserToken("class4f");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ListView.builder(
                        addRepaintBoundaries: true,
                        itemCount: _childrenText.length,
                        controller: listViewController,
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, i) =>
                        !(i == _currentIndex)
                            ? buildTopBarText(_childrenText[i], i)
                            : buildTopBarSelectedText(_childrenText[i], i),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.indigo,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  Container(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                            leading: Icon(Icons.add),
                                            title: Text('Add Student'),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddStudentPage(
                                                              List())));
                                            }),
                                        ListTile(
                                          leading: Icon(Icons.access_alarm),
                                          title: Text('Recent Activity'),
                                          onTap: () {},
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit Class'),
                                          onTap: () {},
                                        ),
                                        ListTile(
                                          title: Text('Log Out'),
                                          onTap: () async {
                                            FirebaseAuth.instance.signOut()
                                                .then((val) {
                                              SharedPreferences.getInstance()
                                                  .then((val) {
                                                val.clear().then((val) {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MyApp()
                                                      ));
                                                });
                                              });
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ));
                        },
                      )
                    ],
                  ),
                )),
            Flexible(
              flex: 8,
              child: PageView.builder(
                  controller: controller,
                  itemCount: _childrenText.length,
                  onPageChanged: (val) {
                    setState(() {
                      _currentIndex = val;
                    });
                  },
                  itemBuilder: (context, i) =>
                  (i == 0)
                      ? HomePage()
                      : ChatPage()),
            )
          ],
        )
    );
  }

  teacherDashBoard(Map<String, dynamic> map) {
//    Class c = Class.fromMap(map);

    var teacher = Provider.of<DocumentSnapshot>(context);

    print(teacher.data.toString());
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(map['className'] + "\t" + map['section'],
              style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          SizedBox(
            height: 10,
          ),
          buildDashboardText('Attendence Date :\t\t' +
              CustomWidgets.getTime(map['lastAttendence'])),
          SizedBox(height: 9),
          buildDashboardText(
              'Present Students :\t' + map['presentStudents'].toString()),
          SizedBox(height: 14),
          buildDashboardText('Last Notice :\t\t' + map['notice']),
        ],
      ),
    );
  }

  Widget buildDashboardText(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w600,
            fontSize: 17));
  }

  Future<String> getData() async {
    var pref = await SharedPreferences.getInstance();
    var user = await FirebaseAuth.instance.currentUser();
    if (pref != null) {
      Firestore.instance
          .document(
          'schools/' + pref.getString('school') + '/classes/' + user.email)
          .get()
          .then((snap) {
        setState(() {
          this.subList = snap.data['subjectList'];
          print(subList);
        });
      });
    }
  }

  final List<String> names = [
    'Notice',
    'Remark',
    'Attendence',
    'Homework',
    'Students',
    'Result'
  ];
  final List<String> iconPaths = [
    'assets/teacher/notice.png',
    'assets/teacher/remark.png',
    'assets/teacher/attendence.png',
    'assets/teacher/homework.png',
    'assets/teacher/student.png',
    'assets/teacher/exam.png'
  ];

  Widget HomePage() {
    user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return Scaffold(
        primary: false,
        backgroundColor: Colors.white,
        body: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('schools')
                .document(pref.getString('school'))
                .collection('classes')
                .document(user.email)
                .snapshots(),
            builder: (context, snapshot) {
              return (!snapshot.hasData)
                  ? CircularProgressIndicator()
                  : CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: false,
                    floating: false,
                    primary: false,
                    leading: SizedBox(),
                    title: Text(
                      snapshot.data.data['teacherName'],
                      style: TextStyle(
                          fontSize: 20,
                          foreground: Paint()
                            ..shader = linearGradient,
                          fontWeight: FontWeight.w500),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    expandedHeight:
                    MediaQuery
                        .of(context)
                        .size
                        .height * 0.28,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 58.0),
                            child: AnimatedContainer(
                              duration: Duration(seconds: 2),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: Firestore.instance
                                    .collection('schools')
                                    .document(pref.getString('school'))
                                    .collection('classes')
                                    .document(user.email)
                                    .snapshots(),
                                builder: (context, snap) {
                                  var s = snap.data;
                                  if (s != null && s.exists)
                                    return teacherDashBoard(
                                        snap.data.data);
                                  else
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverGrid.count(
                    crossAxisCount: 1,
                    childAspectRatio: 3.8,
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    feesNotificationPage()));
                          },
                          child: CustomWidgets
                              .teacherHomePannelCardHeroSingle(
                              context,
                              'Fee Notification',
                              'assets/teacher/fees.png',
                              Colors.blue,
                              Colors.indigo,
                              'fees'))
                    ],
                  ),
                  SliverGrid.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NoticePage()));
                        },
                        child: CustomWidgets.teacherHomePannelCardHero(
                            context,
                            'Notice',
                            'assets/teacher/notice.png',
                            Colors.blue,
                            Colors.lightBlue,
                            'notice'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RemarkPage()));
                        },
                        child: CustomWidgets.teacherHomePannelCardHero(
                            context,
                            'Remarks',
                            'assets/teacher/remark.png',
                            Colors.indigoAccent,
                            Colors.blueAccent,
                            'remark'),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    AttendencePage(
                                      map: snapshot
                                          .data.data['attendenceList'],
                                    )));
                          },
                          child: CustomWidgets.teacherHomePannelCardHero(
                              context,
                              'Attendence',
                              'assets/teacher/attendence.png',
                              Colors.indigoAccent,
                              Colors.indigo,
                              'attendence')),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => homeworkPage()));
                        },
                        child: CustomWidgets.teacherHomePannelCardHero(
                            context,
                            'HomeWork',
                            'assets/teacher/homework.png',
                            Colors.blue,
                            Colors.indigoAccent,
                            'homework'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StudentListPage()));
                        },
                        child: CustomWidgets.teacherHomePannelCardHero(
                            context,
                            'Students ',
                            'assets/teacher/student.png',
                            Colors.blue,
                            Colors.lightBlue,
                            'studentList'),
                      ),
                      CustomWidgets.teacherHomePannelCard(
                          context,
                          'Result',
                          'assets/teacher/exam.png',
                          Colors.indigo,
                          Colors.indigoAccent)
                    ],
                  )
                ],
              );
            }));
  }

  Widget ChatPage() {
    user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);


    return Scaffold(

      body: user.email == null
          ? CircularProgressIndicator()
          : StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools')
            .document(pref.getString('school'))
            .collection('chat')
            .where('users', arrayContains: user.email)
            .snapshots(),
        builder: (context, query) =>
        (query.hasData &&
            query.data.documents.length > 0)
            ? buildStudentChatList(query.data.documents, user.email)
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  height: 100,
                  child: Image.asset('assets/teacher/teacher.png'),
                ),
              ),
              Text(
                'No Messages Yet',
                style: TextStyle(fontSize: 30, color: Colors.blue),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildTopBarText(text, i) {
    return GestureDetector(
      onTap: () {
        controller.animateToPage(i,
            duration: Duration(milliseconds: 500), curve: Curves.decelerate);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            text,
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ),
      ),
    );
  }

  Shader linearGradient = LinearGradient(
    colors: <Color>[Colors.lightBlue, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100, 10.0));

  buildTopBarSelectedText(text, int i) {
    print(controller.page);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              foreground: Paint()
                ..shader = linearGradient),
        ),
      ),
    );
  }

  buildStudentChatList(List<DocumentSnapshot> documents, String id) {
    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (cont, i) {
          return buildChatList(documents[i], id);
        });
  }

  buildChatList(DocumentSnapshot document, String id) {
    var pref = Provider.of<SharedPreferences>(context);

    bool d = false;

    int not = document.data['count'];
    int count = pref.getInt(document.documentID);
    if (count == null) {
      count = not;
      pref.setInt(document.documentID, not);

      d = true;
    }
    else {
      if (not == count) {
        d = false;
      }
      else {
        d = true;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6)
      ),
      child: ListTile(
        title: Text((document.data['users'][0].toString().substring(
            0, document.data['users'][0].toString().indexOf("@")))),
        subtitle: Text('See Messages'),
        leading: Image(
          image: AssetImage('assets/teacher/teacher.png'),
        ),
        trailing: SizedBox(
          height: 30,
          width: 30,
          child: !(count - not == 0) ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle
              , color: Colors.indigo,
            ),
            child: Center(child: Text((not - count).toString(),
              style: TextStyle(color: Colors.white),)),
          ) : SizedBox(),

        ),
        onTap: () {
          pref.setInt(document.documentID, not);
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(classId: document.documentID, id: id,)
          ));
        },
      ),
    );
  }
}
