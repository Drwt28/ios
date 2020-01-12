import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_magna/Services/Class.dart';

class Teacher {
  FirebaseUser user;

  DocumentReference ref;

  bool isLoggedin() {
    if (FirebaseAuth.instance.currentUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  init() async {
    this.user = await FirebaseAuth.instance.currentUser();

    if (user != null) {
      this.ref = Firestore.instance
          .collection("schoolsTest")
          .document("school_1")
          .collection("classes")
          .document(user.email);

      print(user.email);
    } else {
      this.ref = null;
      print(ref.toString());
    }
  }

  static Future login(id, pass) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: id, password: pass)
        .then((AuthResult result) {
      if (result.user != null) {
        return result.user;
      } else {
        return null;
      }
    }).catchError((e) {
      print(e.toString());
      return null;
    });
  }

  Future<Class> checkForData() async {
    init();
    ref.get().then((DocumentSnapshot snap) {
      print(snap.toString());
    }).catchError((Error e) {
      print(e.toString());
    });
  }

  Future<bool> setData(Class s) async {
    if (isLoggedin())
      await ref.setData(Class.convertToMap(s)).whenComplete(() {
        return true;
      });
  }
}

class _homeWork {
  String day, text, imageUri;
}
