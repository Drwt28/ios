import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendentPage extends StatefulWidget {
  @override
  _AttendentPageState createState() => _AttendentPageState();
}

class _AttendentPageState extends State<AttendentPage> {
  DateTime _currentDate;
  EventList<Event> eventList = EventList<Event>(events: {});

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    String id = pref.getString('Student');
    return Scaffold(

      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .document('schools/$schoolId/students/$id')
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData ? Center(
                child: CircularProgressIndicator()) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SafeArea(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[

                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: ListTile(

                          leading: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/parent/parents.png',
                                ),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          title: Column(
                            children: <Widget>[
                              buildDashText('Name', snapshot.data.data['name'])
                              , buildDashText(
                                  'Roll No:', snapshot.data.data['rollNo'])
                              ,
                              buildDashText('Total Present',
                                  snapshot.data.data['presentList'].length
                                      .toString())
                              , buildDashText('Total Absent',
                                  snapshot.data.data['absentList'].length
                                      .toString())
                              , buildDashText('Total Present',
                                  snapshot.data.data['leaveList'].length
                                      .toString())

                            ],
                          )),
                    ),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'Present',
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'Absent',
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.red),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'Leave',
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Card(
                      color: Colors.grey.shade200,
                      elevation: 0.4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * .5,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: buildCalender(snapshot.data),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  buildCalender(DocumentSnapshot data) {
    EventList<Event> markeddateMap = EventList<Event>(events: {});

    List<dynamic> pList = data['presentList'];

    for (Timestamp d in pList) {
      DateTime c =
      DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
      markeddateMap.add(
          DateTime(c.year, c.month, c.day),
          Event(
              title: 'present',
              date: DateTime(c.year, c.month, c.day),
              icon: Container(
                decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: Center(child: Text(c.day.toString())),
              )));
    }
    List<dynamic> aList = data['absentList'];

    for (Timestamp d in aList) {
      DateTime c =
      DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
      markeddateMap.add(
          DateTime(c.year, c.month, c.day),
          Event(
              title: 'absent',
              date: DateTime(c.year, c.month, c.day),
              icon: Container(
                decoration: BoxDecoration(
                    color: Colors.redAccent, shape: BoxShape.circle),
                child: Center(child: Text(c.day.toString())),
              )));
    }
    List<dynamic> lList = data['leaveList'];

    for (Timestamp d in lList) {
      DateTime c =
      DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
      markeddateMap.add(
          DateTime(c.year, c.month, c.day),
          Event(
              title: 'leave',
              date: DateTime(c.year, c.month, c.day),
              icon: Container(
                decoration:
                BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: Center(child: Text(c.day.toString())),
              )));
    }
    return CalendarCarousel(
      markedDatesMap: markeddateMap,
      showOnlyCurrentMonthDate: false,
      markedDateShowIcon: true,
      todayTextStyle: TextStyle(color: Colors.black),
      todayButtonColor: Colors.transparent,
      markedDateIconMaxShown: 1,
      markedDateMoreShowTotal: null,
      markedDateIconBuilder: (Event event) {
        return event.icon;
      },
    );
  }

  buildDashText(String title, val) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                flex: 1,
                child: Text(title, style: TextStyle(color: Colors.blue),)),
            Flexible(
                flex: 1,
                child: Text(val, style: TextStyle(color: Colors.indigoAccent)))

          ]),
    );
  }
}
