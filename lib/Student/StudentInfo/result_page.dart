import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    String studentId = pref.getString('Student');

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .document('schools/$schoolId/students/$studentId')
            .collection('result')
            .snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            body: !(snapshot.hasData && snapshot.data.documents.length > 0)
                ? Center(
              child: CircularProgressIndicator(),
            )
                : ListView(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              children: <Widget>[
                StudentInformationList(),
                SizedBox(
                  height: 20.0,
                ),
                ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) =>
                        ResultTable(
                          name: snapshot.data.documents[i]['name'],
                          declaredDate: CustomWidgets.getTime(
                              snapshot.data.documents[i]['time']),
                          max: int.parse(
                              snapshot.data.documents[i]['max']),
                          resultMap: snapshot.data.documents[i]['marks'],
                          subjectList: snapshot.data.documents[i]
                          ['subjectList'],
                        )),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        });
  }
}

class StudentInformationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    String schoolId = pref.getString('school');
    String id = pref.getString('Student');
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .document('schools/$schoolId/students/$id')
            .snapshots(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? Center(
            child: CircularProgressIndicator(),
          )
              : Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                      buildDashText('Name :', snapshot.data.data['name']),
                      buildDashText(
                          "Father's Name :", snapshot.data.data['fName']),
                      buildDashText(
                          "Mother's Name :", snapshot.data.data['mName']),
                      buildDashText("Roll No :",
                          snapshot.data.data['rollNo'] ?? ""),
                    ],
                  )),
            ),
          );
        });
  }

  buildDashText(String title, val) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                flex: 1,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.0, color: Colors.blue),
                )),
            Flexible(
                flex: 1,
                child: Text(val, style: TextStyle(color: Colors.indigoAccent)))
          ]),
    );
  }

  buildResultWorkLayout(String title, DocumentSnapshot content) {
    print(title);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigoAccent])),
        child: ListTile(
          onTap: () {},
          title: Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          subtitle: Text(
            'Recieved at  $content',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class ResultTable extends StatelessWidget {
  String name;

  int max;

  String declaredDate;

  List subjectList = [];

  Map resultMap = Map();

  ResultTable({@required this.name,
    this.declaredDate,
    this.subjectList,
    this.resultMap,
    this.max});

  @override
  Widget build(BuildContext context) {
    return buildDataTable(context);
  }

  Widget buildDataTable(BuildContext context) {
    double total = 0,
        per;

    for (var c in subjectList) {
      total = total + double.parse(resultMap[c]);
    }
    int t = max * subjectList.length;

    per = (total / t) * 100;

    var items = List<ItemInfo>();
    items = List.generate(subjectList.length, (i) {
      return ItemInfo(
          marks: resultMap[subjectList[i]],
          subjects: subjectList[i],
          total: max);
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          child: Card(
            elevation: 1.0,
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                      fontSize: 23),
                ),
                SizedBox(
                  height: 10,
                ),
                DataTable(
                  columns: [
                    DataColumn(
                        label: Text('Subject',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ))),
                    DataColumn(
                        label: Text('Total\nMarks',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ))),
                    DataColumn(
                        label: Text('Marks\nObtained',
                            style: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ))),
                  ],
                  rows: items
                      .map(
                        (itemRow) =>
                        DataRow(
                          cells: [
                            DataCell(
                              Text(itemRow.subjects),
                            ),
                            DataCell(
                              Text('${itemRow.total}'),
                            ),
                            DataCell(
                              Text('${itemRow.marks}'),
                            ),
                          ],
                        ),
                  )
                      .toList(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  'Percentage: ${per.toStringAsFixed(2)} %',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Declared on : $declaredDate',
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black54),
                )
              ],
            ),
          )),
    );
  }
}

class ItemInfo {
  String subjects;
  String marks;
  int total;

  ItemInfo({this.subjects, this.marks, this.total});
}
