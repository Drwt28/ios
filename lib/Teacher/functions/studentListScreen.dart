import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Student List'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: SizedBox(
                height: 90,
                width: 90,
                child: buildTopBox(),
              ),
            ),
            Flexible(
              flex: 7,
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('schools')
                    .document(pref.getString('school'))
                    .collection('students')
                    .where('classId', isEqualTo: user.email)
                    .snapshots(),
                builder: (context, query) {
                  return (query.data != null && query.data.documents.length > 0)
                      ? builStudentList(query.data.documents)
                      : CircularProgressIndicator();
                },
              ),
            ),
          ],
        ));
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'studentList',
      child: Image(
        image: AssetImage('assets/teacher/student.png'),
      ),
    );
  }

  List<ExpansionPanel> studentList=[];
  builStudentList(List<DocumentSnapshot> documents) {


    return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context,i){

      return buildStudentItem(documents[i]);
    });
  }


  Widget buildStudentItem(DocumentSnapshot document) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ExpandablePanel(

          tapBodyToCollapse: true,

          header: ListTile(
            leading: CircleAvatar(
              child: Image.asset('assets/teacher/student.png'),),
            title: Text(document['name']),
          ),
          collapsed: Container(child: Text('view Details')),
          expanded: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[

                buildDetailedTextStudent("father's name", document['fName'])
                , SizedBox(height: 10,)
                ,
                buildDetailedTextStudent("mothers's name", document['mName'])
                , SizedBox(height: 10,)
                ,
                buildDetailedTextStudent("date of birth", "23/11/2009")
                , SizedBox(height: 10,),
                buildDetailedTextStudent("Remark", document['remark'])
                ,
                SizedBox(height: 10,)


              ],
            ),
          ),
          tapHeaderToExpand: true,
          hasIcon: true,
        ),
      ),
    );
  }

  buildDetailedTextStudent(String tile, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: <Widget>[
        Text(tile + "\t:", style: TextStyle(color: Colors.blue, fontSize: 16),)
        , Text(data, style: TextStyle(color: Colors.black, fontSize: 16),)
      ],
    );
  }

}
