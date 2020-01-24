import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:school_magna/main.dart';

class TeacherCarousel extends StatefulWidget {
  @override
  _TeacherCarouselState createState() => _TeacherCarouselState();
}

class _TeacherCarouselState extends State<TeacherCarousel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: CarouselSlider(
            height: MediaQuery.of(context).size.height * 0.78,
            viewportFraction: 0.90,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            autoPlayAnimationDuration: Duration(milliseconds: 500),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: Duration(seconds: 10),
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
            items: [
              Builder(
                builder: (BuildContext context) {
                  return buildFirstSlide(
                      Colors.blue,
                      'assets/teacher/teacher.png',
                      'assets/parent/parents.png',
                      'assets/teacher/student.png',
                      'Welcome to School Magna');
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return buildSlide(
                      Colors.indigo,
                      'assets/teacher/attendence.png',
                      'Daily Attendance Notification ');
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return buildSlide(Colors.blue, 'assets/teacher/remark.png',
                      'Parents and Teacher Coversation ');
                },
              ),
              Builder(
                builder: (BuildContext context) {
                  return buildSlide(Colors.deepOrange,
                      'assets/teacher/fees.png', 'Perodic Fees Notifications');
                },
              )
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        },
        backgroundColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Skip',
              style: TextStyle(color: Colors.indigo),
            )
          ],
        ),
      ),
    );
  }

  buildSlide(Color color, String path, String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            path,
            height: 100,
            width: 100,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  SkipButton() {
    return FlatButton(
      onPressed: () {},
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Skip',
            style: TextStyle(color: Colors.indigo),
          ),
          Icon(
            Icons.navigate_next,
            color: Colors.indigo,
          )
        ],
      )),
    );
  }

  Widget buildFirstSlide(
      Color color, String s, String t, String u, String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset(
                t,
                height: 100,
                width: 100,
              ),
              Image.asset(
                s,
                height: 100,
                width: 100,
              ),
            ],
          ),
          Image.asset(
            u,
            height: 100,
            width: 100,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
