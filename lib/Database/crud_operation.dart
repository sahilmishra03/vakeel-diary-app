import 'package:cloud_firestore/cloud_firestore.dart';

class CrudOperation {
  final CollectionReference obj = FirebaseFirestore.instance.collection(
    "cases",
  );

  Future<void> create(
    String caseTitle,
    String caseNumber,
    String courtName,
    String judgeName,
    DateTime previousDate,
    DateTime nextDate,
    String notes,
  ) {
    return obj.add({
      "CaseTitleAttribute": caseTitle,
      "CaseNumberAttribute": caseNumber,
      "CourtNameAttribute": courtName,
      "JudgeNameAttribute": judgeName,
      "PreviousDateAttribute": previousDate,
      "NextDateAttribute": nextDate,
      "NotesAttribute": notes,
    });
  }

  Stream<QuerySnapshot> read() {
    return obj.snapshots();
  }

  Future<void> update(
    String id,
    String caseTitle,
    String caseNumber,
    String courtName,
    String judgeName,
    DateTime previousDate,
    DateTime nextDate,
    String notes,
  ) {
    return obj.doc(id).update({
      "CaseTitleAttribute": caseTitle,
      "CaseNumberAttribute": caseNumber,
      "CourtNameAttribute": courtName,
      "JudgeNameAttribute": judgeName,
      "PreviousDateAttribute": previousDate,
      "NextDateAttribute": nextDate,
      "NotesAttribute": notes,
    });
  }
  
  Stream<QuerySnapshot> readTodayCases() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return obj
        .where("NextDateAttribute", isGreaterThanOrEqualTo: startOfDay)
        .where("NextDateAttribute", isLessThanOrEqualTo: endOfDay)
        .snapshots();
  }

  //delete a case
  Future<void> delete(String id) {
    return obj.doc(id).delete();
  }
}
