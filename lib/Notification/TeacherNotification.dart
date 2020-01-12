import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherNotification {
  DocumentReference _documentReference;

  TeacherNotification() {
    _documentReference = Firestore.instance.document('Service/notification');
  }

  sendNotification(String title, message, id) {
    print(id);
    _documentReference
        .updateData({'title': title, 'message': message, 'id': id}).then((val) {
      print('Sent');
    });
  }
}
