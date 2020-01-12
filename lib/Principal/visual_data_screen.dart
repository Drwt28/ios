import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//student class
class Attendence {
  Attendence({this.week, this.number});
  final String week;
  final int number;
}
class Visualization extends StatefulWidget {
  @override
  _VisualizationState createState() => _VisualizationState();
}

var pref;
String id = pref.get('school');
String className;
class _VisualizationState extends State<Visualization> {
  final List<Attendence> data = List<Attendence>();
  int _value = 1;
  List<List<Attendence>> list = new List<List<Attendence>>();
  @override
  Widget build(BuildContext context) {
    pref = Provider.of<SharedPreferences>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools/$id/classes')
            .where('className', isEqualTo: className)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: RotationTransition(
                      turns: AlwaysStoppedAnimation(-45 / 360),
                      child: Text(
                        "Class",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 28.0,
                            color: Colors.indigo),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: buildClassClip(snapshot.data.documents),
                    ),
                  ),
                ],
              ),
              !(snapshot.hasData && snapshot.data.documents.length > 0)
                  ? Container(
                padding: EdgeInsets.symmetric(
                  vertical: 60.0,
                ),
                child: Center(
                  child: Text(
                    'No Data Yet',
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 24.0),
                  ),
                ),
              )
                  : getSectionList(snapshot.data.documents),
            ],
          );
        });
  }

  getSectionList(List<DocumentSnapshot> documents) {
    return Wrap(
      children: List.generate(documents.length, (int index) {
        return Container(
            child: Column(
              children: <Widget>[
                Text('Section: ' + '${documents[index]['section']}',
                  style: TextStyle(fontWeight: FontWeight.w500),),
                buildCard(index, context, documents[index]['section'])
              ],
            ));
      }),
    );
  }

  buildCard(int index, BuildContext context, String section) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools/$id/classes')
            .where('className', isEqualTo: className)
            .where('section', isEqualTo: section)
            .snapshots(),
        builder: (context, snapshot) {
          try {
            list.insert(index, getDataFromMap(
                snapshot.data.documents[0].data['attendenceList']));
          } catch (e) {
            list.add(getDataFromMap(
                snapshot.data.documents[0].data['attendenceList']));
          }
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            elevation: 3.0,
            child: Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .5,
              child: charts.BarChart(
                _createVisualizationData(),
                animate: true,
                behaviors: [
                  charts.ChartTitle('Number of Student',
                      behaviorPosition: charts.BehaviorPosition.start),
                  charts.ChartTitle('Weeks',
                      behaviorPosition: charts.BehaviorPosition.bottom)
                ],
              ),
            ),
          );
        }
    );
  }

  Wrap buildClassClip(List<DocumentSnapshot> documents) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 8.0,
      runAlignment: WrapAlignment.end,
      children: List<Widget>.generate(
        12,
            (int index) {
          return FilterChip(
            autofocus: true,
            selectedColor: Colors.indigoAccent,
            label: Text('${index + 1}'),
            selected: _value == index,
            onSelected: (bool selected) {
              setState(() {
                _value = selected ? index : index;
                className = 'Class ' + '${index + 1}';
              });
            },
          );
        },
      ).toList(),
    );
  }
  List<charts.Series<Attendence, String>> _createVisualizationData() {
    return [
      charts.Series<Attendence, String>(
          id: 'StudentAttendence',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (Attendence dataPoint, _) => dataPoint.week,
          measureFn: (Attendence dataPoint, _) => dataPoint.number,
          data: data)
    ];
  }
  List<Attendence> getDataFromMap(Map map) {
    List<Attendence> attendence = [];
    String s = map.toString();
    int i = map.toString().indexOf(',');
    while (i > 0) {
      try {
        String l = s.substring(0, i);
        attendence.add(Attendence(
            week: l.substring(0, l.indexOf(':')).replaceFirst('{', ""),
            number: map[l
                .substring(0, l.indexOf(':'))
                .toString()
                .replaceFirst("{", "")
                .trim()]));
        s = s.substring(i + 1, s.length - 1);
        i = s.indexOf(',');
      } catch (e) {
        break;
      }
    }
    for (var a in attendence) {
      print(a.week + '${a.number}');
      data.add(Attendence(week: a.week, number: a.number));
    }
    return attendence;
  }
}