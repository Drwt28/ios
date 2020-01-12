import 'package:flutter/material.dart';

class SpalashScreen extends StatelessWidget {
  Shader l1 = LinearGradient(
    colors: <Color>[Colors.lightBlue, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100, 10.0));

  Shader l2 = LinearGradient(
    colors: <Color>[Colors.blue, Colors.indigo],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 100, 100.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [Colors.lightBlue, Colors.blue, Colors.indigo])),
              child: Center(
                  child: Text(
                'S',
                style: TextStyle(fontSize: 50, color: Colors.white),
              )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'School',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    foreground: Paint()..shader = l1,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Magna',
                  style: TextStyle(
                    fontSize: 38,
                    foreground: Paint()..shader = l2,
                  ),
                )
              ],
            ),
          ),
        ],
      )),
    );
  }
}
