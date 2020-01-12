import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/Database/db.dart';
import 'package:school_magna/Services/Class.dart';
import 'package:school_magna/Teacher/teacherHome.dart';
import 'package:school_magna/Services/Teacher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class classBuilderScreen extends StatefulWidget {
  @override
  _classBuilderScreenState createState() => _classBuilderScreenState();
}

class _classBuilderScreenState extends State<classBuilderScreen> {
  List<bool> CheckList = [];
  TextEditingController tName = TextEditingController();
  String className, sectioName;
  List<String> subList = [];
  Teacher teacher = Teacher();
  ScrollController controller;
  String email;
  bool dec = true;
  bool screen = false;

  @override
  initState() {

    teacher.init();

    SharedPreferences.getInstance()
    .then((pref){

      var id = pref.getString('id');
      var schoolid = pref.getString('school');

//      checkDocument(id,schoolid);

    });

    super.initState();


    controller = ScrollController();



  }



  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<FirebaseUser>(context);
    var pref = Provider.of<SharedPreferences>(context);

    checkDocument(user.email, pref.getString('school'));
    return screen ?Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          TextField(
            textInputAction: TextInputAction.done,
            controller: tName,
            decoration: InputDecoration(labelText: 'Tecaher name'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              buildClassDropDown(context),
              buildSectionSelection(context)
            ],
          ),
          Expanded(
              flex: 1,
              child: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('schools')
                    .document(pref.getString("school"))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  return buildCheckBox(
                      context, snapshot.data.data['subjectList']);
                },
              )),

        ],
      ),
      persistentFooterButtons: <Widget>[
        Container(
          child: dec
              ? RaisedButton(
            child: Text(
              'done',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              setState(() {
                dec = false;
              });

              uploadData(user.email, tName.text, subList, className,
                  sectioName, pref.getString('school'));
            },
          )
              : CircularProgressIndicator(),
        ),
      ],) : Scaffold(body: Center(child: CircularProgressIndicator())
    );
  }


checkDocument(String id,schoolId)
  {
   var doc =  Firestore.instance.collection('schools/'+schoolId+'/classes').document(id);

   doc.get().then((val){

     if(val.exists)
       {
         setState(() {
           Navigator.pushReplacement(context, MaterialPageRoute(
             builder: (context)=>TeacherHomePage()
           ));
         });
       }
     else{
       setState(() {
         screen = true;
       });
     }
   });
  }

  Widget buildCheckBox(BuildContext context, List list) {
    for (var c in list) {
      CheckList.add(false);
    }
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: (){
              setState(() {
                if (CheckList[index] == false) {
                  CheckList[index] = true;
                  subList.add(list[index]);
                } else {
                  CheckList[index] = false;
                  subList.remove(list[index]);
                }
              });
            },
            title: Text(list[index]),
            trailing: Checkbox(
                activeColor: Colors.blue,
                value: CheckList[index],
                onChanged: (bool value) {
                  setState(() {
                    if (CheckList[index] == false) {
                      CheckList[index] = true;
                      subList.add(list[index]);
                    } else {
                      CheckList[index] = false;
                      subList.remove(list[index]);
                    }

                    print(subList);
                  });
                }),
          );
        });
  }

  void uploadData(String id, tname, List<String> subList, className,
      sectionName, schoolName) {
    DocumentReference ref = Firestore.instance
        .collection("schools")
        .document(schoolName)
        .collection('classes')
        .document(id);

    Class c = Class();

    c.className = className;
    c.classId = id;
    c.section = sectioName;
    c.teacherName = tname;
    c.subjectList = subList;

    ref.setData(Class.convertToMap(c)).whenComplete(() {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TeacherHomePage()));
    });
  }


  Widget buildClassDropDown(BuildContext context) {
    return SizedBox(
        height: 50,
        child: DropdownButton<String>(
          value: className,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 28,
          hint: Text("Select your Class"),
          elevation: 16,
          style: TextStyle(color: Colors.indigo),
          underline: Container(
            height: 2,
            color: Colors.indigoAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              className = newValue;
            });
          },
          items: <String>[
            'Class 1',
            'Class 2',
            'Class 3',
            'Class 4',
            'Class 5',
            'Class 6',
            'Class 7',
            'Class 8',
            'Class 9',
            'Class 10',
            'Class 11',
            'Class 12',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }

  Widget buildSectionSelection(BuildContext context) {
    return SizedBox(
        child: DropdownButton<String>(
          value: sectioName,
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
          hint: Text("Select your Class"),
          elevation: 16,
          style: TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String newValue) {
            setState(() {
              sectioName = newValue;
            });
          },
          items: <String>[
            'A',
            'B',
            'C',
            'D',
            'E',
            'F',
            'G',
            'H',
            'I',
            'J',
            'K',
            'L',
            'M',
            'N',
            'O',
            'P',
            'Q',
            'R',
            'S',
            'T',
            'U',
            'V',
            'W',
            'X',
            'Y',
            'Z'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ));
  }
}
