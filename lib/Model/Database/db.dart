import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_magna/Services/Class.dart';
import 'package:school_magna/Services/Student.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Future<Class> getClass(String id, schoolId) async {
    var snap = await _db
        .collection("schools")
        .document(schoolId)
        .collection("classes")
        .document(id)
        .get();

    return Class.fromMap(snap.data);
  }

  Stream<Class> streamClass(String schoolId, String id) {
    return _db
        .collection("schools")
        .document(schoolId)
        .collection("classes")
        .document(id)
        .snapshots()
        .map((snap) => Class.fromMap(snap.data));
  }

  DocumentSnapshot getDocument(String id, schoolId) {}


  List<Student> getStudents(String classId, schoolId) {
    List<Student> students = [];
    _db.collection('schools').document(schoolId).collection('students').where(
        'classId', isEqualTo: classId).getDocuments()
        .then((query) {
      for (DocumentSnapshot snapshot in query.documents) {
        students.add(Student.toStudent(snapshot.data));
      }
    });


    return students;
  }
}
