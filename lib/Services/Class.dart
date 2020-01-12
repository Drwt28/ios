class Class {
  String teacherName, className, section, classId, notice;
  Map<dynamic, dynamic> attendeceData;

  Class(
      {this.teacherName,
      this.className,
      this.section,
      this.classId,
      this.notice,
      this.studentId,
      this.subjectList,
      this.lastAttendence,
      this.presentStudents,
      this.homeWorkList,
        this.attendenceList
      });

  List<String> studentId;

  //contains all the subjects of class
  List<String> subjectList;
  DateTime lastAttendence;
  int presentStudents;

  //contain seven days of home
  List<Map<String, String>> homeWorkList;
  Map<DateTime, int> attendenceList;

  static Map<String, dynamic> convertToMap(Class temp) {
    Map<String, dynamic> map = Map();
    map['classId'] = temp.classId ?? '';
    map['teacherName'] = temp.teacherName ?? '';
    map['className'] = temp.className ?? '';
    map['section'] = temp.section ?? '';
    map['notice'] = temp.notice ?? '';
    map['studentid'] = temp.studentId ?? List<String>();
    map['subjectList'] = temp.subjectList ?? List<String>();
    map['lastAttendence'] = temp.lastAttendence ?? DateTime.now();
    map['presentStudents'] = temp.presentStudents ?? 0;
    map['homeWorkList'] = temp.homeWorkList ?? List<homeWork>();
    map['attendenceList'] = temp.attendenceList ?? Map<DateTime, int>();
    return map;
  }

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
        teacherName: map['teacherName'] ?? '',
        classId: map['classId'] ?? '',
        className: map['className'] ?? '',
        section: map['section'] ?? '',
        notice: map['notice'] ?? '',
        studentId: map['studentId'] ?? List<String>(),
        subjectList: map['subjectList'] ?? List<String>(),
        lastAttendence: map['lastAttendence'] ?? DateTime.now(),
        presentStudents: map['presentStudents'] ?? '0',
        homeWorkList: map['homeWorkList'] ?? List<homeWork>(),
        attendenceList: map['attendenceList'] ?? Map<DateTime, int>());
  }
}

// ignore: camel_case_types
class homeWork {
  String day, text, imageUri;
}
