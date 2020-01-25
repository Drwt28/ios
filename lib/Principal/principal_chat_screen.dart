import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Principal/CreateChatPage.dart';
import 'package:school_magna/Teacher/TeacherChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrincipalChatScreen extends StatefulWidget {
  @override
  _PrincipalChatScreenState createState() => _PrincipalChatScreenState();
}

class _PrincipalChatScreenState extends State<PrincipalChatScreen> {

  NoticationService noticationService = NoticationService();

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);

    String pId = pref.getString('school');
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

  Future<int> getChatCounter(DocumentSnapshot document) async {
    var pref = Provider.of<SharedPreferences>(context);
    int count = pref.getInt(document.documentID);
    var col = await Firestore.instance.collection(
        'schools/${pref.getString('school')}/chat/${document
            .documentID}/messages').getDocuments();
    int not = col.documents.length;

    return (not - count);
  }

  buildChatList(DocumentSnapshot document, String id) {
    var pref = Provider.of<SharedPreferences>(context);

    bool d = false;


    String notificationId = "C" + pref.getString('school').substring(
        0, pref.getString('school').indexOf('@'));
    noticationService.saveUserToken(notificationId);


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
          child: FutureBuilder<int>(
              future: getChatCounter(document),
              builder: (context, snap) =>
              (snap.hasData && snap.data > 0) ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo,
                ),
                child: Center(
                    child: Text(
                      (snap.data).toString(),
                      style: TextStyle(color: Colors.white),
                    )),
              )
                  : SizedBox()),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(
                        classId: document.documentID,
                        id: id,
                      )));
        },
      ),
    );
  }
}
