import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/constraints.dart';
import 'package:school_magna/Notification/Notification.dart';
import 'package:school_magna/Notification/TeacherNotification.dart';
import 'package:school_magna/Principal/CreateChatPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentChatScreen extends StatefulWidget {
  final classId;
  final studentId;

  StudentChatScreen({this.classId, this.studentId});

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
var pref, currentUser;
bool isTeacher = false;

class _StudentChatScreenState extends State<StudentChatScreen> {

  NoticationService notification = NoticationService();
  String sender = "";
  final _auth = FirebaseAuth.instance;
  String messageText;

  TextEditingController messageTextEditingController = TextEditingController();

  @override
  void initState() {
    getCurrentUser();

    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        isTeacher = true;
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
    loggedInUser != null
        ? currentUser = loggedInUser.email
        : currentUser = widget.studentId;

    setState(() {
      if (currentUser == widget.classId) {
        sender = widget.classId
            .toString()
            .substring(0, widget.classId.toString().indexOf("@"));
      } else {
        sender = widget.studentId.toString();
      }
    });
  }

  TeacherNotification teacherNotification = TeacherNotification();

  @override
  Widget build(BuildContext context) {
    pref = Provider.of<SharedPreferences>(context);
    String id = pref.getString('school');
    var user = Provider.of<FirebaseUser>(context);
    return Scaffold(
      appBar: AppBar(title: user == null ? Text(
          widget.classId.toString().substring(
              0, widget.classId.toString().indexOf('@')))
          : Text(pref.getString('studentName'))),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              studentId: widget.studentId,
              schoolId: id,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextEditingController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      if (messageText.isNotEmpty) {
                        _firestore
                            .collection(
                            'schools/$id/chat/${widget.studentId}/messages')
                            .add({
                          'text': messageText,
                          'sender': currentUser,
                          'timestamp':
                          DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString()
                        });


                        if (user == null) {
                          teacherNotification.sendNotification(
                              '$sender sent you a message ', messageText,
                              "C" + widget.studentId);
                        }
                        else {
                          teacherNotification.sendNotification(
                              'Message from Class Teacher', messageText,
                              widget.studentId);
                        }
                        messageText = "";
                        messageTextEditingController.clear();
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final studentId, schoolId;

  MessagesStream({this.schoolId, this.studentId});

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('schools/$schoolId/chat/$studentId/messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!(snapshot.hasData)) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        pref.setInt(studentId, messages.length);
        for (var message in messages) {
          final messageText = message.data['text'];
          final messageSender = message.data['sender'];

          final messageWidget = MessageBubble(
            messageText: messageText,
            messageSender: messageSender,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageWidget);
        }

        return Expanded(
          child: ListView(
            reverse: true,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {@required this.messageText,
      @required this.messageSender,
      @required this.isMe});

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    var pref = Provider.of<SharedPreferences>(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          messageSender.contains('@') ? Text(
              messageSender.substring(0, messageSender.indexOf('@'))) : Text(
              '${pref.getString('studentName')}'),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0))
                : BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.blue.shade100 : Colors.indigo.shade100,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(messageText),
            ),
          ),
        ],
      ),
    );
  }
}
