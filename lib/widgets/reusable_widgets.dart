import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakeel_diary/Database/crud_operation.dart';
import 'package:vakeel_diary/Pages/add_case_page.dart';

// Reusable text field widget
Widget buildTextField(
  String labelText,
  TextEditingController controller, {
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    cursorColor: Colors.black,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black87),
      hintStyle: const TextStyle(color: Colors.black26),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    style: const TextStyle(color: Colors.black),
  );
}

// Reusable date field widget
Widget buildDateField(
  String labelText,
  DateTime? selectedDate,
  VoidCallback onTap,
) {
  return TextFormField(
    readOnly: true,
    onTap: onTap,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black87),
      suffixIcon: const Icon(
        Icons.calendar_today_rounded,
        color: Colors.black,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(10),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    controller: TextEditingController(
      text: selectedDate != null
          ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
          : "",
    ),
  );
}

// Reusable function to build the case card
Widget buildCaseCard(
    BuildContext context, String caseId, Map<String, dynamic> data, bool showEditButton) {
  final caseTitle = data['CaseTitleAttribute'] ?? 'N/A';
  final caseNumber = data['CaseNumberAttribute'] ?? 'N/A';
  final courtName = data['CourtNameAttribute'] ?? 'N/A';
  final nextDate = (data['NextDateAttribute'] as Timestamp).toDate();

  return Dismissible(
    key: Key(caseId),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(
        Icons.delete_forever,
        color: Colors.white,
        size: 30,
      ),
    ),
    onDismissed: (direction) {
      CrudOperation().delete(caseId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$caseTitle dismissed")),
      );
    },
    child: GestureDetector(
      onLongPress: () => showCaseDetailsDialog(context, data),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            caseTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                "Case No: $caseNumber",
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                "Court: $courtName",
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                "Next Date: ${DateFormat('dd/MM/yyyy').format(nextDate)}",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          trailing: showEditButton
              ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCasePage(
                          caseId: caseId,
                          initialData: data,
                        ),
                      ),
                    );
                  },
                )
              : null,
        ),
      ),
    ),
  );
}

// Reusable function to show case details in a dialog
void showCaseDetailsDialog(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          data['CaseTitleAttribute'] ?? 'Case Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDetailRow("Case Number:", data['CaseNumberAttribute']),
              buildDetailRow("Court Name:", data['CourtNameAttribute']),
              buildDetailRow("Judge Name:", data['JudgeNameAttribute']),
              buildDetailRow(
                "Previous Date:",
                data['PreviousDateAttribute'] != null
                    ? DateFormat('dd/MM/yyyy').format(
                        (data['PreviousDateAttribute'] as Timestamp).toDate(),
                      )
                    : 'N/A',
              ),
              buildDetailRow(
                "Next Date:",
                data['NextDateAttribute'] != null
                    ? DateFormat('dd/MM/yyyy').format(
                        (data['NextDateAttribute'] as Timestamp).toDate(),
                      )
                    : 'N/A',
              ),
              const SizedBox(height: 16),
              const Text(
                "Notes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                data['NotesAttribute'] ?? 'N/A',
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );
}

// Reusable function to build detail rows for the dialog
Widget buildDetailRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: " $value"),
        ],
      ),
    ),
  );
}