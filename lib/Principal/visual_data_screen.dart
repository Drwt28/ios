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
  int _value = 1;
  List<bool> isSelected = [true, false];
  int indexValue;

  @override
  void initState() {
    super.initState();
  }

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
                      child: buildClassClip(),
                    ),
                  ),
                ],
              ),
              Container(
                height: 35.0,
                alignment: Alignment.topRight,
                child: ToggleButtons(
                  disabledColor: Colors.grey,
                  borderRadius: BorderRadius.circular(3.0),
                  fillColor: Colors.indigo,
                  children: <Widget>[
                    Text(
                      'Week',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      'Month',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                  isSelected: isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int indexBtn = 0;
                      indexBtn < isSelected.length;
                      indexBtn++) {
                        if (indexBtn == index) {
                          isSelected[indexBtn] = !isSelected[indexBtn];
                          indexValue = index;
                        } else {
                          isSelected[indexBtn] = false;
                        }
                      }
                    });
                  },
                ),
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
                Text(
                  'Section: ' + '${documents[index]['section']}',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                indexValue == 0
                    ? showWeekData(documents[index])
                    : showMonthData(documents[index])
              ],
            ));
      }),
    );
  }

  Wrap buildClassClip() {
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

  List<Attendence> getData(DocumentSnapshot document) {
    List<Attendence> attendence = [];
    List keys = document.data['attendenceKey'] ?? List();
    Map map = document.data['attendenceList'];
    for (var a in keys) {
      attendence.add(Attendence(week: a, number: map[a]));
    }

    return attendence;
  }

  showWeekData(DocumentSnapshot document) {
    List<Attendence> weekData = getData(document);
    List<List<Attendence>> weekList = new List<List<Attendence>>();
    List<charts.Series<Attendence, String>> _createVisualizationData() {
      return [
        charts.Series<Attendence, String>(
            id: 'StudentAttendence',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (Attendence dataPoint, _) => dataPoint.week,
            measureFn: (Attendence dataPoint, _) => dataPoint.number,
            data: weekData),
      ];
    }

    weekList.add(getData(document));
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height * .4,
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

  showMonthData(document) {
    List<Attendence> monthData = getData(document);
    List<List<Attendence>> monthList = new List<List<Attendence>>();
    List<charts.Series<Attendence, String>> _createVisualizationData() {
      return [
        charts.Series<Attendence, String>(
            id: 'StudentAttendence',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (Attendence dataPoint, _) => dataPoint.week,
            measureFn: (Attendence dataPoint, _) => dataPoint.number,
            data: monthData),
      ];
    }

    monthList.add(getData(document));
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height * .4,
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
}
