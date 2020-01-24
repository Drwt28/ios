import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_magna/Services/Student.dart';

class CustomWidgets {
//teacher home pannel card

  static Widget teacherHomePannelCard(BuildContext context, String tit,
      String path, Color startColor, Color endColor) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(4),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [startColor, endColor]),
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image(
                    image: AssetImage(path),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  tit,
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
              )
            ],
          ),
        ));
  }

  static Widget studentHomePannel(BuildContext context, String tit, String path,
      Color startColor, Color endColor) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(4),
        child: SizedBox(
          height: 100,
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.1,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [startColor, endColor]),
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Text(
                    tit,
                    style: TextStyle(fontSize: 26, color: Colors.white),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: AssetImage(path),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  static Widget teacherHomePannelCardHero(BuildContext context, String tit,
      String path, Color startColor, Color endColor, String tag) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(4),
        child: Card(
          elevation: 10,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(

            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [startColor, endColor]),
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Hero(
                      tag: tag,
                      child: Image(
                        image: AssetImage(path),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    tit,
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  static Widget teacherHomePannelCardHeroSingle(BuildContext context,
      String tit, String path, Color startColor, Color endColor, String tag) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(4),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [startColor, endColor]),
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Text(
                  tit,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Hero(
                    tag: tag,
                    child: Image(
                      image: AssetImage(path),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

//selection pannel card
  static Widget SelectionPannelCard(BuildContext context, String tit,
      String path, Color startColor, Color endColor, tag) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [startColor, endColor]),
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Hero(
                  tag: tag,
                  child: Image(
                    image: AssetImage(path),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  tit,
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
              )
            ],
          ),
        ));
  }

  static String getTimeFromString(DateTime time) {
    var now = time;
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(now);

    return formatted;
  }

  static String getTime(Timestamp time) {
    var now = DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
    var formatter = new DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(now);

    return formatted;
  }

  static Widget SchoolPannelCard(BuildContext context, String logo, String name,
      String address, Color startColor, Color endColor, int i) {
    return AnimatedContainer(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(10),
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.18,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(


              color: Colors.indigo,
              borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Flexible(
                flex: 1,
                child: Hero(
                  tag: i,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: CircleAvatar(
                          radius: 25,
                          foregroundColor: Colors.indigo,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(logo),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: <Widget>[
                    Text(name, style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 20),
                      textAlign: TextAlign.start,),


                    buildIconRow(Icons.school, name),


                    buildIconRow(Icons.location_on, address)

                  ],
                ),
              ),
            ],
          ),
        ));
  }

  static buildIconRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: Colors.white, size: 18,)
        , SizedBox(width: 10,),
        Text(text, style: TextStyle(color: Colors.white),)
      ],
    );
  }
  static ShowDialog(BuildContext context, Widget icon, content) {
    showDialog(
        context: context,
        child: AlertDialog(
          title: icon,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }
}
