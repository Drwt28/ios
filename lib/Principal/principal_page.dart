import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_magna/Principal/CreateChatPage.dart';
import 'package:school_magna/Principal/notices.dart';
import 'package:school_magna/Principal/principal_chat_screen.dart';
import 'package:school_magna/Principal/visual_data_screen.dart';
import 'package:school_magna/Services/Teacher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class PrincipalHomeScreen extends StatefulWidget {
  @override
  _PrincipalHomeScreenState createState() => _PrincipalHomeScreenState();
}

class _PrincipalHomeScreenState extends State<PrincipalHomeScreen> {
  int currentTabIndex = 0;

  PageController controller = PageController();
  ScrollController listViewController = ScrollController();


  final List<String> _childrenText = ['Home', 'Chat', 'Notice'];

  Teacher teacher = Teacher();

  int currentItem = 0;


  int _currentIndex = 0;
  final List<Widget> _children = [
    Visualization(),
    PrincipalChatScreen(),
    Notices(),
  ];

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
                    itemBuilder: (context, i) => _children[i]

                )
            )
          ],
        )
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
}
