import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Services/Class.dart';
import 'package:school_magna/Widgets/Homework.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homeworkPage extends StatefulWidget {
  @override
  _homeworkPageState createState() => _homeworkPageState();
}

class _homeworkPageState extends State<homeworkPage> {
  File _image;

  bool dec = true;
  int progress = 0;
  List<bool> uploadImage = [];
  int selectedImage = 0;

  Map<String, dynamic> subjectImage = Map();

  List<String> subList = [];

  List<File> subImageList = [];

  List<TextEditingController> controllers = [];

  List<String> homeWorkTextList = [];


  Future getImageCamera(int i) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      subImageList[i] = image;
      uploadImage.insert(i, true);
    });
  }

  Future getImageGallery(int i) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      subImageList[i] = image;

      uploadImage.insert(i, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);
    return Material(
      color: Colors.white,
      child: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('schools')
            .document(pref.getString('school'))
            .collection('classes')
            .document(user.email)
            .snapshots(),
        builder: (context, snap) =>
            SafeArea(
              child: (!snap.hasData)
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    primary: true,
                    pinned: true,
                    expandedHeight: MediaQuery
                        .of(context)
                        .size
                        .height * 0.4,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.pin,
                      title: Text(
                        'Homework',
                        style: TextStyle(color: Colors.black),
                      ),
                      background: Center(
                        child: SizedBox(
                            height: 100,
                            width: 100,
                            child:
                            Image.asset('assets/teacher/homework.png')),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      List list = snap.data.data['subjectList'];
                      return HomeworkTile(
                        subjectName: list[i],
                      );
                    }, childCount: snap.data.data['subjectList'].length),
                  )
                ],
              ),
            ),
      ),
    );
  }

  Widget buildTopBox() {
    return Hero(
      tag: 'homework',
      child: Image(
        image: AssetImage('assets/teacher/homework.png'),
      ),
    );
  }

  Widget buildHomeWorkListTile(int i, String SubName) {
    return ListTile(
      title: subImageList[i] == null
          ? Text(i.toString() + '\t' + SubName)
          : Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(flex: 1, child: Text(i.toString() + '\t' + SubName)),
                Flexible(flex: 5, child: Image.file((subImageList[i])))
              ],
            ),
          )),
      isThreeLine: true,
      contentPadding: EdgeInsets.all(5),
      subtitle: TextField(
        decoration: InputDecoration(labelText: 'enter homework '),
        controller: controllers[i],
      ),
      trailing: SizedBox(
        height: 100,
        width: 100,
        child: Center(
          child: subImageList[i] != null
              ? IconButton(
            color: Colors.blue,
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                subImageList[i] = null;
              });
            },
          )
              : Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.camera_enhance),
                color: Colors.blue,
              ),
              IconButton(
                onPressed: () {

                },
                icon: Icon(Icons.image),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildHomeworkImagePreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 200,
        width: 200,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              borderRadius: BorderRadius.circular(10)),
          child: Image.file(
            _image,
            fit: BoxFit.fitWidth,
            width: 200,
          ),
        ),
      ),
    );
  }

  Future<List> getData() async {
    var pref = Provider.of<SharedPreferences>(context);
    var user = Provider.of<FirebaseUser>(context);
    var data = await Firestore.instance
        .collection('schools')
        .document(pref.getString('school'))
        .collection('classes')
        .document(user.email)
        .get();

    for (var c in data.data['subjectList']) {
      subImageList.add(null);
      controllers.add(TextEditingController());
      uploadImage.add(false);
    }

    return data.data['subjectList'];
  }

  void sendHomeWork() async {
    int count = 0;
    for (var c in subImageList) {
      uploadImageStorage(count, c);
    }
  }

  Future<String> uploadImageStorage(int i, var imageFile) async {
    String url;

    final FirebaseStorage storage = FirebaseStorage.instance;

    StorageReference ref = storage.ref().child("/photo.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);

    if (uploadTask.isInProgress) {
      setState(() {
        uploadImage.insert(i, true);
      });
    }

    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    url = dowurl.toString();
    setState(() {
      uploadImage.insert(i, false);
    });

    print(url);
    return url;
  }

}
