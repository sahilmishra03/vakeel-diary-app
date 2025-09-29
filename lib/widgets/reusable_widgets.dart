import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vakeel_diary/Pages/add_case_page.dart';
import 'package:vakeel_diary/Database/crud_operation.dart'; // Ensure this is imported

// --- THEME COLORS ---
const Color primaryBlue = Color(0xFF1A237E);
const Color darkGray = Color(0xFF424242);
const Color mediumGray = Color(0xFF9E9E9E);
const Color offWhite = Color(0xFFF5F5F5);

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
    cursorColor: primaryBlue,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: darkGray),
      hintStyle: const TextStyle(color: mediumGray),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: mediumGray, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryBlue, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    style: const TextStyle(color: darkGray),
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
      labelStyle: const TextStyle(color: darkGray),
      suffixIcon: const Icon(
        Icons.calendar_today_outlined,
        color: primaryBlue,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: mediumGray, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryBlue, width: 2.5),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
    ),
    controller: TextEditingController(
      text: selectedDate != null
          ? DateFormat('dd MMM yyyy').format(selectedDate)
          : "",
    ),
    style: const TextStyle(color: darkGray),
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
      color: Colors.red.shade700,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(
        Icons.delete_forever,
        color: offWhite,
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
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: mediumGray, width: 1.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            caseTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryBlue,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildDetailRowWithIcon(Icons.looks_one, "Case No:", caseNumber),
              _buildDetailRowWithIcon(Icons.gavel, "Court:", courtName),
              _buildDetailRowWithIcon(
                Icons.calendar_today,
                "Next Date:",
                DateFormat('dd MMM yyyy').format(nextDate),
              ),
            ],
          ),
          trailing: showEditButton
              ? IconButton(
                  icon: const Icon(Icons.edit, color: primaryBlue),
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

// Reusable function to show case details in a dialog with a smooth scale animation
void showCaseDetailsDialog(BuildContext context, Map<String, dynamic> data) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dialog',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              data['CaseTitleAttribute'] ?? 'Case Details',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRowWithIcon(Icons.looks_one_outlined, "Case Number:", data['CaseNumberAttribute']),
                  _buildDetailRowWithIcon(Icons.gavel_outlined, "Court Name:", data['CourtNameAttribute']),
                  _buildDetailRowWithIcon(Icons.account_circle_outlined, "Judge Name:", data['JudgeNameAttribute']),
                  _buildDetailRowWithIcon(
                    Icons.calendar_today_outlined,
                    "Previous Date:",
                    data['PreviousDateAttribute'] != null
                        ? DateFormat('dd MMM yyyy').format((data['PreviousDateAttribute'] as Timestamp).toDate())
                        : 'N/A',
                  ),
                  _buildDetailRowWithIcon(
                    Icons.calendar_today_outlined,
                    "Next Date:",
                    data['NextDateAttribute'] != null
                        ? DateFormat('dd MMM yyyy').format((data['NextDateAttribute'] as Timestamp).toDate())
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Notes:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: darkGray),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['NotesAttribute'] ?? 'N/A',
                    style: const TextStyle(color: darkGray),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Close",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Reusable function to build detail rows for the dialog with icons
Widget _buildDetailRowWithIcon(IconData icon, String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: darkGray),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: darkGray, fontSize: 16),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " $value"),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}