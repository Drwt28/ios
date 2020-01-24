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
        backgroundColor: Colors.white,
        body: Center(

          child: Image(
            image: AssetImage('assets/logo/logo.png'),
            height: MediaQuery
                .of(context)
                .size
                .height * 0.6,
            width: MediaQuery
                .of(context)
                .size
                .width * 0.6,
          ),
        )
    );
  }
}
