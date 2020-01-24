import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelpandSupport extends StatelessWidget {
  TextEditingController emailId = TextEditingController(),
      feedback = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Help and Support',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Image(
            image: AssetImage('assets/logo/logo.png'),
            height: MediaQuery.of(context).size.height * .30,
          ),
          ListTile(
            title: Text('For any Help and support'),
            subtitle: Text('supportTeam@SchoolMagna.com'),
          ),
          ListTile(
            title: Text('Submit Your feedback'),
            subtitle: Column(
              children: <Widget>[
                TextField(
                  controller: emailId,
                  decoration: InputDecoration(hintText: 'Mail id'),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: feedback,
                    decoration: InputDecoration(hintText: 'Feedback'))
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            widthFactor: 100,
            child: RaisedButton(
              onPressed: () {
                submitFeedback(context);
              },
              color: Colors.indigoAccent,
              child: Text('Submit'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
        ],
      ),
    ));
  }

  void submitFeedback(BuildContext context) {
    String email = emailId.text;
    String feedbackText = feedback.text;

    if (email.isNotEmpty) {
      DocumentReference ref =
          Firestore.instance.collection('feedback').document(email);

      ref.setData({
        'email': email,
        'feedback': feedback,
        'time': Timestamp.now()
      }).then((val) {
        showDialog(
            context: (context),
            child: AlertDialog(
              shape: RoundedRectangleBorder(),
              title: Text('Feedback is submitted'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
      });
    }
  }
}
