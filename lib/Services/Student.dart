import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String rollNo, name, fName, mName, dateOfBirth;
  String id;
  String teacherId;
  String classId;
  DateTime lastAttendence;
  List<dynamic> presentList, absentList, leaveList;
  Map<String, dynamic> remark;

  List<dynamic> compulsorySubjectList, optionSubjectList;
  List<result> resultList;


  Student(this.rollNo,
      this.name,
      this.fName,
      this.mName,
      this.dateOfBirth,
      this.id,
      this.teacherId,
      this.classId,
      this.lastAttendence,
      this.presentList,
      this.absentList,
      this.leaveList,
      this.remark,
      this.compulsorySubjectList,
      this.optionSubjectList,
      this.resultList);

  factory Student.toStudent(Map<String, dynamic> map) {
    return Student(
        map['rollNo'],
        map['name'],
        map['fName'],
        map['mName'],
        map['dateOfBirth'],
        map['id'],
        map['teacherId'],
        map['classId'],
        map['lastAttendence'],
        map['presentList'] ?? List<Timestamp>(),
        map['absentList'] ?? List<Timestamp>(),
        map['leaveList'] ?? List<Timestamp>(),
        map['remark'],
        map['compulsorySubjectList'] ?? List<String>(),
        map['optioSubjectList'] ?? List<String>(),
        map['resultList']);
  }

  static toMap(Student student) {
    Map<String, dynamic> map = Map();

    map['rollNo'] = student.rollNo;
    map['name'] = student.name;
    map['fName'] = student.fName;
    map['mName'] = student.mName;
    map['dateOfBirth'] = student.dateOfBirth;
    map['id'] = student.id;
    map['teacherId'] = student.teacherId;
    map['classId'] = student.classId;
    map['lastAttendence'] = student.lastAttendence;
    map['presentList'] = student.presentList;
    map['absentList'] = student.absentList;
    map['leaveList'] = student.leaveList;
    map['remark'] = student.remark;
    map['compulsorySubjectList'] = student.compulsorySubjectList;
    map['optionSubjectList'] = student.optionSubjectList;
    map['resultList'] = student.resultList;

    return map;
  }
}

class result {
  String nameOfResult;
  List<String> SubjectList;
  Map<String, double> marks;
}
