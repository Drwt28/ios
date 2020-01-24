import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_magna/Model/model.dart';
import 'package:school_magna/Principal/principal_page.dart';
import 'package:school_magna/StartScreen/HelpAndSupportScreen.dart';
import 'package:school_magna/Student/studentHomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../selectPanel.dart';

class SchoolsListScreen extends StatefulWidget {
  @override
  _SchoolsListScreenState createState() => _SchoolsListScreenState();
}

class _SchoolsListScreenState extends State<SchoolsListScreen> {
  @override
  Widget build(BuildContext context) {
    return buildPage();
  }

  Widget buildSchoolListcard(int i, List<DocumentSnapshot> documents) {
    SharedPreferences sharedPreferences =
        Provider.of<SharedPreferences>(context);

    return GestureDetector(
        onTap: () {
          sharedPreferences
              .setString("school", documents[i]['id'])
              .then((bool val) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectionPanel(i)));
          });
        },
        child: CustomWidgets.SchoolPannelCard(
            context,
            documents[i]['logo'],
            documents[i]['name'],
            documents[i]['address'],
            Colors.blue,
            Colors.indigo,
            i));
  }

  buildDrawer() {
    return Drawer(
      elevation: 0,
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage('assets/logo/logo.png')),
            ),
          ),
          ListTile(
              onTap: () {},
              title: Text(
                'Register School',
                style: TextStyle(color: Colors.indigo),
              )),
          ListTile(
            onTap: () {},
            title: Text(
              'Our Team',
              style: TextStyle(color: Colors.indigo),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (contexr) => HelpandSupport()));
            },
            title: Text(
              'Help and Support',
              style: TextStyle(color: Colors.indigo),
            ),
          )
        ],
      ),
    );
  }

  Widget buildPage() {
    var pref = Provider.of<SharedPreferences>(context);

    if (pref.getString('Student') != null) {
      return StudentHome();
    } else if (pref.getString('Principal') != null) {
      return PrincipalHomeScreen();
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("schools").snapshots(),
          builder: (context, snapshots) => (snapshots.hasData)
              ? Scaffold(
                  drawer: buildDrawer(),
                  appBar: topBar(snapshots.data.documents),
                  body: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(top: 40),
                      itemBuilder: (context, i) {
                        return buildSchoolListcard(i, snapshots.data.documents);
                      },
                      itemCount: snapshots.data.documents.length),
                )
              : Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ));
    }
  }
}

class topBar extends StatelessWidget implements PreferredSizeWidget {
  List<DocumentSnapshot> list;

  topBar(this.list);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.loose,
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          color: Colors.indigo,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Select School',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          color: Colors.indigo,
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) => FilterMenu(context),
                                useRootNavigator: true,
                                backgroundColor: Colors.white);
                          },
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            width: MediaQuery.of(context).size.width * 0.80,
            bottom: -15,
            height: 50,
            child: RaisedButton(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[Icon(Icons.search), Text('Search.......')],
              ),
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SchoolSearch(schoolsList: list));
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromRadius(80);

  FilterMenu(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Filters',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Colors.black87),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);
          },
          leading: Icon(Icons.location_on),
          title: Text('by location'),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);
          },
          leading: Icon(Icons.star),
          title: Text('by Rating'),
        )
      ],
    );
  }
}

class SchoolSearch extends SearchDelegate {
  List<DocumentSnapshot> schoolsList;

  SchoolSearch({this.schoolsList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: schoolsList.length,
        itemBuilder: (context, index) => Card(
              child: ListTile(
                onTap: () {},
                leading: Icon(Icons.school),
                title: Text(schoolsList[index].data['name']),
                subtitle: Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on,
                      size: 13,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(schoolsList[index].data['address']),
                  ],
                ),
              ),
            ));
  }
}
