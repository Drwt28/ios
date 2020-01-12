import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Principal/CreateChatPage.dart';
import 'package:school_magna/Teacher/TeacherChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrincipalChatScreen extends StatefulWidget {
  @override
  _PrincipalChatScreenState createState() => _PrincipalChatScreenState();
}

class _PrincipalChatScreenState extends State<PrincipalChatScreen> {
  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    String pId = pref.getString('principal');
    String schoolId = pref.getString('school');
    return Scaffold(
        body: pId == null
            ? CircularProgressIndicator()
            : StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('schools')
              .document(pref.getString('school'))
              .collection('chat')
              .where('users', arrayContains: pId)
              .snapshots(),
          builder: (context, query) =>
          (query.hasData &&
              query.data.documents.length > 0)
              ? buildTeacherChatList(query.data.documents, pId)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    height: 100,
                    child:
                    Image.asset('assets/teacher/teacher.png'),
                  ),
                ),
                Text(
                  'No Messages Yet',
                  style:
                  TextStyle(fontSize: 30, color: Colors.blue),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.chat),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CreateChatListPage()));
          },
        ));
  }

  buildTeacherChatList(List<DocumentSnapshot> documents, String id) {
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
    } else {
      if (not == count) {
        d = false;
      } else {
        d = true;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        title: Text((document.data['users'][1]
            .toString()
            .substring(0, document.data['users'][1].toString().indexOf("@")))),
        subtitle: Text('See Messages'),
        leading: Image(
          image: AssetImage('assets/teacher/teacher.png'),
        ),
        trailing: SizedBox(
          height: 30,
          width: 30,
          child: !(count - not == 0)
              ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.indigo,
            ),
            child: Center(
                child: Text(
                  ((not - count)).toString(),
                  style: TextStyle(color: Colors.white),
                )),
          )
              : SizedBox(),
        ),
        onTap: () {
          pref.setInt(document.documentID, not);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(
                        classId: document.documentID,
                        id: document.documentID,
                      )));
        },
      ),
    );
  }
}
