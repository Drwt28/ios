import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('schools')
            .document(pref.getString('school'))
            .collection('students')
            .orderBy('name')
            .where('classId', isEqualTo: user.email)
            .snapshots(),
        builder: (context, query) {
          return (query.data != null && query.data.documents.length > 0)
              ? Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  pinned: true,
                  primary: true,
                  expandedHeight:
                  MediaQuery
                      .of(context)
                      .size
                      .height * 0.3,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    title: Text(
                      'Student List',
                      style: TextStyle(color: Colors.black),
                    ),
                    background: Center(
                      child: SizedBox(
                          height: 80,
                          width: 80,
                          child: Center(child: buildTopBox())),
                    ),
                  ),
                ),
                SliverList(

                  delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        return buildStudentItem(query.data.documents[i]);
                      },
                      childCount: query.data.documents.length),
                )
              ],
            ),

          )
              : Scaffold(body: Center(child: CircularProgressIndicator()));
        });
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
    return Card(
      child: ExpandablePanel(


        header: ListTile(
          leading: CircleAvatar(
            child: Image.asset('assets/teacher/student.png'),),
          title: Text(document['name']),
        ),
        collapsed: Container(child: Text('view Details')),
        expanded: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: <Widget>[

              buildDetailedTextStudent("father's name", document['fName'])
              ,
              SizedBox(height: 10,)
              ,
              buildDetailedTextStudent("mothers's name", document['mName'])
              ,
              SizedBox(height: 10,)
              ,
              buildDetailedTextStudent("date of birth", "23/11/2009")
              ,
              SizedBox(height: 10,),
              Text('Remark', style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),)
              ,
              Text(document['remark'],
                style: TextStyle(color: Colors.indigo, fontSize: 16),
                softWrap: true,)
              ,
              SizedBox(height: 10,)


            ],
          ),
        ),
        tapHeaderToExpand: true,
        hasIcon: true,
      ),
    );
  }

  buildDetailedTextStudent(String tile, data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

      children: <Widget>[
        Text(tile + "\t:", style: TextStyle(color: Colors.blue, fontSize: 16),)
        ,
        Text(data, textAlign: TextAlign.justify,
          style: TextStyle(color: Colors.black, fontSize: 16),)
      ],
    );
  }

}
