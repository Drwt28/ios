import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Services/Class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeworkTile extends StatefulWidget {
  String subjectName;

  var days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thrusday',
    'Friday',
    'Saturday'
  ];
  Firestore db = Firestore.instance;

  HomeworkTile({@required this.subjectName});

  @override
  _HomeworkTileState createState() => _HomeworkTileState();
}

class _HomeworkTileState extends State<HomeworkTile> {
  bool imageSlected = false;

  File imageFile = null;
  bool progress = true;
  bool sent = false;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);

    var pref = Provider.of<SharedPreferences>(context);

    return (sent)
        ? sentCard(widget.subjectName)
        : Card(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            title: imageFile == null
                ? Text('\t' + widget.subjectName)
                : Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          flex: 1, child: Text(widget.subjectName)),
                      Flexible(
                          flex: 5,
                          child: Image.file(
                            (imageFile),
                            fit: BoxFit.fill,
                          ))
                    ],
                  ),
                )),
            isThreeLine: true,
            contentPadding: EdgeInsets.all(5),
            subtitle: TextField(
              onChanged: (val) {},
              decoration: InputDecoration(labelText: 'enter homework '),
              controller: controller,
            ),
            trailing: SizedBox(
              width: 100,
              child: Center(
                child: imageFile != null
                    ? IconButton(
                  color: Colors.blue,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      imageFile = null;
                    });
                  },
                )
                    : SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          getImage(ImageSource.camera);
                        },
                        icon: Icon(Icons.camera_enhance),
                        color: Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        icon: Icon(Icons.image),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          !progress
              ? CircularProgressIndicator()
              : Container(
            height: 50,
            width: 100,
            child: Center(
              child: FlatButton(
                onPressed: () {
                  if (imageFile == null || progress) {
                    uploadImageStorage(
                        widget.subjectName,
                        1,
                        imageFile,
                        user.email,
                        controller.text,
                        user,
                        pref.getString('school'));
                  }
                },
                padding: EdgeInsets.all(5),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'Send',
                      style: TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Icon(
                      Icons.send,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void getImage(ImageSource gallery) async {
    var image = await ImagePicker.pickImage(source: gallery);
    setState(() {
      imageFile = image;
    });
  }

  Future<String> uploadImageStorage(String subjectName, int j, var imageFile,
      String name, String text, FirebaseUser user, String schoolId) async {
    List<String> urlList = List<String>();
    String t = text;

    var pref = Provider.of<SharedPreferences>(context);

    final FirebaseStorage storage = FirebaseStorage.instance;

    DateTime date = DateTime.now();
    StorageReference ref = storage
        .ref()
        .child(pref.getString('school'))
        .child(user.email)
        .child(widget.subjectName + widget.days[date.weekday - 1]);

    StorageUploadTask uploadTask = ref.putFile(imageFile);

    if (uploadTask.isInProgress) {
      setState(() {
        progress = false;
      });
    }

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    urlList.add(dowurl.toString());

    saveToDatabase(user, t, dowurl.toString(), schoolId, subjectName);

    return "";
  }

  void saveToDatabase(FirebaseUser user, String t, String url, String schoolId,
      String subjectName) {
    String id = user.email;
    Map<String, dynamic> homework = Map();

    DateTime date = DateTime.now();

    homework['day'] = widget.days[date.weekday];
    String day = widget.days[date.weekday - 1].toLowerCase();
    DocumentReference doc =
    Firestore.instance.document('schools/$schoolId/classes/$id');

    List list = List();

    list.add(url);

    homework['image'] = list ?? List();

    homework['time'] = Timestamp.now();

    homework['text'] = t;

    homework['day'] = day;

    homework['name'] = subjectName;

    Map<String, dynamic> dataMap = ({subjectName: homework});
    doc.updateData(dataMap).then((val) {
      setState(() {
        sent = true;
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  sentCard(String subjectName) {
    return Card(
      child: ListTile(
          trailing: IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.blue,
              size: 35,
            ),
            onPressed: () {
              setState(() {
                sent = false;
                progress = true;
                imageFile = null;
              });
            },
          ),
          onTap: () {
            setState(() {
              sent = false;
              progress = true;
              imageFile = null;
            });
          },
          title: Text(
            '$subjectName home work sent succesfully',
            style: TextStyle(color: Colors.green, fontSize: 18),
          ),
          leading: Icon(
            Icons.check,
            color: Colors.green,
            size: 40,
          )),
    );
  }
}
